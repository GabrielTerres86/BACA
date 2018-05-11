CREATE OR REPLACE PACKAGE CECRED.CADA0006 is
 /* ---------------------------------------------------------------------------------------------------------------
  
    Programa : CADA0004
    Sistema  : Rotinas para detalhes de cadastros
    Sigla    : CADA
    Autor    : Odirlei Busana - AMcom
    Data     : Agosto/2015.                   Ultima atualizacao: 25/04/2017
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Rotinas para buscar detalhes de cadastros
  
   Alteracoes:   

  ---------------------------------------------------------------------------------------------------------------*/
	
  -- Validar transferencia de contas entre tipos de conta.
  PROCEDURE pc_valida_transferencia(pr_inpessoa   IN INTEGER --> Tipo de pessoa
                                   ,pr_cdcooper   IN INTEGER --> Código da cooperativa
                                   ,pr_tipcta_ori IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo tipo de conta de origem
                                   ,pr_tipcta_des IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo tipo de conta de destino
                                   ,pr_cdcritic  OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                   ,pr_dscritic  OUT crapcri.dscritic%TYPE); --> Descricao Erro  
  
  -- Transferir tipo de conta
  PROCEDURE pc_valida_novo_tipo(pr_inpessoa   IN INTEGER --> Tipo de pessoa
                               ,pr_cdcooper   IN INTEGER --> Código da cooperativa
                               ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta
                               ,pr_tipcta_ori IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo tipo de conta de origem
                               ,pr_tipcta_des IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo tipo de conta de destino
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                               ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao Erro  
  
  -- Verificar se o tipo de conta permite o produto
  PROCEDURE pc_permite_produto_tipo(pr_cdprodut  IN tbcc_produto.cdproduto%TYPE --> Codigo do produto
                                   ,pr_cdtipcta  IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo do produto
                                   ,pr_cdcooper  IN INTEGER --> Código da cooperativa
                                   ,pr_inpessoa  IN INTEGER --> Tipo de pessoa
                                   ,pr_possuipr OUT VARCHAR2 --> possui produto
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao Erro 
                                   
  PROCEDURE pc_busca_valor_contratado(pr_cdcooper  IN INTEGER --> Código da cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                                     ,pr_cdprodut  IN tbcc_produto.cdproduto%TYPE --> Codigo do produto
                                     ,pr_vlcontra OUT NUMBER --> Valor contratado
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao Erro  
                                   
  PROCEDURE pc_buscar_tpconta_coop_web(pr_inpessoa  IN tbcc_tipo_conta_coop.inpessoa%TYPE 
                                      ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2); --> Erros do processo
                                   
  PROCEDURE pc_buscar_tipos_de_conta_web(pr_inpessoa  IN tbcc_tipo_conta_coop.inpessoa%TYPE 
                                        ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                        ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2); --> Erros do processo
                                        
  PROCEDURE pc_buscar_situacoes_conta_web(pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2); --> Erros do processo
                                        
  PROCEDURE pc_excluir_tipo_conta_coop(pr_inpessoa  IN INTEGER --> tipo de pessoa
                                      ,pr_tpconta   IN INTEGER --> codigo do tipo de conta
                                      ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2); --> Erros do processo
                                      
  PROCEDURE pc_descricao_tipo_conta(pr_inpessoa      IN tbcc_tipo_conta.inpessoa%TYPE --> tipo de pessoa
                                   ,pr_cdtipo_conta  IN tbcc_tipo_conta.cdtipo_conta%TYPE --> codigo do tipo de conta
                                   ,pr_dstipo_conta OUT tbcc_tipo_conta.dstipo_conta%TYPE --> descricao do tipo de conta
                                   ,pr_des_erro     OUT VARCHAR2 --> Código da crítica
                                   ,pr_dscritic     OUT VARCHAR2); --> Descrição da crítica
                                   
  PROCEDURE pc_busca_modalidade_tipo(pr_inpessoa           IN tbcc_tipo_conta.inpessoa%TYPE --> tipo de pessoa
                                    ,pr_cdtipo_conta       IN tbcc_tipo_conta.cdtipo_conta%TYPE --> codigo do tipo de conta
                                    ,pr_cdmodalidade_tipo OUT INTEGER --> descricao do tipo de conta
                                    ,pr_des_erro          OUT VARCHAR2 --> Código da crítica
                                    ,pr_dscritic          OUT VARCHAR2); --> Descrição da crítica
                                    
  PROCEDURE pc_valida_prod_liberado(pr_cdcooper  IN tbcc_produtos_coop.cdcooper%TYPE --> Codigo da cooperativa
                                   ,pr_inpessoa  IN tbcc_produtos_coop.inpessoa%TYPE --> tipo de pessoa
                                   ,pr_cdtipcta  IN tbcc_produtos_coop.tpconta%TYPE --> codigo do tipo de conta
                                   ,pr_cdproduto IN tbcc_produtos_coop.cdproduto%TYPE --> codigo do produto
                                   ,pr_permprod OUT INTEGER --> Flag permite produto
                                   ,pr_des_erro OUT VARCHAR2 --> Código da crítica (0-NÃO/1-SIM)
                                   ,pr_dscritic OUT VARCHAR2); --> Descrição da crítica
                                   
  PROCEDURE pc_valida_tipo_conta_coop(pr_cdcooper      IN tbcc_tipo_conta_coop.cdcooper%TYPE --> Codigo da cooperativa
                                     ,pr_inpessoa      IN tbcc_tipo_conta_coop.inpessoa%TYPE --> tipo de pessoa
                                     ,pr_cdtipo_conta  IN tbcc_tipo_conta_coop.cdtipo_conta%TYPE --> codigo do tipo de conta
                                     ,pr_flgtpcta     OUT VARCHAR2 --> flag existe tipo de conta (0-Nao/1-Sim)
                                     ,pr_des_erro     OUT VARCHAR2 --> Código da crítica
                                     ,pr_dscritic     OUT VARCHAR2); --> Descrição da crítica
                                     
  PROCEDURE pc_lista_tipo_modalidade(pr_inpessoa    IN tbcc_tipo_conta_coop.inpessoa%TYPE --> tipo de pessoa
                                    ,pr_modalidades IN VARCHAR2 --> lista de modalidades
                                    ,pr_tpcontas   OUT VARCHAR2 --> lista de tipos de conta
                                    ,pr_des_erro   OUT VARCHAR2 --> Código da crítica
                                    ,pr_dscritic   OUT VARCHAR2); --> Descrição da crítica
                                    
  PROCEDURE pc_busca_tipo_conta_itg(pr_inpessoa      IN tbcc_tipo_conta.inpessoa%TYPE --> tipo de pessoa
                                   ,pr_cdtipo_conta  IN tbcc_tipo_conta.cdtipo_conta%TYPE --> tipo de conta
                                   ,pr_indconta_itg OUT tbcc_tipo_conta.indconta_itg%TYPE --> lista de tipos de conta
                                   ,pr_des_erro     OUT VARCHAR2 --> Código da crítica
                                   ,pr_dscritic     OUT VARCHAR2); --> Descrição da crítica
                                    
  PROCEDURE pc_lista_tipo_conta_itg(pr_indconta_itg  IN tbcc_tipo_conta.indconta_itg%TYPE --> flag conta integração
                                   ,pr_cdmodalidade  IN tbcc_tipo_conta.cdmodalidade_tipo%TYPE --> modalidade
                                   ,pr_tiposconta   OUT CLOB --> tipos de conta
                                   ,pr_des_erro     OUT VARCHAR2 --> Código da crítica
                                   ,pr_dscritic     OUT VARCHAR2); --> Descrição da crítica
                                    
  PROCEDURE pc_valida_grupo_historico(pr_cdgrupo_historico IN tbcc_grupo_historico.cdgrupo_historico%TYPE --> codigo do tipo de conta
                                     ,pr_flggphis         OUT VARCHAR2 --> flag existe grupo de historico (0-Nao/1-Sim)
                                     ,pr_des_erro         OUT VARCHAR2 --> Código da crítica
                                     ,pr_dscritic         OUT VARCHAR2); --> Descrição da crítica
  
  PROCEDURE pc_descricao_grupo_historico(pr_cdgrupo_historico  IN tbcc_grupo_historico.cdgrupo_historico%TYPE --> codigo do tipo de conta
                                        ,pr_dsgrupo_historico OUT tbcc_grupo_historico.dsgrupo_historico%TYPE --> descricao do tipo de conta
                                        ,pr_des_erro          OUT VARCHAR2 --> Código da crítica
                                        ,pr_dscritic          OUT VARCHAR2); --> Descrição da crítica
  
  PROCEDURE pc_verifica_tipo_acesso(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                   ,pr_cdsitdct IN crapass.cdsitdct%TYPE --> Situacao
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE --> Codigo do operador
                                   ,pr_flacesso OUT INTEGER              --> Tipo de acesso
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao Erro  
END CADA0006;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CADA0006 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0006
  --  Sistema  : Rotinas para detalhes de cadastros
  --  Sigla    : CADA
  --  Autor    : Lombardi
  --  Data     : Janeiro/2018.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para manutenção de tipos de conta
  --
  -- Alteracoes:   
  ---------------------------------------------------------------------------------------------------------------
  
  /*****************************************************************************/
  /**                      Procedure valida transferencia                     **/
  /*****************************************************************************/
  
  PROCEDURE pc_valida_transferencia(pr_inpessoa   IN INTEGER --> Tipo de pessoa
                                   ,pr_cdcooper   IN INTEGER --> Código da cooperativa
                                   ,pr_tipcta_ori IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo tipo de conta de origem
                                   ,pr_tipcta_des IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo tipo de conta de destino
                                   ,pr_cdcritic  OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                   ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS --> Descricao Erro  
    /* .............................................................................
    
        Programa: pc_valida_transferencia
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Janeiro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para validar transferencia de contas entre tipos de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic crapcri.dscritic%TYPE; --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis auxiliares
      vr_nrcontas INTEGER;
      
      -- Busca tipo de conta
      CURSOR cr_tipo_conta (pr_inpessoa     IN tbcc_tipo_conta.inpessoa%TYPE
                           ,pr_cdtipo_conta IN tbcc_tipo_conta.cdtipo_conta%TYPE) IS
        SELECT cta.cdtipo_conta
          FROM tbcc_tipo_conta cta
         WHERE cta.inpessoa = pr_inpessoa
           AND cta.cdtipo_conta = pr_cdtipo_conta;
      rw_tipo_conta cr_tipo_conta%ROWTYPE;
      
      -- Busca contas atreladas ao tipo de conta
      CURSOR cr_crapass (pr_inpessoa     IN tbcc_tipo_conta.inpessoa%TYPE
                        ,pr_cdtipo_conta IN tbcc_tipo_conta.cdtipo_conta%TYPE
                        ,pr_cdcooper     IN crapcop.cdcooper%TYPE) IS
        SELECT ass.nrdconta
          FROM crapass ass
              ,tbcc_tipo_conta_coop ctc
         WHERE ass.cdcooper = ctc.cdcooper
           AND ass.inpessoa = ctc.inpessoa
           AND ass.cdtipcta = ctc.cdtipo_conta
           AND ctc.inpessoa = pr_inpessoa
           AND ctc.cdtipo_conta = pr_cdtipo_conta
           AND ctc.cdcooper = pr_cdcooper;
           
    BEGIN
     
      -- Verifica tipo de conta de origem
      IF pr_tipcta_ori = 0 THEN
        vr_dscritic := 'Código do tipo de conta origem inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica tipo de conta de destino
      IF pr_tipcta_des = 0 THEN
        vr_dscritic := 'Código do tipo de conta destino inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca tipo de conta de origem
      OPEN cr_tipo_conta (pr_inpessoa     => pr_inpessoa
                         ,pr_cdtipo_conta => pr_tipcta_ori);
      FETCH cr_tipo_conta INTO rw_tipo_conta;
      
      IF cr_tipo_conta%NOTFOUND THEN
        CLOSE cr_tipo_conta;
        vr_dscritic := 'Tipo de conta de origem não encontrado.';
        RAISE vr_exc_saida;
      END IF;
      
      CLOSE cr_tipo_conta;
      
      -- Busca tipo de conta de destino
      OPEN cr_tipo_conta (pr_inpessoa     => pr_inpessoa
                         ,pr_cdtipo_conta => pr_tipcta_des);
      FETCH cr_tipo_conta INTO rw_tipo_conta;
      
      IF cr_tipo_conta%NOTFOUND THEN
        CLOSE cr_tipo_conta;
        vr_dscritic := 'Tipo de conta de destino não encontrado.';
        RAISE vr_exc_saida;
      END IF;
      
      CLOSE cr_tipo_conta;
      
      vr_nrcontas := 0;
      
      -- varre as contas com o tipo de conta de origem
      FOR rw_crapass IN cr_crapass (pr_inpessoa     => pr_inpessoa
                                   ,pr_cdtipo_conta => pr_tipcta_ori
                                   ,pr_cdcooper     => pr_cdcooper) LOOP
        -- Valida transferencia
        pc_valida_novo_tipo(pr_inpessoa => pr_inpessoa
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_crapass.nrdconta
                           ,pr_tipcta_ori => pr_tipcta_ori
                           ,pr_tipcta_des => pr_tipcta_des
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
        -- Se ocorrer algum erro
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        vr_nrcontas := vr_nrcontas + 1;
      END LOOP;
      
      -- Caso não encontre nenhuma conta para transferir gera erro
      IF vr_nrcontas = 0 THEN
        vr_dscritic := 'Nenhuma conta encontrada para transferência!';
        RAISE vr_exc_saida;
      END IF;
      
     
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TIPCTA: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_valida_transferencia;
  
  /*****************************************************************************/
  /**                   Procedure valida novo tipo de conta                   **/
  /*****************************************************************************/
  
  PROCEDURE pc_valida_novo_tipo(pr_inpessoa   IN INTEGER --> Tipo de pessoa
                               ,pr_cdcooper   IN INTEGER --> Código da cooperativa
                               ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta
                               ,pr_tipcta_ori IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo tipo de conta de origem
                               ,pr_tipcta_des IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo tipo de conta de destino
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                               ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao Erro  
    /* .............................................................................
    
        Programa: pc_valida_novo_tipo
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Janeiro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para transferir tipo de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_possuipr  VARCHAR2(1);
      
      --Variaveis auxiliares
      vr_vlcontra NUMBER;
      
      -- Busca pelos produtos do tipo de conta origem
      CURSOR cr_produtos (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_cdtipcta IN crapass.cdtipcta%TYPE
                         ,pr_inpessoa IN crapass.inpessoa%TYPE)IS
        SELECT pro.cdproduto
              ,prc.vlminimo_adesao
              ,prc.vlmaximo_adesao
              ,pro.idfaixa_valor
          FROM tbcc_produto pro
              ,tbcc_produtos_coop prc
         WHERE prc.cdproduto = pro.cdproduto
           AND prc.cdcooper = pr_cdcooper
           AND prc.tpconta = pr_cdtipcta
           AND prc.inpessoa = pr_inpessoa;
      
    BEGIN
      -- loop pelos produtos do tipo de conta origem
      FOR rw_produtos IN cr_produtos (pr_cdcooper => pr_cdcooper
                                     ,pr_cdtipcta => pr_tipcta_ori
                                     ,pr_inpessoa => pr_inpessoa) LOOP
        -- Se o produto estiver habilitado para essa conta
        IF cada0003.fn_produto_habilitado(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdproduto => rw_produtos.cdproduto) = 'S' THEN
          -- Verifica se o tipo de conta destino permite o produto
          pc_permite_produto_tipo(pr_cdprodut => rw_produtos.cdproduto
                                 ,pr_cdtipcta => pr_tipcta_des
                                 ,pr_cdcooper => pr_cdcooper
                                 ,pr_inpessoa => pr_inpessoa
                                 ,pr_possuipr => vr_possuipr
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
          -- Se houver alguma crítica
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          
          IF vr_possuipr = 'N' THEN
            vr_dscritic := 'Conta ' || gene0002.fn_mask_conta(pr_nrdconta) || ' nao atende aos requisitos do tipo de conta destino.';
            RAISE vr_exc_saida;
          END IF;
          
          IF rw_produtos.idfaixa_valor = 1 THEN
          
           -- Buscar valor contratado
          pc_busca_valor_contratado(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_cdprodut => rw_produtos.cdproduto
                                   ,pr_vlcontra => vr_vlcontra
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
          -- Se ocorrer algum erro
          IF vr_cdcritic > 0 AND vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
        END IF;
          
          -- Verifica se o valor contratado para o produto está de acordo
            IF vr_vlcontra IS NOT NULL AND
              (vr_vlcontra < rw_produtos.vlminimo_adesao OR
               vr_vlcontra > rw_produtos.vlmaximo_adesao) THEN
              vr_dscritic := 'Conta ' || gene0002.fn_mask_conta(pr_nrdconta) || ' nao atende aos requisitos do tipo de conta destino.';
            RAISE vr_exc_saida;
          END IF;
          
        END IF;
        END IF;
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_valida_novo_tipo: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_valida_novo_tipo;
   
  /*****************************************************************************/
  /**                 Procedure permite produto tipo de conta                 **/
  /*****************************************************************************/
  
  PROCEDURE pc_permite_produto_tipo(pr_cdprodut  IN tbcc_produto.cdproduto%TYPE --> Codigo do produto
                                   ,pr_cdtipcta  IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo do produto
                                   ,pr_cdcooper  IN INTEGER --> Código da cooperativa
                                   ,pr_inpessoa  IN INTEGER --> Tipo de pessoa
                                   ,pr_possuipr OUT VARCHAR2 --> possui produto
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao Erro  
    /* .............................................................................
    
        Programa: pc_permite_produto_tipo
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Janeiro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para verificar se o tipo de conta permite o produto
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Verifica se existe o produto para o tipo de conta
      CURSOR cr_produto (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_cdtipcta IN crapass.cdtipcta%TYPE
                        ,pr_inpessoa IN crapass.inpessoa%TYPE
                        ,pr_cdprodut IN tbcc_produto.cdproduto%TYPE)IS
        SELECT prd.idfaixa_valor
              ,prc.vlminimo_adesao
              ,prc.vlmaximo_adesao
          FROM tbcc_produtos_coop prc
              ,tbcc_produto       prd
         WHERE prc.cdcooper = pr_cdcooper
           AND prc.tpconta = pr_cdtipcta
           AND prc.cdproduto = pr_cdprodut
           AND prc.inpessoa = pr_inpessoa
           AND prc.cdproduto = prd.cdproduto;
      rw_produto cr_produto%ROWTYPE;
    BEGIN
      
      -- Verifica se existe o produto para o tipo de conta
      OPEN cr_produto(pr_cdcooper => pr_cdcooper
                     ,pr_cdtipcta => pr_cdtipcta
                     ,pr_inpessoa => pr_inpessoa
                     ,pr_cdprodut => pr_cdprodut);
      FETCH cr_produto INTO rw_produto;
      -- se existir
      IF cr_produto%FOUND THEN
        pr_possuipr := 'S'; -- Permite produto
      ELSE
        pr_possuipr := 'N'; -- Não permite produto
      END IF;
      
      CLOSE cr_produto;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TIPCTA: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_permite_produto_tipo;
  
  /*****************************************************************************/
  /**                    Procedure busca valor contratado                     **/
  /*****************************************************************************/
  
  PROCEDURE pc_busca_valor_contratado(pr_cdcooper  IN INTEGER --> Código da cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                                     ,pr_cdprodut  IN tbcc_produto.cdproduto%TYPE --> Codigo do produto
                                     ,pr_vlcontra OUT NUMBER --> Valor contratado
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao Erro  
    /* .............................................................................
    
        Programa: pc_busca_valor_contratado
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Janeiro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar valor contratado
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- buscar os limites contratados de cartão de crédito
      CURSOR cr_crawcrd (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
        SELECT SUM(vllimitg)
          FROM (SELECT t.nrcctitg
                      ,MAX(t.vllimcrd) vllimitg
                  FROM crawcrd t
                 WHERE cdcooper = pr_cdcooper
                   AND nrdconta = pr_nrdconta
                   AND cdadmcrd BETWEEN 10 AND 80
                   AND insitcrd IN (1, -- Aprovado
                                    2, -- Solicitado
                                    3, -- Liberado
                                    4, -- Em uso
                                    5) -- Bloqueado
                 GROUP BY t.nrcctitg);
      
      -- buscar os limites contratados de cartão de crédito BB e cartão de crédito empresarial
      CURSOR cr_crawcrd_bb (pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
        SELECT SUM(vllimitg)
          FROM (SELECT t.nrcctitg
                     , MAX(t.vllimcrd) vllimitg
                  FROM crawcrd t
                     , crapass p
                 WHERE p.cdcooper = t.cdcooper
                   AND p.nrdconta = t.nrdconta
                   AND t.cdcooper = pr_cdcooper
                   AND t.nrdconta = pr_nrdconta
                   AND (t.cdadmcrd NOT BETWEEN 10 AND 80 
                         OR p.inpessoa <> 1)
                   AND t.insitcrd IN (1, -- Aprovado
                                      2, -- Solicitado
                                      3, -- Liberado
                                      4, -- Em uso
                                      5) -- Bloqueado
                   GROUP BY t.nrcctitg);
      
      -- buscar valor referente a integralização de capital
      CURSOR cr_crapcot (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
        SELECT vldcotas
          FROM crapcot t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta;
           
      -- buscar o valor de Planos de cotas contratados, utilizar a consulta:
      CURSOR cr_crappla (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
        SELECT sum(vlprepla)
          FROM crappla
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND cdsitpla = 1;
           
    BEGIN
      
      IF pr_cdprodut = 12 THEN -- Integralização de capital
        
        -- buscar valor referente a integralização de capital
        OPEN cr_crapcot(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapcot INTO pr_vlcontra;
        CLOSE cr_crapcot;
        
      ELSIF pr_cdprodut = 15 THEN -- Planos de Cotas
        -- buscar o valor de Planos de cotas contratados, utilizar a consulta:
        OPEN cr_crappla(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crappla INTO pr_vlcontra;
        CLOSE cr_crappla;

      ELSIF pr_cdprodut = 21 THEN -- Cartao credito CECRED
        
        -- buscar os limites contratados de cartão de crédito
        OPEN cr_crawcrd(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crawcrd INTO pr_vlcontra;
        CLOSE cr_crawcrd;
        
      ELSIF pr_cdprodut = 4 OR pr_cdprodut = 24 THEN -- Cartao de credito BB e cartao CRED empresarial
        
        -- buscar os limites contratados de cartão de crédito BB e cartão de crédito empresarial
        OPEN cr_crawcrd_bb(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crawcrd_bb INTO pr_vlcontra;
        CLOSE cr_crawcrd_bb;
        
      END IF;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_busca_valor_contratado: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_busca_valor_contratado;
  
  PROCEDURE pc_buscar_tpconta_coop_web(pr_inpessoa  IN tbcc_tipo_conta_coop.inpessoa%TYPE 
                                      ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_buscar_tpconta_coop_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Fevereiro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar os tipos de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis auxiliares
      vr_clob CLOB;   
      vr_xml_temp VARCHAR2(32726) := '';
      
      -- Busca tipo de conta
      CURSOR cr_tipos_conta_coop (pr_inpessoa IN tbcc_tipo_conta_coop.inpessoa%TYPE
                                 ,pr_cdcooper IN tbcc_tipo_conta_coop.cdcooper%TYPE) IS
        SELECT cta.cdtipo_conta
              ,cta.dstipo_conta
              ,cta.idindividual            
              ,cta.idconjunta_solidaria    
              ,cta.idconjunta_nao_solidaria
          FROM tbcc_tipo_conta cta
              ,tbcc_tipo_conta_coop ctc
         WHERE cta.inpessoa = pr_inpessoa
           AND ctc.inpessoa = cta.inpessoa
           AND ctc.cdcooper = pr_cdcooper
           AND ctc.cdtipo_conta = cta.cdtipo_conta
         ORDER BY cta.cdtipo_conta;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
        
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><tipos_conta>');
      
      FOR rw_tipos_conta_coop IN cr_tipos_conta_coop(pr_inpessoa => pr_inpessoa
                                                    ,pr_cdcooper => vr_cdcooper) LOOP
        -- Carrega os dados
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<tipo_conta>' ||
                                                       '<cdtipo_conta>'             || rw_tipos_conta_coop.cdtipo_conta             || '</cdtipo_conta>' ||
                                                       '<dstipo_conta>'             || rw_tipos_conta_coop.dstipo_conta             || '</dstipo_conta>' ||
                                                       '<idindividual>'             || rw_tipos_conta_coop.idindividual             || '</idindividual>' ||
                                                       '<idconjunta_solidaria>'     || rw_tipos_conta_coop.idconjunta_solidaria     || '</idconjunta_solidaria>' ||
                                                       '<idconjunta_nao_solidaria>' || rw_tipos_conta_coop.idconjunta_nao_solidaria || '</idconjunta_nao_solidaria>' ||
                                                     '</tipo_conta>');
      END LOOP;
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</tipos_conta></Root>'
                             ,pr_fecha_xml      => TRUE);

      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
      
    EXCEPTION
      WHEN vr_exc_saida THEN
      
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
      
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina CADA0006: ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_buscar_tpconta_coop_web;
  
  PROCEDURE pc_buscar_tipos_de_conta_web(pr_inpessoa  IN tbcc_tipo_conta_coop.inpessoa%TYPE 
                                        ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                        ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_buscar_tipos_de_conta_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Dezembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar os tipos de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis auxiliares
      vr_clob CLOB;   
      vr_xml_temp VARCHAR2(32726) := '';
      
      -- Busca tipo de conta
      CURSOR cr_tipos_conta_coop (pr_inpessoa IN tbcc_tipo_conta_coop.inpessoa%TYPE
                                 ,pr_cdcooper IN tbcc_tipo_conta_coop.cdcooper%TYPE) IS
        SELECT cta.cdtipo_conta
              ,cta.dstipo_conta
              ,cta.idindividual
              ,cta.idconjunta_solidaria
              ,cta.idconjunta_nao_solidaria
              ,(SELECT vlminimo_capital 
                  FROM tbcc_tipo_conta_coop ctc
                 WHERE ctc.inpessoa = cta.inpessoa
                   AND ctc.cdcooper = pr_cdcooper
                   AND ctc.cdtipo_conta = cta.cdtipo_conta) vlminimo_capital
          FROM tbcc_tipo_conta cta
         WHERE cta.inpessoa = pr_inpessoa
         ORDER BY cta.cdtipo_conta;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><tipos_conta>');
        
      FOR rw_tipos_conta_coop IN cr_tipos_conta_coop(pr_inpessoa => pr_inpessoa
                                                    ,pr_cdcooper => vr_cdcooper) LOOP
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<tipo_conta>' ||
                                                       '<cdtipo_conta>'     || rw_tipos_conta_coop.cdtipo_conta     || '</cdtipo_conta>' ||
                                                       '<dstipo_conta>'     || rw_tipos_conta_coop.dstipo_conta     || '</dstipo_conta>' ||
                                                       '<vlminimo_capital>' || to_char(rw_tipos_conta_coop.vlminimo_capital,'FM999G999G990D00') || '</vlminimo_capital>' ||
                                                       '<idindividual>'             || rw_tipos_conta_coop.idindividual             || '</idindividual>' ||
                                                       '<idconjunta_solidaria>'     || rw_tipos_conta_coop.idconjunta_solidaria     || '</idconjunta_solidaria>' ||
                                                       '<idconjunta_nao_solidaria>' || rw_tipos_conta_coop.idconjunta_nao_solidaria || '</idconjunta_nao_solidaria>' ||
                                                     '</tipo_conta>');
      END LOOP;
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</tipos_conta></Root>'
                             ,pr_fecha_xml      => TRUE);

      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
      
    EXCEPTION
      WHEN vr_exc_saida THEN
      
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
      
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina CADA0006: ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_buscar_tipos_de_conta_web;
  
  PROCEDURE pc_buscar_situacoes_conta_web(pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_buscar_situacoes_conta_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Janeiro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar as situações de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis auxiliares
      vr_clob CLOB;   
      vr_xml_temp VARCHAR2(32726) := '';
      
      -- Busca situacoes de conta
      CURSOR cr_situacao_conta (pr_cdcooper IN tbcc_situacao_conta_coop.cdcooper%TYPE) IS
        SELECT ctc.cdsituacao
             , sit.dssituacao
          FROM tbcc_situacao_conta       sit
             , tbcc_situacao_conta_coop  ctc
         WHERE sit.cdsituacao = ctc.cdsituacao
           AND ctc.cdcooper   = pr_cdcooper
         ORDER BY ctc.cdsituacao;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><situacoes_conta>');
        
      FOR rw_situacao_conta IN cr_situacao_conta(pr_cdcooper => vr_cdcooper) LOOP
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<situacao_conta>' ||
                                                       '<cdsituacao>' || rw_situacao_conta.cdsituacao || '</cdsituacao>' ||
                                                       '<dssituacao>' || rw_situacao_conta.dssituacao || '</dssituacao>' ||
                                                     '</situacao_conta>');
      END LOOP;
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</situacoes_conta></Root>'
                             ,pr_fecha_xml      => TRUE);

      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
      
    EXCEPTION
      WHEN vr_exc_saida THEN
      
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
      
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina CADA0006: ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_buscar_situacoes_conta_web;
  
  PROCEDURE pc_excluir_tipo_conta_coop(pr_inpessoa  IN INTEGER --> tipo de pessoa
                                      ,pr_tpconta   IN INTEGER --> codigo do tipo de conta
                                      ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_excluir_tipo_conta_coop
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Dezembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para excluir tipo de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Busca tipo de conta
      CURSOR cr_tipo_conta_coop(pr_inpessoa IN tbcc_tipo_conta_coop.inpessoa%TYPE
                               ,pr_tpconta  IN tbcc_tipo_conta_coop.cdtipo_conta%TYPE
                               ,pr_cdcooper IN tbcc_tipo_conta_coop.cdcooper%TYPE) IS
        SELECT ctc.cdtipo_conta
          FROM tbcc_tipo_conta_coop ctc
         WHERE ctc.inpessoa = pr_inpessoa
           AND ctc.cdtipo_conta = pr_tpconta
           AND ctc.cdcooper = pr_cdcooper;
      rw_tipo_conta_coop cr_tipo_conta_coop%ROWTYPE;
      
      -- Busca contas atreladas ao tipo de conta
      CURSOR cr_conta_atreladas(pr_inpessoa IN tbcc_tipo_conta.inpessoa%TYPE
                               ,pr_tpconta  IN tbcc_tipo_conta.cdtipo_conta%TYPE
                               ,pr_cdcooper IN tbcc_tipo_conta_coop.cdcooper%TYPE) IS
        SELECT 1
          FROM tbcc_tipo_conta_coop ctc
              ,crapass              ass
         WHERE ctc.inpessoa = pr_inpessoa
           AND ctc.cdtipo_conta = pr_tpconta
           AND ctc.cdcooper = pr_cdcooper
           AND ass.cdcooper = ctc.cdcooper
           AND ass.inpessoa = ctc.inpessoa
           AND ass.cdtipcta = ctc.cdtipo_conta
           AND ROWNUM = 1;
      rw_conta_atreladas cr_conta_atreladas%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica tipo de pessoa
      IF pr_inpessoa = 0 THEN
        vr_dscritic := 'Tipo de pessoa inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica tipo de conta
      IF pr_tpconta = 0 THEN
        vr_dscritic := 'Código do tipo de conta inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca tipo de conta
      OPEN cr_tipo_conta_coop(pr_inpessoa => pr_inpessoa
                             ,pr_tpconta  => pr_tpconta
                             ,pr_cdcooper => vr_cdcooper);
      FETCH cr_tipo_conta_coop INTO rw_tipo_conta_coop;
      
      IF cr_tipo_conta_coop%NOTFOUND THEN
        CLOSE cr_tipo_conta_coop;
        vr_dscritic := 'Tipo de conta não encontrado.';
        RAISE vr_exc_saida;
      END IF;
      
      CLOSE cr_tipo_conta_coop;

      -- Verifica se há contas atreladas
      OPEN cr_conta_atreladas(pr_inpessoa => pr_inpessoa
                             ,pr_tpconta  => pr_tpconta
                             ,pr_cdcooper => vr_cdcooper);
      FETCH cr_conta_atreladas INTO rw_conta_atreladas;
      
      IF cr_conta_atreladas%FOUND THEN
        CLOSE cr_conta_atreladas;
        vr_dscritic := 'Há contas que utilizam este Tipo de Conta. Exclusão não permitida!';
        RAISE vr_exc_saida;
      END IF;
      
      CLOSE cr_conta_atreladas;
      
      -- Exclui o tipo de conta
      BEGIN
        DELETE tbcc_tipo_conta_coop ctc
         WHERE ctc.inpessoa = pr_inpessoa
           AND ctc.cdtipo_conta = pr_tpconta
           AND ctc.cdcooper = vr_cdcooper;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir tipo de conta. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Exclui os produtos vinculados ao tipo de conta
      BEGIN
        DELETE tbcc_produtos_coop prc
         WHERE prc.inpessoa = pr_inpessoa
           AND prc.tpconta  = pr_tpconta
           AND prc.cdcooper = vr_cdcooper;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir tipo de conta. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root>OK</Root>');
      
    EXCEPTION
      WHEN vr_exc_saida THEN
      
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
      
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TIPCTA: ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_excluir_tipo_conta_coop;
  
  PROCEDURE pc_descricao_tipo_conta(pr_inpessoa      IN tbcc_tipo_conta.inpessoa%TYPE --> tipo de pessoa
                                   ,pr_cdtipo_conta  IN tbcc_tipo_conta.cdtipo_conta%TYPE --> codigo do tipo de conta
                                   ,pr_dstipo_conta OUT tbcc_tipo_conta.dstipo_conta%TYPE --> descricao do tipo de conta
                                   ,pr_des_erro     OUT VARCHAR2 --> Código da crítica
                                   ,pr_dscritic     OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_descricao_tipo_conta
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Dezembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar descricao do tipo de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Busca tipo de conta
      CURSOR cr_tipo_conta(pr_inpessoa IN tbcc_tipo_conta.inpessoa%TYPE
                          ,pr_tpconta  IN tbcc_tipo_conta.cdtipo_conta%TYPE) IS
        SELECT cta.dstipo_conta
          FROM tbcc_tipo_conta cta
         WHERE cta.inpessoa = pr_inpessoa
           AND cta.cdtipo_conta = pr_tpconta;
      rw_tipo_conta cr_tipo_conta%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      -- Verifica tipo de pessoa
      IF pr_inpessoa = 0 THEN
        vr_dscritic := 'Tipo de pessoa inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica tipo de conta
      IF pr_cdtipo_conta = 0 THEN
        vr_dscritic := 'Código do tipo de conta inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca tipo de conta
      OPEN cr_tipo_conta(pr_inpessoa => pr_inpessoa
                        ,pr_tpconta  => pr_cdtipo_conta);
      FETCH cr_tipo_conta INTO rw_tipo_conta;
      
      IF cr_tipo_conta%NOTFOUND THEN
        CLOSE cr_tipo_conta;
        vr_dscritic := 'Tipo de conta não encontrado.';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_tipo_conta;
      
      -- Retorna descricao do tipo de conta
      pr_dstipo_conta := rw_tipo_conta.dstipo_conta;
      pr_des_erro := 'OK';
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina pc_descricao_tipo_conta: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_descricao_tipo_conta;
  
  PROCEDURE pc_busca_modalidade_tipo(pr_inpessoa           IN tbcc_tipo_conta.inpessoa%TYPE --> tipo de pessoa
                                    ,pr_cdtipo_conta       IN tbcc_tipo_conta.cdtipo_conta%TYPE --> codigo do tipo de conta
                                    ,pr_cdmodalidade_tipo OUT INTEGER --> descricao do tipo de conta
                                    ,pr_des_erro          OUT VARCHAR2 --> Código da crítica
                                    ,pr_dscritic          OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_busca_modalidade_tipo
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Janeiro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar codigo da modalidade do tipo de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Busca tipo de conta
      CURSOR cr_tipo_conta(pr_inpessoa IN tbcc_tipo_conta.inpessoa%TYPE
                          ,pr_tpconta  IN tbcc_tipo_conta.cdtipo_conta%TYPE) IS
        SELECT cta.cdmodalidade_tipo
          FROM tbcc_tipo_conta cta
         WHERE cta.inpessoa = pr_inpessoa
           AND cta.cdtipo_conta = pr_tpconta;
      rw_tipo_conta cr_tipo_conta%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      -- Verifica tipo de pessoa
      IF pr_inpessoa = 0 THEN
        vr_dscritic := 'Tipo de pessoa inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica tipo de conta
      IF pr_cdtipo_conta = 0 THEN
        vr_dscritic := 'Código do tipo de conta inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca tipo de conta
      OPEN cr_tipo_conta(pr_inpessoa => pr_inpessoa
                        ,pr_tpconta  => pr_cdtipo_conta);
      FETCH cr_tipo_conta INTO rw_tipo_conta;
      
      IF cr_tipo_conta%NOTFOUND THEN
        CLOSE cr_tipo_conta;
        vr_dscritic := 'Tipo de conta não encontrado.';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_tipo_conta;
      
      -- Retorna codigo da modalidade do tipo de conta
      pr_cdmodalidade_tipo := rw_tipo_conta.cdmodalidade_tipo;
      pr_des_erro := 'OK';
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina pc_busca_modalidade_tipo: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_busca_modalidade_tipo;
  
  PROCEDURE pc_valida_prod_liberado(pr_cdcooper  IN tbcc_produtos_coop.cdcooper%TYPE --> Codigo da cooperativa
                                   ,pr_inpessoa  IN tbcc_produtos_coop.inpessoa%TYPE --> tipo de pessoa
                                   ,pr_cdtipcta  IN tbcc_produtos_coop.tpconta%TYPE --> codigo do tipo de conta
                                   ,pr_cdproduto IN tbcc_produtos_coop.cdproduto%TYPE --> codigo do produto
                                   ,pr_permprod OUT INTEGER --> Flag permite produto
                                   ,pr_des_erro OUT VARCHAR2 --> Código da crítica (0-NÃO/1-SIM)
                                   ,pr_dscritic OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_valida_prod_liberado
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Janeiro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para verificar se produto está liberado para o tipo de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Busca tipo de conta
      CURSOR cr_produtos(pr_cdcooper IN tbcc_produtos_coop.cdcooper%TYPE
                        ,pr_inpessoa IN tbcc_produtos_coop.inpessoa%TYPE
                        ,pr_cdtipcta IN tbcc_produtos_coop.tpconta%TYPE
                        ,pr_cdprodut IN tbcc_produtos_coop.cdproduto%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT 1
          FROM tbcc_produtos_coop  tpc
         WHERE tpc.cdcooper   = pr_cdcooper
           AND tpc.inpessoa   = pr_inpessoa
           AND tpc.tpconta    = pr_cdtipcta
           AND tpc.cdproduto  = pr_cdprodut
           AND (tpc.dtvigencia  IS NULL
            OR tpc.dtvigencia  >= pr_dtmvtolt);
      rw_produtos cr_produtos%ROWTYPE;
      
      -- Registro sobre a tabela de datas
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      
      -- Busca a data do sistema
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      
      -- Verifica tipo de pessoa
      IF pr_cdcooper = 0 THEN
        vr_dscritic := 'Cooperativa inválida.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica tipo de pessoa
      IF pr_inpessoa = 0 THEN
        vr_dscritic := 'Tipo de pessoa inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica tipo de conta
      IF pr_cdtipcta = 0 THEN
        vr_dscritic := 'Código do tipo de conta inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica se produto esta liberado
      OPEN cr_produtos(pr_cdcooper => pr_cdcooper
                      ,pr_inpessoa => pr_inpessoa
                      ,pr_cdtipcta => pr_cdtipcta
                      ,pr_cdprodut => pr_cdproduto
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
      FETCH cr_produtos INTO rw_produtos;
      
      IF cr_produtos%FOUND THEN
        pr_permprod := 1; -- Liberado
      ELSE
        pr_permprod := 0; -- Não Liberado
      END IF;
      
      CLOSE cr_produtos;
      
      pr_des_erro := 'OK';
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina pc_permite_produto_tipo: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_valida_prod_liberado;
  
  PROCEDURE pc_valida_tipo_conta_coop(pr_cdcooper      IN tbcc_tipo_conta_coop.cdcooper%TYPE --> Codigo da cooperativa
                                     ,pr_inpessoa      IN tbcc_tipo_conta_coop.inpessoa%TYPE --> tipo de pessoa
                                     ,pr_cdtipo_conta  IN tbcc_tipo_conta_coop.cdtipo_conta%TYPE --> codigo do tipo de conta
                                     ,pr_flgtpcta     OUT VARCHAR2 --> flag existe tipo de conta (0-Nao/1-Sim)
                                     ,pr_des_erro     OUT VARCHAR2 --> Código da crítica
                                     ,pr_dscritic     OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_valida_tipo_conta_coop
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Janeiro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para verificar se existe tipo de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Busca tipo de conta
      CURSOR cr_tipo_conta(pr_cdcooper     IN tbcc_tipo_conta_coop.cdcooper%TYPE
                          ,pr_inpessoa     IN tbcc_tipo_conta_coop.inpessoa%TYPE
                          ,pr_cdtipo_conta IN tbcc_tipo_conta_coop.cdtipo_conta%TYPE) IS
        SELECT 1
          FROM tbcc_tipo_conta_coop cta
         WHERE cta.inpessoa = pr_inpessoa
           AND cta.cdtipo_conta = pr_cdtipo_conta;
      rw_tipo_conta cr_tipo_conta%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      -- Verifica tipo de pessoa
      IF pr_cdcooper = 0 THEN
        vr_dscritic := 'Cooperativa inválida.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica tipo de pessoa
      IF pr_inpessoa = 0 THEN
        vr_dscritic := 'Tipo de pessoa inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica tipo de conta
      IF pr_cdtipo_conta = 0 THEN
        vr_dscritic := 'Código do tipo de conta inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca tipo de conta
      OPEN cr_tipo_conta(pr_cdcooper     => pr_cdcooper
                        ,pr_inpessoa     => pr_inpessoa
                        ,pr_cdtipo_conta => pr_cdtipo_conta);
      FETCH cr_tipo_conta INTO rw_tipo_conta;
      
      
      IF cr_tipo_conta%FOUND THEN
        pr_flgtpcta := 1; -- Existe
      ELSE
        pr_flgtpcta := 0; -- Não Existe
      END IF;
      
      CLOSE cr_tipo_conta;
      
      pr_des_erro := 'OK';
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina pc_valida_tipo_conta_coop: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_valida_tipo_conta_coop;
  
  PROCEDURE pc_lista_tipo_modalidade(pr_inpessoa    IN tbcc_tipo_conta_coop.inpessoa%TYPE --> tipo de pessoa
                                    ,pr_modalidades IN VARCHAR2 --> lista de modalidades
                                    ,pr_tpcontas   OUT VARCHAR2 --> lista de tipos de conta
                                    ,pr_des_erro   OUT VARCHAR2 --> Código da crítica
                                    ,pr_dscritic   OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_lista_tipo_modalidade
        Sistema : CECRED 
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Janeiro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para verificar se existe tipo de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Busca tipo de conta
      CURSOR cr_tipo_conta(pr_inpessoa    IN tbcc_tipo_conta_coop.inpessoa%TYPE
                          ,pr_modalidades IN VARCHAR2) IS
        SELECT cta.cdtipo_conta
          FROM tbcc_tipo_conta cta
         WHERE cta.inpessoa = pr_inpessoa
           AND gene0002.fn_existe_valor(pr_base => pr_modalidades
                                       ,pr_busca => cta.cdmodalidade_tipo
                                       ,pr_delimite => ',') = 'S';
      rw_tipo_conta cr_tipo_conta%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      -- Verifica tipo de pessoa
      IF pr_inpessoa = 0 THEN
        vr_dscritic := 'Tipo de pessoa inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      pr_tpcontas := '';
      
      -- Busca tipo de conta
      FOR rw_tipo_conta IN cr_tipo_conta(pr_inpessoa    => pr_inpessoa
                                        ,pr_modalidades => pr_modalidades) LOOP
        IF pr_tpcontas IS NOT NULL THEN
          pr_tpcontas := pr_tpcontas || ',';
        END IF;
        pr_tpcontas := pr_tpcontas || rw_tipo_conta.cdtipo_conta;
      END LOOP;
      
      pr_des_erro := 'OK';
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina pc_lista_tipo_modalidade: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_lista_tipo_modalidade;
  
  PROCEDURE pc_busca_tipo_conta_itg(pr_inpessoa      IN tbcc_tipo_conta.inpessoa%TYPE --> tipo de pessoa
                                   ,pr_cdtipo_conta  IN tbcc_tipo_conta.cdtipo_conta%TYPE --> tipo de conta
                                   ,pr_indconta_itg OUT tbcc_tipo_conta.indconta_itg%TYPE --> lista de tipos de conta
                                   ,pr_des_erro     OUT VARCHAR2 --> Código da crítica
                                   ,pr_dscritic     OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_busca_tipo_conta_itg
        Sistema : CECRED 
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Fevereiro/18.                    Ultima atualizacao: --/--/----
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para retornar o indicador de conta integração, indicando
                    se o tipo de conta em questão possui ou não conta integração.
        
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Busca tipo de conta
      CURSOR cr_tipo_conta(pr_inpessoa     IN tbcc_tipo_conta.inpessoa%TYPE
                          ,pr_cdtipo_conta IN tbcc_tipo_conta.cdtipo_conta%TYPE) IS
        SELECT cta.indconta_itg
          FROM tbcc_tipo_conta cta
         WHERE cta.inpessoa     = pr_inpessoa
           AND cta.cdtipo_conta = pr_cdtipo_conta;
      rw_tipo_conta cr_tipo_conta%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      -- Verifica tipo de pessoa
      IF pr_inpessoa = 0 THEN
        vr_dscritic := 'Tipo de pessoa inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca tipo de conta
      OPEN cr_tipo_conta(pr_inpessoa     => pr_inpessoa
                        ,pr_cdtipo_conta => pr_cdtipo_conta);
      FETCH cr_tipo_conta INTO rw_tipo_conta;
      
      IF cr_tipo_conta%FOUND THEN
        pr_indconta_itg := rw_tipo_conta.indconta_itg;
      ELSE
        vr_dscritic := 'Tipo de conta não encontrado.';
        RAISE vr_exc_saida;
      END IF;
      
      pr_des_erro := 'OK';
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina pc_busca_tipo_conta_itg: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_busca_tipo_conta_itg;
  
  PROCEDURE pc_lista_tipo_conta_itg(pr_indconta_itg  IN tbcc_tipo_conta.indconta_itg%TYPE --> flag conta integração
                                   ,pr_cdmodalidade  IN tbcc_tipo_conta.cdmodalidade_tipo%TYPE --> modalidade
                                   ,pr_tiposconta   OUT CLOB --> tipos de conta
                                   ,pr_des_erro     OUT VARCHAR2 --> Código da crítica
                                   ,pr_dscritic     OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_lista_tipo_conta_itg
        Sistema : CECRED 
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Fevereiro/18.                    Ultima atualizacao: --/--/----
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para retornar a lista de todos os tipos de conta que 
                    possuem conta integração ou que não possuem conta integração.
        
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis auxiliares
      vr_clob CLOB;   
      vr_xml_temp VARCHAR2(32726) := '';
      
      -- Busca tipo de conta
      CURSOR cr_tipo_conta(pr_indconta_itg IN tbcc_tipo_conta.indconta_itg%TYPE
                          ,pr_cdmodalidade IN tbcc_tipo_conta.cdmodalidade_tipo%TYPE) IS
        SELECT cta.inpessoa
              ,cta.cdtipo_conta
          FROM tbcc_tipo_conta cta
         WHERE cta.indconta_itg = pr_indconta_itg
           AND (pr_cdmodalidade = 0
            OR cta.cdmodalidade_tipo = pr_cdmodalidade);
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
      
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root>');
        
      FOR rw_tipo_conta IN cr_tipo_conta(pr_indconta_itg => pr_indconta_itg
                                        ,pr_cdmodalidade => pr_cdmodalidade) LOOP
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<tipo_conta>' ||
                                                       '<inpessoa>'     || rw_tipo_conta.inpessoa     || '</inpessoa>' ||
                                                       '<cdtipo_conta>' || rw_tipo_conta.cdtipo_conta || '</cdtipo_conta>' ||
                                                     '</tipo_conta>');
      END LOOP;
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Root>'
                             ,pr_fecha_xml      => TRUE);

      -- Atualiza o XML de retorno
      pr_tiposconta := vr_clob;
      
      pr_des_erro := 'OK';
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina pc_busca_tipo_conta_itg: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_lista_tipo_conta_itg;
  
  PROCEDURE pc_valida_grupo_historico(pr_cdgrupo_historico IN tbcc_grupo_historico.cdgrupo_historico%TYPE --> codigo do tipo de conta
                                     ,pr_flggphis         OUT VARCHAR2 --> flag existe grupo de historico (0-Nao/1-Sim)
                                     ,pr_des_erro         OUT VARCHAR2 --> Código da crítica
                                     ,pr_dscritic         OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_valida_grupo_historico
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Janeiro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para verificar se existe grupo de historico.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Busca grupo de historico
      CURSOR cr_grupo_historico(pr_cdgrupo_historico IN tbcc_grupo_historico.cdgrupo_historico%TYPE) IS
        SELECT 1
          FROM tbcc_grupo_historico his
         WHERE his.cdgrupo_historico = pr_cdgrupo_historico;
      rw_grupo_historico cr_grupo_historico%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      -- Busca grupo de historico
      OPEN cr_grupo_historico(pr_cdgrupo_historico => pr_cdgrupo_historico);
      FETCH cr_grupo_historico INTO rw_grupo_historico;
      
      IF cr_grupo_historico%FOUND THEN
        pr_flggphis := 1; -- Existe
      ELSE
        pr_flggphis := 0; -- Não Existe
      END IF;
      
      CLOSE cr_grupo_historico;
      
      pr_des_erro := 'OK';
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina pc_valida_grupo_historico: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_valida_grupo_historico;
  
  PROCEDURE pc_descricao_grupo_historico(pr_cdgrupo_historico  IN tbcc_grupo_historico.cdgrupo_historico%TYPE --> codigo do tipo de conta
                                        ,pr_dsgrupo_historico OUT tbcc_grupo_historico.dsgrupo_historico%TYPE --> descricao do tipo de conta
                                        ,pr_des_erro          OUT VARCHAR2 --> Código da crítica
                                        ,pr_dscritic          OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_descricao_grupo_historico
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Janeiro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar descricao do grupo de historico.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Busca tipo de conta
      CURSOR cr_grupo_historico(pr_cdgrupo_historico IN tbcc_grupo_historico.cdgrupo_historico%TYPE) IS
        SELECT his.dsgrupo_historico
          FROM tbcc_grupo_historico his
         WHERE his.cdgrupo_historico = pr_cdgrupo_historico;
      rw_grupo_historico cr_grupo_historico%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      -- Busca tipo de conta
      OPEN cr_grupo_historico(pr_cdgrupo_historico  => pr_cdgrupo_historico);
      FETCH cr_grupo_historico INTO rw_grupo_historico;
      
      IF cr_grupo_historico%NOTFOUND THEN
        CLOSE cr_grupo_historico;
        vr_dscritic := 'Grupo de histórico não encontrado.';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_grupo_historico;
      
      -- Retorna descricao do tipo de conta
      pr_dsgrupo_historico := rw_grupo_historico.dsgrupo_historico;
      pr_des_erro := 'OK';
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral na rotina pc_descricao_grupo_historico: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_descricao_grupo_historico;
  
  /*****************************************************************************/
  /**                   Procedure valida novo tipo de conta                   **/
  /*****************************************************************************/

  PROCEDURE pc_verifica_tipo_acesso(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                   ,pr_cdsitdct IN crapass.cdsitdct%TYPE --> Situacao
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE --> Codigo do operador
                                   ,pr_flacesso OUT INTEGER
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao Erro  
    /* .............................................................................
    
        Programa: pc_verifica_tipo_acesso
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Janeiro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para transferir tipo de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_possuipr  VARCHAR2(1);
      
      --Variaveis auxiliares
      vr_vlcontra NUMBER;
      
      -- Busca pelos produtos do tipo de conta origem
      CURSOR cr_situacao (pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_cdsitdct IN crapass.cdsitdct%TYPE)IS
        SELECT sit.tpacesso
          FROM tbcc_situacao_conta_coop sit
         WHERE sit.cdcooper = pr_cdcooper
           AND sit.cdsituacao = pr_cdsitdct;
      rw_situacao cr_situacao%ROWTYPE;
      
      CURSOR cr_crapace (pr_cdcooper IN crapace.cdcooper%TYPE
                        ,pr_cdoperad IN crapace.cdoperad%TYPE) IS
        SELECT *
          FROM crapace ace
         WHERE ace.cdcooper        = pr_cdcooper
           AND UPPER(ace.cdoperad) = UPPER(pr_cdoperad)
           AND UPPER(ace.nmdatela) = 'SITCTA' -- SITUAÇÕES DE CONTAS
           AND UPPER(ace.cddopcao) = 'X';     -- Acesso Especial
      rw_crapace cr_crapace%ROWTYPE;
      
    BEGIN
      
      OPEN cr_situacao (pr_cdcooper => pr_cdcooper
                       ,pr_cdsitdct => pr_cdsitdct);
      FETCH cr_situacao INTO rw_situacao;
      
      IF cr_situacao%NOTFOUND THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Situacao n&atilde;o encontrado.';
      ELSE
        IF rw_situacao.tpacesso = 1 THEN
          pr_flacesso := 1;
        ELSIF rw_situacao.tpacesso = 2 THEN
          OPEN cr_crapace (pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad);
          FETCH cr_crapace INTO rw_crapace;
          
          IF cr_crapace%FOUND THEN
            pr_flacesso := 1;
          ELSE
            pr_flacesso := 1;
            pr_cdcritic := 0;
            pr_dscritic := 'Operador sem permiss&atilde;o de utiliza&ccedil;&atilde;o desta Situa&ccedil;&atilde;o de Conta.';
          END IF;
        ELSIF rw_situacao.tpacesso = 3 THEN
          pr_flacesso := 0;
          pr_cdcritic := 0;
          pr_dscritic := 'Situa&ccedil;&atilde;o de Conta liberada apenas para uso do sistema.';
        END IF;
      END IF;
      
      CLOSE cr_situacao;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_valida_novo_tipo: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_verifica_tipo_acesso;
  
END CADA0006;
/
