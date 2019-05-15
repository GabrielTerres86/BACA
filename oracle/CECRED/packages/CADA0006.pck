CREATE OR REPLACE PACKAGE CECRED.CADA0006 is
 /* ---------------------------------------------------------------------------------------------------------------
  
    Programa : CADA0006
    Sistema  : Rotinas para detalhes de cadastros
    Sigla    : CADA
    Autor    : Lombardi
    Data     : Janeiro/2018.                   Ultima atualizacao: 01/10/2018
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Rotinas para buscar detalhes de cadastros
  
   Alteracoes: 08/09/2018 - Considerar apenas a contratação da Aplicação Programada, não somando com aplicações 
                            anteriores (pc_valida_valor_de_adesao)
                            Proj. 411.2 (CIS Corporate)   
  
               01/10/2018 - Possibilitar a alteração do dia da contratação, valor e finalidade de aplicações programadas
                            Proj. 411.2 (CIS Corporate)   

  ---------------------------------------------------------------------------------------------------------------*/
  
  -- Validar transferencia de contas entre tipos de conta
  PROCEDURE pc_valida_transferencia(pr_inpessoa   IN INTEGER --> Tipo de pessoa
                                   ,pr_cdcooper   IN INTEGER --> Código da cooperativa
                                   ,pr_tipcta_ori IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo tipo de conta de origem
                                   ,pr_tipcta_des IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo tipo de conta de destino
                                   ,pr_cdoperad   IN VARCHAR2    --> Código do operador que solicitou a transferencia
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
                                   
  -- Verificar se a situacao de conta permite o produto
  PROCEDURE pc_permite_produto_situacao(pr_cdprodut  IN tbcc_produto.cdproduto%TYPE --> Codigo do produto
                                        ,pr_cdcooper  IN tbcc_situacao_conta_coop.cdcooper%TYPE --> Código da cooperativa
                                       ,pr_cdsitdct  IN tbcc_situacao_conta_coop.cdsituacao%TYPE --> Codigo da situacao
                                       ,pr_possuipr OUT VARCHAR2 --> possui produto
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao Erro  
  
  -- Verificar se o tipo de conta permite lista de produtos
  PROCEDURE pc_permite_lista_prod_tipo(pr_lsprodut  IN VARCHAR2 --> Codigo do produto
                                      ,pr_cdtipcta  IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo do produto
                                      ,pr_cdcooper  IN INTEGER --> Código da cooperativa
                                      ,pr_inpessoa  IN INTEGER --> Tipo de pessoa
                                      ,pr_possuipr OUT VARCHAR2 --> possui produto
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao Erro  
                                      
  PROCEDURE pc_busca_valor_contratado(pr_cdcooper  IN INTEGER --> Código da cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                                     ,pr_cdprodut  IN tbcc_produto.cdproduto%TYPE --> Codigo do produto
                                     ,pr_cddchave  IN INTEGER --> Cod. chave
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
                                   
  PROCEDURE pc_descricao_situacao_conta(pr_cdsituacao  IN tbcc_situacao_conta.cdsituacao%TYPE --> codigo da situacao de conta
                                       ,pr_dssituacao OUT tbcc_situacao_conta.dssituacao%TYPE --> descricao da situacao de conta
                                       ,pr_des_erro   OUT VARCHAR2 --> Código da crítica
                                       ,pr_dscritic   OUT VARCHAR2); --> Descrição da crítica
  
  PROCEDURE pc_busca_modalidade_tipo(pr_inpessoa           IN tbcc_tipo_conta.inpessoa%TYPE --> tipo de pessoa
                                    ,pr_cdtipo_conta       IN tbcc_tipo_conta.cdtipo_conta%TYPE --> codigo do tipo de conta
                                    ,pr_cdmodalidade_tipo OUT INTEGER --> descricao do tipo de conta
                                    ,pr_des_erro          OUT VARCHAR2 --> Código da crítica
                                    ,pr_dscritic          OUT VARCHAR2); --> Descrição da crítica
                                   
  PROCEDURE pc_busca_modalidade_conta(pr_cdcooper          IN crapass.cdcooper%TYPE --> codigo da coperativa
                                     ,pr_nrdconta          IN crapass.nrdconta%TYPE --> codigo do tipo de conta
                                     ,pr_cdmodalidade_tipo OUT INTEGER --> codigo da modalide da conta
                                     ,pr_des_erro          OUT VARCHAR2 --> Código da crítica
                                     ,pr_dscritic          OUT VARCHAR2); --> Descrição da crítica  
  
  PROCEDURE pc_busca_modalidade_web(pr_cdcooper IN crapass.cdcooper%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);
                                   
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
                                    
  PROCEDURE pc_busca_tipo_conta(pr_cdtipcta      IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo do produto
                               ,pr_cdcooper      IN INTEGER --> Código da cooperativa
                               ,pr_inpessoa      IN INTEGER --> Tipo de pessoa
                               ,pr_existe_tpcta OUT INTEGER --> possui produto
                               ,pr_cdcritic     OUT crapcri.cdcritic%TYPE --> Codigo Erro
                               ,pr_dscritic     OUT crapcri.dscritic%TYPE); --> Descricao Erro  
                               
  PROCEDURE pc_lista_tipo_conta_itg(pr_indconta_itg  IN tbcc_tipo_conta.indconta_itg%TYPE --> flag conta integração
                                   ,pr_cdmodalidade  IN tbcc_tipo_conta.cdmodalidade_tipo%TYPE --> modalidade
                                   ,pr_tiposconta   OUT CLOB --> tipos de conta
                                   ,pr_des_erro     OUT VARCHAR2 --> Código da crítica
                                   ,pr_dscritic     OUT VARCHAR2); --> Descrição da crítica
                                    
  PROCEDURE pc_ind_impede_credito(pr_cdcooper  IN crapass.cdcooper%TYPE --> Código da cooperativa
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Código da conta
                                 ,pr_inimpede_credito OUT tbcc_situacao_conta_coop.inimpede_credito%TYPE --> indicador de impedimento
                                 ,pr_des_erro OUT VARCHAR2 --> Código da crítica                             de operacao de credito.
                                 ,pr_dscritic OUT VARCHAR2); --> Descrição da crítica
                                 
  PROCEDURE pc_ind_impede_talonario(pr_cdcooper  IN crapass.cdcooper%TYPE --> Código da cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Código da conta
                                   ,pr_inimpede_talionario OUT tbcc_situacao_conta_coop.inimpede_talionario%TYPE --> indicador de impedimento
                                   ,pr_des_erro OUT VARCHAR2 --> Código da crítica                                   para retirada de talionarios
                                   ,pr_dscritic OUT VARCHAR2); --> Descrição da crítica
                                   
  PROCEDURE pr_ind_contratacao_produto(pr_cdcooper  IN crapass.cdcooper%TYPE --> Código da cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Código da conta
                                      ,pr_incontratacao_produto OUT tbcc_situacao_conta_coop.incontratacao_produto%TYPE --> indicador de impedimento para 
                                      ,pr_des_erro OUT VARCHAR2 --> Código da crítica                                       contratacao de produtos e serviços
                                      ,pr_dscritic OUT VARCHAR2); --> Descrição da crítica
                                      
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
                                   
  PROCEDURE pc_valida_adesao_produto(pr_cdcooper  IN crapass.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Situacao
                                    ,pr_cdprodut  IN tbcc_produto.cdproduto%TYPE --> Codigo do operador
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao Erro  
                                    
  PROCEDURE pc_valida_adesao_prod_web(pr_nrdconta   IN crapass.nrdconta%TYPE --> Situacao
                                     ,pr_cdprodut   IN tbcc_produto.cdproduto%TYPE --> Codigo do operador
                                     ,pr_xmllog     IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo
                                     
  PROCEDURE pc_valida_adesao_apl_prog_web (pr_nrdconta   IN crapass.nrdconta%TYPE  --> Situacao
                                          ,pr_dtmvtolt   IN VARCHAR2               --> Data de movimento
                                          ,pr_dtinirpp   IN VARCHAR2               --> Data do início da Apl. Prog.
                                          ,pr_vlprerpp   IN craprpp.vlprerpp%TYPE  --> Valor da parcela
                                          ,pr_tpemiext   IN PLS_INTEGER            --> Tipo da Impressão
                                          ,pr_xmllog     IN VARCHAR2               --> XML com informações de LOG
                                          ,pr_cdcritic   OUT PLS_INTEGER           --> Código da crítica
                                          ,pr_dscritic   OUT VARCHAR2              --> Descrição da crítica
                                          ,pr_retxml  IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                                          ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                          ,pr_des_erro   OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_valida_altera_apl_prog_web (pr_nrdconta   IN crapass.nrdconta%TYPE       --> Situacao
                                          ,pr_dtmvtolt   IN VARCHAR2                    --> Data de movimento
                                          ,pr_nrctrrpp   IN craprpp.nrctrrpp%TYPE       --> Número do Contrato - CRAPRPP
                                          ,pr_indebito   IN INTEGER                     --> Dia de débito
                                          ,pr_vlprerpp   IN craprpp.vlprerpp%TYPE       --> Valor da parcela
                                          ,pr_xmllog     IN VARCHAR2                    --> XML com informações de LOG
                                          ,pr_cdcritic   OUT PLS_INTEGER                --> Código da crítica
                                          ,pr_dscritic   OUT VARCHAR2                   --> Descrição da crítica
                                          ,pr_retxml  IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
                                          ,pr_nmdcampo   OUT VARCHAR2                   --> Nome do campo com erro
                                          ,pr_des_erro   OUT VARCHAR2);                 --> Erros do processo
                                    
  PROCEDURE pc_valida_valor_adesao(pr_cdcooper  IN crapass.cdcooper%TYPE --> Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Situacao
                                  ,pr_cdprodut  IN tbcc_produto.cdproduto%TYPE --> Codigo do operador
                                  ,pr_vlcontra  IN VARCHAR2               --> Valor contratado
                                  ,pr_idorigem  IN INTEGER               --> ID origem
                                  ,pr_solcoord OUT INTEGER               --> Solicita senha coordenador
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao Erro
  
  PROCEDURE pc_valida_valor_de_adesao(pr_cdcooper  IN crapass.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Situacao
                                     ,pr_cdprodut  IN tbcc_produto.cdproduto%TYPE --> Codigo do operador
                                     ,pr_vlcontra  IN VARCHAR2               --> Valor contratado
                                     ,pr_idorigem  IN INTEGER               --> ID origem
                                     ,pr_cddchave  IN INTEGER               --> Cod. chave
                                     ,pr_solcoord OUT INTEGER               --> Solicita senha coordenador
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao Erro
                                     
  PROCEDURE pc_valida_valor_adesao_empr(pr_nrdconta  IN crapass.nrdconta%TYPE --> Situacao
                                       ,pr_vlcontra  IN VARCHAR2               --> Valor contratado
                                       ,pr_dsctrliq  IN VARCHAR2              --> Contratos liquidados
                                       ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro  OUT VARCHAR2); --> Erros do processo
                                        
  PROCEDURE pc_valida_valor_adesao_web(pr_nrdconta   IN crapass.nrdconta%TYPE --> Situacao
                                      ,pr_cdprodut   IN tbcc_produto.cdproduto%TYPE --> Codigo do operador
                                      ,pr_vlcontra   IN VARCHAR2               --> Valor contratado
                                      ,pr_cddchave   IN INTEGER               --> Cod. chave
                                      ,pr_xmllog     IN VARCHAR2 --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                      ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

  /*****************************************************************************/
  /**            Procedure para gravar tabela de historico de conta           **/
  /*****************************************************************************/
  PROCEDURE pc_grava_dados_hist(pr_nmtabela    IN tbcc_campo_historico.nmtabela_oracle%TYPE  --> Nome da tela                              
                               ,pr_nmdcampo    IN tbcc_campo_historico.nmcampo%TYPE          --> Nome do campo
                               ,pr_cdcooper    IN tbcc_conta_historico.cdcooper%TYPE     DEFAULT 0 --> Cooperativa
                               ,pr_nrdconta    IN tbcc_conta_historico.nrdconta%TYPE     DEFAULT 0 --> Número da conta
                               ,pr_inpessoa    IN tbcc_conta_historico.inpessoa%TYPE     DEFAULT 0 --> Tipo de pessoa
                               ,pr_idseqttl    IN tbcc_conta_historico.idseqttl%TYPE     DEFAULT 0 --> Sequencia do titular
                               ,pr_cdtipcta    IN tbcc_conta_historico.cdtipo_conta%TYPE DEFAULT NULL --> Código do tipo de conta
                               ,pr_cdsituac    IN tbcc_conta_historico.cdsituacao%TYPE   DEFAULT NULL --> Código da situação
                               ,pr_cdprodut    IN tbcc_produtos_coop.cdproduto%TYPE      DEFAULT NULL --> Código do produto
                               ,pr_tpoperac    IN tbcc_conta_historico.tpoperacao%TYPE       --> Tipo de operacao (1-Inclusao/ 2-Alteracao/ 3-Exclusao)
                               ,pr_dsvalant    IN tbcc_conta_historico.dsvalor_anterior%TYPE --> Valor anterior
                               ,pr_dsvalnov    IN tbcc_conta_historico.dsvalor_novo%TYPE     --> Valor novo
                               ,pr_cdoperad    IN tbcc_conta_historico.cdoperad_altera%TYPE  --> Código do operador da ação
                               ,pr_dscritic   OUT VARCHAR2);                                 --> Retornar Critica 

  --> Procedure para retornar as opçoes do dominio para o Ayllos WEB.
  PROCEDURE pc_lista_situacoes_conta_web(pr_xmllog   IN VARCHAR2             --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER         --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2            --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2            --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2);          --> Erros do processo

  PROCEDURE pc_valor_min_capital(pr_cdcooper          IN tbcc_tipo_conta_coop.cdcooper%TYPE --> codigo da cooperativa
                                ,pr_inpessoa          IN tbcc_tipo_conta_coop.inpessoa%TYPE --> tipo de pessoa
                                ,pr_cdtipo_conta      IN tbcc_tipo_conta_coop.cdtipo_conta%TYPE --> codigo do tipo de conta
                                ,pr_vlminimo_capital OUT tbcc_tipo_conta_coop.vlminimo_capital%TYPE --> valor minimo de capital
                                ,pr_des_erro         OUT VARCHAR2 --> Código da crítica
                                ,pr_dscritic         OUT VARCHAR2); --> Descrição da crítica
  
  PROCEDURE pc_verifica_lib_blq_pre_aprov(pr_cdcooper  IN tbcc_situacao_conta_coop.cdcooper%TYPE --> codigo da cooperativa
                                         ,pr_nrdconta  IN tbepr_param_conta.nrdconta%TYPE --> Numero da conta
                                         ,pr_cdsitdct  IN tbcc_situacao_conta_coop.cdsituacao%TYPE --> codigo da situacao
                                         ,pr_des_erro OUT VARCHAR2 --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2); --> Descrição da crítica
                                         
                                       
END CADA0006;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CADA0006 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0006
  --  Sistema  : Rotinas para detalhes de cadastros
  --  Sigla    : CADA
  --  Autor    : Lombardi
  --  Data     : Janeiro/2018.                   Ultima atualizacao: 08/09/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para manutenção de tipos de conta
  --
  -- Alteracoes: 08/09/2018 - Considerar apenas a contratação da Aplicação Programada, não somando com aplicações 
  --                          anteriores (pc_valida_valor_de_adesao)
  --                          Proj. 411.2 (CIS Corporate)   
  --  
  ---------------------------------------------------------------------------------------------------------------
  
  /*****************************************************************************/
  /**                      Procedure valida transferencia                     **/
  /*****************************************************************************/
  
  PROCEDURE pc_valida_transferencia(pr_inpessoa   IN INTEGER --> Tipo de pessoa
                                   ,pr_cdcooper   IN INTEGER --> Código da cooperativa
                                   ,pr_tipcta_ori IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo tipo de conta de origem
                                   ,pr_tipcta_des IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo tipo de conta de destino
                                   ,pr_cdoperad   IN VARCHAR2    --> Código do operador que solicitou a transferencia
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
    
        Alteracoes: 09/04/2018 - Incluir a geração de histórico na transferencia de tipo
		                         de conta. (Renato Darosci - Supero)
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
        
        -- Se validou o novo tipo, deve gerar histórico
        CADA0006.pc_grava_dados_hist(pr_nmtabela => 'CRAPASS'
                                    ,pr_nmdcampo => 'CDTIPCTA'
                                    ,pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_idseqttl => 1 -- Colocar como titular
                                    ,pr_tpoperac => 2 -- Alteração
                                    ,pr_dsvalant => pr_tipcta_ori -- Tipo de conta atual
                                    ,pr_dsvalnov => pr_tipcta_des -- Novo tipo de conta
                                    ,pr_cdoperad => pr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
        -- Se ocorrer algum erro
        IF vr_dscritic IS NOT NULL THEN
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
    
        Objetivo  : Rotina para verificar se as contas atendem aos requisitos do tipo de conta destino.
    
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
              ,pro.idfaixa_valor
              ,pro.dsproduto
          FROM tbcc_produto pro
              ,tbcc_produtos_coop prc
         WHERE prc.cdproduto = pro.cdproduto
           AND prc.cdcooper = pr_cdcooper
           AND prc.tpconta = pr_cdtipcta
           AND prc.inpessoa = pr_inpessoa;
      
      -- Buscar a configuração do produto na conta destino
      CURSOR cr_proddest(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_cdtipcta IN crapass.cdtipcta%TYPE
                        ,pr_inpessoa IN crapass.inpessoa%TYPE
                        ,pr_cdprodut IN tbcc_produto.cdproduto%TYPE) IS
        SELECT prc.vlminimo_adesao
             , prc.vlmaximo_adesao
          FROM tbcc_produtos_coop prc
         WHERE prc.cdcooper  = pr_cdcooper
           AND prc.tpconta   = pr_cdtipcta
           AND prc.inpessoa  = pr_inpessoa
           AND prc.cdproduto = pr_cdprodut;
      rw_proddest   cr_proddest%ROWTYPE;
      
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
            vr_dscritic := 'Conta ' || gene0002.fn_mask_conta(pr_nrdconta) || ' nao atende aos requisitos do tipo de conta destino ('||rw_produtos.dsproduto||').';
            RAISE vr_exc_saida;
          END IF;
          
          IF rw_produtos.idfaixa_valor = 1 THEN
          
            -- Buscar valor contratado
            pc_busca_valor_contratado(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_cdprodut => rw_produtos.cdproduto
                                     ,pr_cddchave => 0
                                     ,pr_vlcontra => vr_vlcontra
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
            -- Se ocorrer algum erro
            IF vr_cdcritic > 0 AND vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          
            -- Buscar o valor minimo e maximo para o produto no tipo de conta destino
            OPEN  cr_proddest(pr_cdcooper => pr_cdcooper
                             ,pr_cdtipcta => pr_tipcta_des
                             ,pr_inpessoa => pr_inpessoa
                             ,pr_cdprodut => rw_produtos.cdproduto);
            FETCH cr_proddest INTO rw_proddest;
            CLOSE cr_proddest;
            
            -- Verifica se o valor contratado para o produto está de acordo
            IF vr_vlcontra IS NOT NULL AND
              (vr_vlcontra < rw_proddest.vlminimo_adesao OR
               vr_vlcontra > rw_proddest.vlmaximo_adesao) THEN
              vr_dscritic := 'Conta ' || gene0002.fn_mask_conta(pr_nrdconta) || ' nao atende aos requisitos do tipo de conta destino ('||rw_produtos.dsproduto||').';
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
                        ,pr_cdprodut IN tbcc_produto.cdproduto%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE)IS
        SELECT prd.idfaixa_valor
              ,prc.vlminimo_adesao
              ,prc.vlmaximo_adesao
          FROM tbcc_produtos_coop prc
              ,tbcc_produto       prd
         WHERE prc.cdcooper = pr_cdcooper
           AND prc.tpconta = pr_cdtipcta
           AND prc.cdproduto = pr_cdprodut
           AND prc.inpessoa = pr_inpessoa
           AND prc.cdproduto = prd.cdproduto
           AND (prc.dtvigencia IS NULL 
            OR prc.dtvigencia >= pr_dtmvtolt);
      rw_produto cr_produto%ROWTYPE;
      
      -- Registro sobre a tabela de datas
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
    BEGIN
      
      
      -- Busca a data do sistema
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      
      -- Verifica se existe o produto para o tipo de conta
      OPEN cr_produto(pr_cdcooper => pr_cdcooper
                     ,pr_cdtipcta => pr_cdtipcta
                     ,pr_inpessoa => pr_inpessoa
                     ,pr_cdprodut => pr_cdprodut
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
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
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina pc_permite_produto_tipo: ' || SQLERRM;
    END;
  END pc_permite_produto_tipo;
  
  /*****************************************************************************/
  /**               Procedure permite produto situacao de conta               **/
  /*****************************************************************************/
  
  PROCEDURE pc_permite_produto_situacao(pr_cdprodut  IN tbcc_produto.cdproduto%TYPE --> Codigo do produto
                                        ,pr_cdcooper  IN tbcc_situacao_conta_coop.cdcooper%TYPE --> Código da cooperativa
                                        ,pr_cdsitdct  IN tbcc_situacao_conta_coop.cdsituacao%TYPE --> Codigo da situacao
                                        ,pr_possuipr OUT VARCHAR2 --> possui produto
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao Erro  
    /* .............................................................................
    
        Programa: pc_permite_produto_situacao
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Janeiro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para verificar se a situacao de conta permite o produto
    
        Observacao: -----
    
        Alteracoes: 29/06/2018 - Quando o produto for 41 - Resgate de aplicação, não 
                                 deve ser validada a situação da conta, conforme SM 
                                 aprovada em 29/06/2018.  (Renato Darosci - Supero)
    ..............................................................................*/
  BEGIN
    DECLARE
      
      -- Variaveis auxiliares
      vr_inconprd INTEGER;
      vr_inimpcre INTEGER;
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Verifica se existe o produto para o tipo de conta
      CURSOR cr_situacao(pr_cdcooper IN tbcc_situacao_conta_coop.cdcooper%TYPE
                        ,pr_cdsitdct IN tbcc_situacao_conta_coop.cdsituacao%TYPE)IS
        SELECT sit.incontratacao_produto inconprd
              ,sit.inimpede_credito      inimpcre
          FROM tbcc_situacao_conta_coop sit
         WHERE sit.cdcooper = pr_cdcooper
           AND sit.cdsituacao = pr_cdsitdct;
      rw_situacao cr_situacao%ROWTYPE;
      
    BEGIN
      
      pr_possuipr := 'S';
      
      -- Verifica se existe o produto para o tipo de conta
      OPEN cr_situacao(pr_cdcooper => pr_cdcooper
                      ,pr_cdsitdct => pr_cdsitdct);
      FETCH cr_situacao INTO rw_situacao;
      
      -- se existir
      IF cr_situacao%FOUND THEN
        vr_inconprd := rw_situacao.inconprd;
        vr_inimpcre := rw_situacao.inimpcre;
      ELSE
        vr_dscritic := 'Situacao nao encontrada.'; -- Não permite produto
        RAISE vr_exc_saida;
      END IF;
      
      CLOSE cr_situacao;
      
      -- Quando o produto for 41 - Resgate de aplicação, não deve ser validada
      -- a situação da conta, conforme SM aprovada em 29/06/2018. 
      IF pr_cdprodut <> 41 THEN
      
        IF vr_inconprd = 1 OR
          (vr_inconprd = 2 AND pr_cdprodut <> 6) THEN -- Cobrança Bancária
          pr_possuipr := 'N';
          vr_dscritic := 'Situacao de Conta nao permite adesao ao produto.';
          RAISE vr_exc_saida;
        END IF;
        
      END IF;
      
      IF vr_inimpcre = 1 AND 
         pr_cdprodut IN (4  -- CARTÃO DE CRÉDITO
                        ,13 -- LIMITE DE CRÉDITO
                        ,21 -- CARTÃO CRÉDITO CECRED
                        ,24 -- CARTÃO CREDITO EMPRESARIAL
                        ,25 -- PRE APROVADO
                        ,31 -- EMPRÉSTIMOS 
                        ,34 -- BORDERO DE CHEQUES
                        ,35 -- BORDEROS DE TÍTULOS
                        ,36 -- LIMITE DE DESCONTO DE CHEQUE
                        ,37 -- LIMITE DE DESCONTO DE TITULO
                        ) THEN
        pr_possuipr := 'N';
        vr_dscritic := 'Situacao de Conta nao permite produtos de credito.';
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
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina pc_permite_produto_situacao: ' || SQLERRM;
    END;
  END pc_permite_produto_situacao;
  
  /*****************************************************************************/
  /**                 Procedure permite produto tipo de conta                 **/
  /*****************************************************************************/
  
  PROCEDURE pc_permite_lista_prod_tipo(pr_lsprodut  IN VARCHAR2 --> Codigo do produto
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
    
        Objetivo  : Rotina para verificar se o tipo de conta permite lista de produtos
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
      
      vr_possuipr VARCHAR2(100); --> possui produto
      
      vr_tab_cdprodut  gene0002.typ_split;
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
    BEGIN
      
      vr_tab_cdprodut := gene0002.fn_quebra_string(pr_lsprodut,',');
      IF vr_tab_cdprodut.count() = 0 THEN
        vr_dscritic := 'Codigo do produto deve ser informado.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica tipo de pessoa
      IF pr_cdtipcta = 0 THEN
        vr_dscritic := 'Tipo de conta inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica tipo de pessoa
      IF pr_inpessoa = 0 THEN
        vr_dscritic := 'Tipo de pessoa inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica se permite cada produto
      FOR idx IN vr_tab_cdprodut.first..vr_tab_cdprodut.last LOOP
        
        pc_permite_produto_tipo(pr_cdprodut => to_number(vr_tab_cdprodut(idx))
                               ,pr_cdtipcta => pr_cdtipcta	
                               ,pr_cdcooper => pr_cdcooper
                               ,pr_inpessoa => pr_inpessoa
                               ,pr_possuipr => vr_possuipr
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
        
        IF vr_cdcritic > 0 OR vr_dscritic IS not NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        IF pr_possuipr IS NOT NULL THEN
          pr_possuipr := pr_possuipr || ',';
        END IF;
      
        pr_possuipr := pr_possuipr || vr_possuipr;
        
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
        pr_dscritic := 'Erro geral na rotina pc_permite_lista_prod_tipo: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_permite_lista_prod_tipo;
  
  /*****************************************************************************/
  /**                    Procedure busca valor contratado                     **/
  /*****************************************************************************/
  
  PROCEDURE pc_busca_valor_contratado(pr_cdcooper  IN INTEGER --> Código da cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                                     ,pr_cdprodut  IN tbcc_produto.cdproduto%TYPE --> Codigo do produto
                                     ,pr_cddchave  IN INTEGER --> Cod. chave
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
      vr_des_erro VARCHAR2(1000); --> Desc. Erro
      
      -- Variáveis geral 
      vr_vlcontra  NUMBER;
      vr_vlsdeved NUMBER := 0;
      vr_qtprecal crapepr.qtprecal%TYPE;
      vr_dstextab VARCHAR2(1000);
      vr_inusatab BOOLEAN;
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- buscar os limites contratados de cartão de crédito
      CURSOR cr_crawcrd (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
        SELECT nvl(SUM(vllimitg), 0)
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
        SELECT nvl(SUM(vllimitg), 0)
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
        SELECT nvl(vldcotas, 0)
          FROM crapcot t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta;
      
      -- Cursor sobre a tabela de associados
      CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT vllimcre,
               decode(inpessoa,1,'F','J') tppessoa,
               nrcpfcgc,
               dtentqst,
               inpessoa
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Cursor sobre o cadatro de senhas
      CURSOR cr_crapsnh(pr_tpdsenha crapsnh.tpdsenha%TYPE) IS
        SELECT NVL(GREATEST(snh.vllimweb,
                            snh.vllimted,
                            snh.vllimvrb,
                            snh.vllimtrf,
                            snh.vllimpgo), 0)
          FROM crapsnh snh,
               crapass ass
         WHERE snh.cdcooper = pr_cdcooper
           AND snh.nrdconta = pr_nrdconta
           AND snh.cdcooper = ass.cdcooper
           AND snh.nrdconta = ass.nrdconta
           AND snh.tpdsenha = pr_tpdsenha
           AND snh.cdsitsnh = 1  -- Ativa
           AND ((ass.idastcjt = 0 AND snh.idseqttl = DECODE(pr_tpdsenha,2,0,1))
            OR ass.idastcjt = 1
            ); 
      
      -- buscar o valor de Planos de cotas contratados
      CURSOR cr_crappla (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
        SELECT nvl(sum(vlprepla), 0)
          FROM crappla
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND cdsitpla = 1;
      
      -- buscar o valor das parcelas de poupança programada contratadas
      CURSOR cr_craprpp (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_nrctrrpp IN INTEGER)IS
        SELECT nvl(sum(vlprerpp), 0)
          FROM craprpp
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrrpp <> pr_nrctrrpp
           AND cdsitrpp NOT IN (3, 5);
      
      -- Buscar o valor de aplicações
      CURSOR cr_crapaar (pr_cdcooper IN crapaar.cdcooper%TYPE
                        ,pr_nrdconta IN crapaar.nrdconta%TYPE) IS
        SELECT nvl(SUM(vlaplica), 0)
          FROM (SELECT SUM(vlaplica) vlaplica
                  FROM craprda 
                 WHERE cdcooper = pr_cdcooper
                   AND nrdconta = pr_nrdconta
                   AND insaqtot = 0
                UNION ALL
                SELECT SUM(vlparaar)
                  FROM crapaar 
                 WHERE cdcooper = pr_cdcooper
                   AND nrdconta = pr_nrdconta
                   AND flgtipar = 0 -- Apenas aplicações
                   AND cdsitaar <> 3);
          
      -- buscar o valor dos borderôs de cheque contratados
      CURSOR cr_crapbdc (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
        SELECT nvl(sum(crapcdb.vlcheque), 0)
          FROM crapcdb
             , crapbdc
         WHERE crapcdb.cdcooper = crapbdc.cdcooper
           AND crapcdb.nrdconta = crapbdc.nrdconta
           AND crapcdb.nrborder = crapbdc.nrborder
           AND crapcdb.nrctrlim = crapbdc.nrctrlim
           AND crapbdc.cdcooper = pr_cdcooper 
           AND crapbdc.nrdconta = pr_nrdconta
           AND crapbdc.insitbdc = 3;
          
      -- buscar o valor dos borderôs de cheque contratados
      CURSOR cr_crapbdt (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
        SELECT nvl(sum(craptdb.vltitulo), 0)
          FROM craptdb
             , crapbdt
         WHERE craptdb.cdcooper = crapbdt.cdcooper
           AND craptdb.nrdconta = crapbdt.nrdconta
           AND craptdb.nrborder = crapbdt.nrborder
           AND craptdb.nrctrlim = crapbdt.nrctrlim
           AND crapbdt.cdcooper = pr_cdcooper 
           AND crapbdt.nrdconta = pr_nrdconta
           AND crapbdt.insitbdt = 3;
          
      -- buscar o limite de borderôs de cheque contratados
      CURSOR cr_craplim_c (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
        SELECT nvl(SUM(craplim.vllimite), 0)
          FROM craplim
         WHERE craplim.cdcooper = pr_cdcooper
           AND craplim.nrdconta = pr_nrdconta
           AND craplim.tpctrlim = 2  -- CHEQUE
           AND craplim.insitlim = 2; -- Ativo
          
      -- buscar o limite de borderôs de títulos contratados
      CURSOR cr_craplim_t (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
        SELECT nvl(SUM(craplim.vllimite), 0)
          FROM craplim
         WHERE craplim.cdcooper = pr_cdcooper
           AND craplim.nrdconta = pr_nrdconta
           AND craplim.tpctrlim = 3  -- TITULOS
           AND craplim.insitlim = 2; -- Ativo
      
      -- Buscar empréstimos não liquidados
      CURSOR cr_crapepr (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT t.nrctremp
          FROM crapepr t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta
           AND t.inliquid = 0
           AND t.inprejuz = 0;
           
    BEGIN
      
      pr_vlcontra := 0;
      
      IF pr_cdprodut = 3  THEN -- APLICAÇÃO
        
        -- Buscar valor total contratado
        OPEN  cr_crapaar(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapaar INTO pr_vlcontra;
        CLOSE cr_crapaar;
        
      ELSIF pr_cdprodut = 4 OR pr_cdprodut = 24 THEN -- Cartao de credito BB e cartao CRED empresarial
        -- buscar os limites contratados de cartão de crédito BB e cartão de crédito empresarial
        OPEN  cr_crawcrd_bb(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crawcrd_bb INTO pr_vlcontra;
        CLOSE cr_crawcrd_bb;
        
      ELSIF pr_cdprodut = 12 THEN -- Integralização de capital
      
        -- buscar valor referente a integralização de capital
        OPEN  cr_crapcot(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapcot INTO pr_vlcontra;
        CLOSE cr_crapcot;
      
      ELSIF pr_cdprodut = 13 THEN -- Limite de crédito
        -- Abre a tabela de associados
        OPEN  cr_crapass(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;
        
        pr_vlcontra := nvl(rw_crapass.vllimcre,0);
      
      ELSIF pr_cdprodut = 14 THEN -- Limites Internet
        -- Abre a tabela de senhas para ver se o usuario tem internet liberada
        OPEN  cr_crapsnh(1); -- Internet
        FETCH cr_crapsnh INTO pr_vlcontra;
        CLOSE cr_crapsnh;
      
      ELSIF pr_cdprodut = 15 THEN -- Planos de Cotas
        -- buscar o valor de Planos de cotas contratados
        OPEN  cr_crappla(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crappla INTO pr_vlcontra;
        CLOSE cr_crappla;
      
      ELSIF pr_cdprodut = 16 THEN -- Poupança Programada
        -- buscar o valor das parcelas de poupança programada contratadas
        OPEN cr_craprpp(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctrrpp => pr_cddchave);
        FETCH cr_craprpp INTO pr_vlcontra;
        CLOSE cr_craprpp;
      
      ELSIF pr_cdprodut = 21 THEN -- Cartao credito CECRED
        -- buscar os limites contratados de cartão de crédito
        OPEN cr_crawcrd(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crawcrd INTO pr_vlcontra;
        CLOSE cr_crawcrd;
      
      ELSIF pr_cdprodut = 31 THEN -- Empréstimo e Financiamento
        
        -- Buscar registros da DAT
        OPEN  btch0001.cr_crapdat(pr_cdcooper);
        FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
        CLOSE btch0001.cr_crapdat;
        
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
          IF SUBSTR(vr_dstextab,1,1) = '0' THEN
            --Nao usa tabela
            vr_inusatab:= FALSE;
          ELSE
            --Nao usa tabela
            vr_inusatab:= TRUE;
          END IF;
        END IF;
        
        -- Buscar contratos de emprestimos nao liquidados 
        FOR rw_crapepr IN cr_crapepr (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta) LOOP
          -- Buscar o saldo devedor
          EMPR0001.pc_calc_saldo_epr(pr_cdcooper   => pr_cdcooper         --> Codigo da Cooperativa
                                    ,pr_rw_crapdat => btch0001.rw_crapdat --> Vetor com dados de parametro (CRAPDAT)
                                    ,pr_cdprogra   => 'CADA0006'          --> Programa que solicitou o calculo
                                    ,pr_nrdconta   => pr_nrdconta         --> Numero da conta do emprestimo
                                    ,pr_nrctremp   => rw_crapepr.nrctremp --> Numero do contrato do emprestimo
                                    ,pr_inusatab   => vr_inusatab         --> Indicador de utilizacão da tabela de juros
                                    ,pr_vlsdeved   => vr_vlsdeved         --> Saldo devedor do emprestimo
                                    ,pr_qtprecal   => vr_qtprecal         --> Quantidade de parcelas do emprestimo
                                    ,pr_cdcritic   => vr_cdcritic         --> Codigo de critica encontrada
                                    ,pr_des_erro   => vr_des_erro);       --> Retorno de Erro
          
          -- Se ocorreu erro, gerar critica
          IF vr_cdcritic IS NOT NULL OR vr_des_erro IS NOT NULL THEN
            -- Zerar saldo devedor
            vr_vlsdeved := 0;
            -- Gerar critica
            RAISE vr_exc_saida;
          END IF;
          
          -- Somar os saldos devedores
          vr_vlcontra := NVL(vr_vlcontra,0) + NVL(vr_vlsdeved,0);
          
        END LOOP;
        
        -- Retornar o Saldo
        pr_vlcontra := NVL(vr_vlcontra,0);
      
      ELSIF pr_cdprodut = 34 THEN -- Borderô de Cheque
        -- buscar o valor dos borderôs de cheque contratados
        OPEN cr_crapbdc(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapbdc INTO pr_vlcontra;
        CLOSE cr_crapbdc;
      
      ELSIF pr_cdprodut = 35 THEN -- Borderô de Título
        -- buscar o valor dos borderôs de titulo contratados
        OPEN cr_crapbdt(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapbdt INTO pr_vlcontra;
        CLOSE cr_crapbdt;
      
      ELSIF pr_cdprodut = 36 THEN -- Limite de desconto de cheques
        -- buscar o limite de borderôs de cheque contratados
        OPEN cr_craplim_c(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta);
        FETCH cr_craplim_c INTO pr_vlcontra;
        CLOSE cr_craplim_c;
      
      ELSIF pr_cdprodut = 37 THEN -- Limite de desconto de títulos
        -- buscar o limite de borderôs de títulos contratados
        OPEN cr_craplim_t(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta);
        FETCH cr_craplim_t INTO pr_vlcontra;
        CLOSE cr_craplim_t;
        
      ELSE 
        -- demais... retornar zero
        pr_vlcontra := 0;
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
              ,sit.dssituacao
          FROM tbcc_situacao_conta       sit
              ,tbcc_situacao_conta_coop  ctc
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
              ,ctc.vlminimo_capital
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
      
      -- Gravar Histórico
      CADA0006.pc_grava_dados_hist(pr_nmtabela => 'TBCC_TIPO_CONTA_COOP'
                                  ,pr_nmdcampo => 'VLMINIMO_CAPITAL'
                                  ,pr_cdcooper => vr_cdcooper
                                  ,pr_inpessoa => pr_inpessoa
                                  ,pr_cdtipcta => pr_tpconta
                                  ,pr_tpoperac => 3
                                  ,pr_dsvalant => rw_tipo_conta_coop.vlminimo_capital
                                  ,pr_dsvalnov => NULL
                                  ,pr_cdoperad => vr_cdoperad
                                  ,pr_dscritic => vr_dscritic);
      -- Se ocorrer erro 
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
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
  
  PROCEDURE pc_descricao_situacao_conta(pr_cdsituacao  IN tbcc_situacao_conta.cdsituacao%TYPE --> codigo da situacao de conta
                                       ,pr_dssituacao OUT tbcc_situacao_conta.dssituacao%TYPE --> descricao da situacao de conta
                                       ,pr_des_erro   OUT VARCHAR2 --> Código da crítica
                                       ,pr_dscritic   OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_descricao_situacao_conta
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Dezembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar descricao da situacao de conta.
    
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
      
      -- Busca situacao da conta
      CURSOR cr_situacao(pr_cdsituacao IN tbcc_situacao_conta.cdsituacao%TYPE) IS
        SELECT sit.dssituacao
          FROM tbcc_situacao_conta sit
         WHERE sit.cdsituacao = pr_cdsituacao;
      rw_situacao cr_situacao%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      -- Verifica tipo de conta
      IF pr_cdsituacao = 0 THEN
        vr_dscritic := 'Código da situação de conta inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca tipo de conta
      OPEN cr_situacao(pr_cdsituacao  => pr_cdsituacao);
      FETCH cr_situacao INTO rw_situacao;
      
      IF cr_situacao%NOTFOUND THEN
        CLOSE cr_situacao;
        vr_dscritic := 'Situação não encontrada.';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_situacao;
      
      -- Retorna descricao do tipo de conta
      pr_dssituacao := rw_situacao.dssituacao;
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
  END pc_descricao_situacao_conta;
  
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
  
    PROCEDURE pc_busca_modalidade_conta(pr_cdcooper          IN crapass.cdcooper%TYPE --> codigo da coperativa
                                     ,pr_nrdconta          IN crapass.nrdconta%TYPE --> codigo do tipo de conta
                                     ,pr_cdmodalidade_tipo OUT INTEGER --> codigo da modalide da conta
                                     ,pr_des_erro          OUT VARCHAR2 --> Código da crítica
                                     ,pr_dscritic          OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_busca_modalidade
        Sistema : CECRED
        Sigla   : CADA
        Autor   : Lucas Skroch - Supero
        Data    : 20/11/2018                    Ultima atualizacao: --/--/----
    
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
      CURSOR cr_tipo_conta(pr_cdcooper IN crapass.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT NVL(cta.cdmodalidade_tipo,0) cdmodalidade_tipo
          FROM crapass a,
               tbcc_tipo_conta cta
         WHERE a.inpessoa = cta.inpessoa 
           AND a.cdtipcta = cta.cdtipo_conta           
           AND a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta;
        rw_tipo_conta cr_tipo_conta%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      -- Verifica se a cooperativa eh valida
      IF pr_cdcooper = 0 THEN
        vr_dscritic := 'Código da cooperativa inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica se a conta eh valida
      IF pr_nrdconta = 0 THEN
        vr_dscritic := 'Conta inválida.';
        RAISE vr_exc_saida;
      END IF;            
      
      -- Busca tipo de conta
      OPEN cr_tipo_conta(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
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
  END pc_busca_modalidade_conta;
  
  PROCEDURE pc_busca_modalidade_web(pr_cdcooper IN crapass.cdcooper%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_buscaa_modadlidade_web
        Sistema : CECRED
        Sigla   : CADA
        Autor   : Lucas Skroch - SUpero
        Data    : Novembro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar a modalidade da conta
    
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
      vr_modalidade_conta NUMBER;
      
      -- Busca situacoes de conta
      CURSOR cr_modalidade_conta (pr_cdcooper IN crapass.cdcooper%TYPE
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
            select NVL(cta.cdmodalidade_tipo,0)
             from crapass a,
                  tbcc_tipo_conta cta
            where a.inpessoa = cta.inpessoa 
              and a.cdtipcta = cta.cdtipo_conta           
              and a.cdcooper = pr_cdcooper
              and a.nrdconta = pr_nrdconta;
      
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
  
      open cr_modalidade_conta(pr_cdcooper
                              ,pr_nrdconta);
      fetch cr_modalidade_conta into vr_modalidade_conta;
      close cr_modalidade_conta;
      
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>' || vr_modalidade_conta || '</Dados></Root>');   
      
    EXCEPTION  
      WHEN OTHERS THEN
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina CADA0006: ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_modalidade_web;
  
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
  
  PROCEDURE pc_busca_tipo_conta(pr_cdtipcta      IN tbcc_tipo_conta.cdtipo_conta%TYPE --> Codigo do produto
                               ,pr_cdcooper      IN INTEGER --> Código da cooperativa
                               ,pr_inpessoa      IN INTEGER --> Tipo de pessoa
                               ,pr_existe_tpcta OUT INTEGER --> possui produto
                               ,pr_cdcritic     OUT crapcri.cdcritic%TYPE --> Codigo Erro
                               ,pr_dscritic     OUT crapcri.dscritic%TYPE) IS --> Descricao Erro  
    /* .............................................................................
    
        Programa: pc_busca_tipo_conta
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Março/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para verificar se existe o tipo de conta
    
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
      CURSOR cr_tpconta (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_cdtipcta IN crapass.cdtipcta%TYPE
                        ,pr_inpessoa IN crapass.inpessoa%TYPE)IS
        SELECT 1
          FROM tbcc_tipo_conta tpcta
         WHERE tpcta.cdtipo_conta = pr_cdtipcta
           AND tpcta.inpessoa     = pr_inpessoa
           AND (pr_cdcooper = 0
            OR (pr_cdcooper <> 0
            AND EXISTS (SELECT 1
                          FROM tbcc_tipo_conta_coop tpcta_coop
                         WHERE tpcta_coop.cdtipo_conta = tpcta.cdtipo_conta
                           AND tpcta_coop.inpessoa     = tpcta.inpessoa
                           AND tpcta_coop.cdcooper     = pr_cdcooper)));
      rw_tpconta cr_tpconta%ROWTYPE;
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      -- Verifica tipo de pessoa
      IF pr_cdtipcta = 0 THEN
        vr_dscritic := 'Tipo de conta inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica tipo de pessoa
      IF pr_inpessoa = 0 THEN
        vr_dscritic := 'Tipo de pessoa inválido.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica se existe o tipo de conta
      OPEN cr_tpconta(pr_cdcooper => pr_cdcooper
                     ,pr_cdtipcta => pr_cdtipcta
                     ,pr_inpessoa => pr_inpessoa);
      FETCH cr_tpconta INTO rw_tpconta;
      -- se existir
      IF cr_tpconta%FOUND THEN
        pr_existe_tpcta := 1; -- Existe o tipo de conta
      ELSE
        pr_existe_tpcta := 0; -- Não existe tipo de conta
      END IF;
      
      CLOSE cr_tpconta;
      
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
        pr_dscritic := 'Erro geral na rotina da tela pc_busca_tipo_conta: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_busca_tipo_conta;
  
  PROCEDURE pc_busca_tipo_conta_itg(pr_inpessoa      IN tbcc_tipo_conta.inpessoa%TYPE --> tipo de pessoa
                                   ,pr_cdtipo_conta  IN tbcc_tipo_conta.cdtipo_conta%TYPE --> tipo de conta
                                   ,pr_indconta_itg OUT tbcc_tipo_conta.indconta_itg%TYPE --> indicador conta itg
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
  
  PROCEDURE pc_ind_impede_credito(pr_cdcooper  IN crapass.cdcooper%TYPE --> Código da cooperativa
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Código da conta
                                 ,pr_inimpede_credito OUT tbcc_situacao_conta_coop.inimpede_credito%TYPE --> indicador de impedimento
                                 ,pr_des_erro OUT VARCHAR2 --> Código da crítica                             de operacao de credito.
                                 ,pr_dscritic OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_ind_impede_credito
        Sistema : CECRED 
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Fevereiro/18.                    Ultima atualizacao: --/--/----
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para retornar o indicador de impedimento de operacao de credito.
        
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
      
      -- Busca tipo de conta TBCC_SITUACAO_CONTA_COOP
      CURSOR cr_situacao(pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT sit.inimpede_credito
          FROM tbcc_situacao_conta_coop sit
              ,crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta
           AND ass.cdcooper = sit.cdcooper
           AND ass.cdsitdct = sit.cdsituacao;
      rw_situacao cr_situacao%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      -- Busca tipo de conta
      OPEN cr_situacao(pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      FETCH cr_situacao INTO rw_situacao;
      
      IF cr_situacao%FOUND THEN
        pr_inimpede_credito := rw_situacao.inimpede_credito;
      ELSE
        vr_dscritic := 'Situação não encontrado.';
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
        pr_dscritic := 'Erro geral na rotina pc_ind_impede_credito: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_ind_impede_credito;
  
  PROCEDURE pc_ind_impede_talonario(pr_cdcooper  IN crapass.cdcooper%TYPE --> Código da cooperativa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Código da conta
                                   ,pr_inimpede_talionario OUT tbcc_situacao_conta_coop.inimpede_talionario%TYPE --> indicador de impedimento
                                   ,pr_des_erro OUT VARCHAR2 --> Código da crítica                                   para retirada de talionarios
                                   ,pr_dscritic OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_ind_impede_talonario
        Sistema : CECRED 
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Fevereiro/18.                    Ultima atualizacao: --/--/----
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para retornar o indicador de impedimento para retirada de talionarios.
        
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
      
      -- Busca tipo de conta TBCC_SITUACAO_CONTA_COOP
      CURSOR cr_situacao(pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT sit.inimpede_talionario
          FROM tbcc_situacao_conta_coop sit
              ,crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta
           AND ass.cdcooper = sit.cdcooper
           AND ass.cdsitdct = sit.cdsituacao;
      rw_situacao cr_situacao%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      -- Busca tipo de conta
      OPEN cr_situacao(pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      FETCH cr_situacao INTO rw_situacao;
      
      IF cr_situacao%FOUND THEN
        pr_inimpede_talionario := rw_situacao.inimpede_talionario;
      ELSE
        vr_dscritic := 'Situação não encontrado.';
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
        pr_dscritic := 'Erro geral na rotina pc_ind_impede_talonario: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_ind_impede_talonario;
  
  PROCEDURE pr_ind_contratacao_produto(pr_cdcooper  IN crapass.cdcooper%TYPE --> Código da cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Código da conta
                                      ,pr_incontratacao_produto OUT tbcc_situacao_conta_coop.incontratacao_produto%TYPE --> indicador de impedimento para 
                                      ,pr_des_erro OUT VARCHAR2 --> Código da crítica                                       contratacao de produtos e serviços
                                      ,pr_dscritic OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_ind_contratacao_produto
        Sistema : CECRED 
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Fevereiro/18.                    Ultima atualizacao: --/--/----
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para retornar o indicador de impedimento para contratacao de produtos 
                    e serviços (0-Nao impede/1-Todos/2-Todos exceto emissao de boletos)
        
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
      
      -- Busca tipo de conta TBCC_SITUACAO_CONTA_COOP
      CURSOR cr_situacao(pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT sit.incontratacao_produto
          FROM tbcc_situacao_conta_coop sit
              ,crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta
           AND ass.cdcooper = sit.cdcooper
           AND ass.cdsitdct = sit.cdsituacao;
      rw_situacao cr_situacao%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      -- Busca situacao de conta
      OPEN cr_situacao(pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      FETCH cr_situacao INTO rw_situacao;
      
      IF cr_situacao%FOUND THEN
        pr_incontratacao_produto := rw_situacao.incontratacao_produto;
      ELSE
        vr_dscritic := 'Situação não encontrado.';
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
        pr_dscritic := 'Erro geral na rotina pr_ind_contratacao_produto: ' || SQLERRM;
        ROLLBACK;
    END;
  END pr_ind_contratacao_produto;
  
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
        pr_dscritic := 'Erro geral na rotina da tela pc_verifica_tipo_acesso: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_verifica_tipo_acesso;
  
  PROCEDURE pc_valida_adesao_produto(pr_cdcooper  IN crapass.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                                    ,pr_cdprodut  IN tbcc_produto.cdproduto%TYPE --> Codigo do operador
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao Erro  
    /* .............................................................................
    
        Programa: pc_valida_adesao_produto
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Março/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para verificar se o tipo de conta permite a contratação do produto.
    
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
      
      -- Busca pelos dados da conta
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.cdtipcta
              ,ass.inpessoa
              ,ass.cdsitdct
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
    BEGIN
      -- Buscar dados da conta
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se nao encontrar a conta
      IF cr_crapass%NOTFOUND THEN
        pr_cdcritic := 9;
        RAISE vr_exc_saida;
      END IF;
      -- Fechar cursor
      CLOSE cr_crapass;
      
      -- Verifica se a situacao de conta permite a contratação do produto
      pc_permite_produto_situacao(pr_cdprodut => pr_cdprodut
                                 ,pr_cdcooper => pr_cdcooper
                                 ,pr_cdsitdct => rw_crapass.cdsitdct
                                 ,pr_possuipr => vr_possuipr
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
      -- Se ocorrer erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      vr_possuipr := '';
      
      -- Verifica se o tipo de conta permite a contratação do produto
      pc_permite_produto_tipo(pr_cdprodut => pr_cdprodut
                             ,pr_cdtipcta => rw_crapass.cdtipcta
                             ,pr_cdcooper => pr_cdcooper
                             ,pr_inpessoa => rw_crapass.inpessoa
                             ,pr_possuipr => vr_possuipr
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
      -- Se ocorrer erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Se nao permitir a contratação do produto
      IF vr_possuipr = 'N' THEN
        vr_dscritic := 'Produto nao permitido para este tipo de conta.';
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
        pr_dscritic := 'Erro geral na rotina da tela pc_valida_adesao_produto: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_valida_adesao_produto;
  
  PROCEDURE pc_valida_adesao_prod_web(pr_nrdconta   IN crapass.nrdconta%TYPE --> Situacao
                                     ,pr_cdprodut   IN tbcc_produto.cdproduto%TYPE --> Codigo do operador
                                     ,pr_xmllog     IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml  IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro   OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_valida_adesao_produto
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Março/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para verificar se o tipo de conta permite a contratação do produto.
    
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
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
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
      
      pc_valida_adesao_produto(pr_cdcooper => vr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_cdprodut => pr_cdprodut
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
      
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
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
        
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_valida_adesao_prod_web: ' || SQLERRM;        
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_valida_adesao_prod_web;
  
  PROCEDURE pc_valida_adesao_apl_prog_web (pr_nrdconta   IN crapass.nrdconta%TYPE       --> Situacao
                                          ,pr_dtmvtolt   IN VARCHAR2                    --> Data de movimento
                                          ,pr_dtinirpp   IN VARCHAR2                    --> Data do início da Apl. Prog.
                                          ,pr_vlprerpp   IN craprpp.vlprerpp%TYPE       --> Valor da parcela
                                          ,pr_tpemiext   IN PLS_INTEGER                 --> Tipo da Impressão
                                          ,pr_xmllog     IN VARCHAR2                    --> XML com informações de LOG
                                          ,pr_cdcritic   OUT PLS_INTEGER                --> Código da crítica
                                          ,pr_dscritic   OUT VARCHAR2                   --> Descrição da crítica
                                          ,pr_retxml  IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
                                          ,pr_nmdcampo   OUT VARCHAR2                   --> Nome do campo com erro
                                          ,pr_des_erro   OUT VARCHAR2) IS               --> Erros do processo
    /* .............................................................................
    
        Programa: pc_valida_adesao_apl_prog_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : CIS Corporate
        Data    : Setembro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Mensageria para contratacao da aplicação programada 
                    (validação dos parâmetros e valores)
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
     
      --Variaveis auxiliares
      vr_solcoord INTEGER;
      vr_clob     CLOB;   
      vr_xml_temp VARCHAR2(32726) := '';
      vr_mensagem VARCHAR2(200);
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_possuipr  VARCHAR2(1);
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis gerais
      
      vr_dtmvtolt DATE := to_date(pr_dtmvtolt,'DD/MM/YYYY');
      vr_dtinirpp DATE;
      
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

      -- Verifica se são datas válidas, dentro de prazos válidos
      BEGIN
            vr_dtinirpp := to_date(pr_dtinirpp,'DD/MM/YYYY');
            IF (vr_dtinirpp IS NULL) OR
               (vr_dtinirpp > ADD_MONTHS(vr_dtmvtolt,2)) OR
               (vr_dtinirpp < vr_dtmvtolt)  
             THEN
               RAISE vr_exc_saida;
            END IF;
      EXCEPTION
            WHEN OTHERS THEN
                 vr_cdcritic:=13;  
                 pr_nmdcampo:='dtinirpp'; 
      END;
      IF vr_cdcritic IS NOT NULL THEN
         RAISE vr_exc_saida;  
      END IF;
      -- Verifica Tipo de extrato é válido

      IF pr_tpemiext < 1 OR pr_tpemiext > 3 THEN
         vr_cdcritic:=264;  
         pr_nmdcampo:='tpemiext';
         RAISE vr_exc_saida;  
      END IF;       
      -- Verifica se o valor está dentro da faixa permitida
      pc_valida_valor_de_adesao(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdprodut => 16          -- Poup./Apl. Programada
                               ,pr_vlcontra => pr_vlprerpp
                               ,pr_idorigem => vr_idorigem
                               ,pr_cddchave => 0
                               ,pr_solcoord => vr_solcoord
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);

      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        IF vr_solcoord = 1 THEN
          vr_mensagem := vr_dscritic;
        ELSE
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Monta documento XML - Ok
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>'||
                                                   '<Root>'||
                                                          '<solcoord>'||vr_solcoord||'</solcoord>'||
                                                          '<mensagem>'||vr_mensagem||'</mensagem>'||
                                                   '</Root>'
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
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_valida_adesao_apl_prog_web: ' || SQLERRM;        
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_valida_adesao_apl_prog_web;
  
  PROCEDURE pc_valida_altera_apl_prog_web (pr_nrdconta   IN crapass.nrdconta%TYPE       --> Situacao
                                          ,pr_dtmvtolt   IN VARCHAR2                    --> Data de movimento
                                          ,pr_nrctrrpp   IN craprpp.nrctrrpp%TYPE       --> Número do Contrato - CRAPRPP
                                          ,pr_indebito   IN INTEGER                     --> Dia de débito
                                          ,pr_vlprerpp   IN craprpp.vlprerpp%TYPE       --> Valor da parcela
                                          ,pr_xmllog     IN VARCHAR2                    --> XML com informações de LOG
                                          ,pr_cdcritic   OUT PLS_INTEGER                --> Código da crítica
                                          ,pr_dscritic   OUT VARCHAR2                   --> Descrição da crítica
                                          ,pr_retxml  IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
                                          ,pr_nmdcampo   OUT VARCHAR2                   --> Nome do campo com erro
                                          ,pr_des_erro   OUT VARCHAR2) IS               --> Erros do processo
    /* .............................................................................
    
        Programa: pc_valida_altera_apl_prog_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : CIS Corporate
        Data    : Setembro/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Mensageria para alteracao da aplicação programada 
                    (validação dos parâmetros e valores)
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
     
      --Variaveis auxiliares
      vr_solcoord INTEGER;
      vr_clob     CLOB;   
      vr_xml_temp VARCHAR2(32726) := '';
      vr_mensagem VARCHAR2(200);
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_possuipr  VARCHAR2(1);
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis gerais
      vr_dtmvtolt DATE := to_date(pr_dtmvtolt,'DD/MM/YYYY');
      
      vr_dtproxdeb_char VARCHAR2(10);
      vr_dtproxdeb DATE;
      vr_dtvalida BOOLEAN:=FALSE;
      

      -- Cursores
      -- Busca pelos dados da conta
      CURSOR cr_craprpp (pr_cdcooper IN craprpp.cdcooper%TYPE
                        ,pr_nrdconta IN craprpp.nrdconta%TYPE
                        ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE)
      IS
        SELECT  rpp.cdsitrpp
               ,rpp.dtdebito
               ,rpp.diadebit
          FROM craprpp rpp
         WHERE rpp.cdcooper = pr_cdcooper
           AND rpp.nrdconta = pr_nrdconta
           AND rpp.nrctrrpp = pr_nrctrrpp;
      
      rw_craprpp cr_craprpp%ROWTYPE;
      
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

      -- Verifica se o contrato existe
      OPEN cr_craprpp (pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctrrpp => pr_nrctrrpp);
      FETCH cr_craprpp INTO rw_craprpp;
      -- Se não encontrar
      IF cr_craprpp%NOTFOUND THEN
        CLOSE cr_craprpp;
        vr_cdcritic := 495;
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_craprpp;
     
      -- Verifica se o dia é valido
      IF (pr_indebito < 1) OR (pr_indebito > 31) THEN
         vr_cdcritic := 0;
         vr_dscritic := 'Dia de debito invalido';
         pr_nmdcampo:='indebito'; 
         RAISE vr_exc_saida;
      END IF;

      -- Nao deveria estar nesta situação, mas iremos proteger 
      IF rw_craprpp.dtdebito IS NULL THEN 
         rw_craprpp.dtdebito := vr_dtmvtolt;
      END IF;
      
      IF rw_craprpp.diadebit IS NULL THEN
        rw_craprpp.diadebit := EXTRACT (DAY FROM rw_craprpp.dtdebito);
      END IF;
      
      -- Verificar se alteraram a data débito 
      IF pr_indebito <> rw_craprpp.diadebit THEN
         -- Foi alterada
         IF pr_indebito > rw_craprpp.diadebit THEN -- Debitar novamente neste mês
             BEGIN
                  vr_dtproxdeb := TO_DATE(TO_CHAR(pr_indebito,'00')||TO_CHAR(vr_dtmvtolt,'/MM/YYYY'),'DD/MM/YYYY');
             EXCEPTION -- Colocar para o dia primeiro do próximo mês
                  WHEN OTHERS THEN
                       vr_dtproxdeb := LAST_DAY(vr_dtmvtolt)+1;
             END;    
         ELSE -- Enviar para o próximo mês
             BEGIN
                  vr_dtproxdeb := TO_DATE(TO_CHAR(pr_indebito,'00')||TO_CHAR(LAST_DAY(vr_dtmvtolt)+1,'/MM/YYYY'),'DD/MM/YYYY');
             EXCEPTION -- Colocar para o dia primeiro do próximo mês
                  WHEN OTHERS THEN    
                       vr_dtproxdeb := LAST_DAY(LAST_DAY(vr_dtmvtolt)+1)+1;
             END;    
         END IF;
         vr_dtproxdeb_char := TO_CHAR(vr_dtproxdeb,'DD/MM/YYYY');
      ELSE
         vr_dtproxdeb_char := TO_CHAR(rw_craprpp.dtdebito,'DD/MM/YYYY');
      END IF;
            
      -- Verifica se o valor está dentro da faixa permitida
      pc_valida_valor_de_adesao(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdprodut => 16          -- Poup./Apl. Programada
                               ,pr_vlcontra => pr_vlprerpp
                               ,pr_idorigem => vr_idorigem
                               ,pr_cddchave => 0
                               ,pr_solcoord => vr_solcoord
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);

      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        IF vr_solcoord = 1 THEN
          vr_mensagem := vr_dscritic;
        ELSE
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Monta documento XML - Ok
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>'||
                                                   '<Root>'||
                                                          '<solcoord>'||vr_solcoord||'</solcoord>'||
                                                          '<mensagem>'||vr_mensagem||'</mensagem>'||
                                                          '<diadebito>'||vr_dtproxdeb_char||'</diadebito>'||
                                                   '</Root>'
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
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_valida_adesao_apl_prog_web: ' || SQLERRM;        
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_valida_altera_apl_prog_web;
  
  PROCEDURE pc_valida_valor_adesao(pr_cdcooper  IN crapass.cdcooper%TYPE --> Cooperativa
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Situacao
                                  ,pr_cdprodut  IN tbcc_produto.cdproduto%TYPE --> Codigo do operador
                                  ,pr_vlcontra  IN VARCHAR2              --> Valor contratado
                                  ,pr_idorigem  IN INTEGER               --> ID origem
                                  ,pr_solcoord OUT INTEGER               --> Solicita senha coordenador
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao Erro
    /* .............................................................................
    
        Programa: pc_valida_valor_adesao
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Março/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para verificar se o valor contratado é permitido pelo tipo de conta
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
    
      pc_valida_valor_de_adesao(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdprodut => pr_cdprodut
                               ,pr_vlcontra => pr_vlcontra
                               ,pr_idorigem => pr_idorigem
                               ,pr_solcoord => pr_solcoord
                               ,pr_cddchave => 0
                               ,pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => pr_dscritic);
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina da tela pc_valida_valor_adesao: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_valida_valor_adesao;
  
  PROCEDURE pc_valida_valor_de_adesao(pr_cdcooper  IN crapass.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Situacao
                                     ,pr_cdprodut  IN tbcc_produto.cdproduto%TYPE --> Codigo do operador
                                     ,pr_vlcontra  IN VARCHAR2              --> Valor contratado
                                     ,pr_idorigem  IN INTEGER               --> ID origem
                                     ,pr_cddchave  IN INTEGER               --> Cod. chave
                                     ,pr_solcoord OUT INTEGER               --> Solicita senha coordenador
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo Erro
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao Erro
    /* .............................................................................
    
        Programa: pc_valida_valor_adesao
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Março/18.                    Ultima atualizacao: 08/09/2018
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para verificar se o valor contratado é permitido pelo tipo de conta
    
        Observacao: -----
    
        Alteracoes: 08/09/2018 - Para Apl. programadas, não considerar outras aplicações
                               - Proj. 411.2 (CIS Corporate)
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
      
      -- Busca pelos dados da conta
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.cdtipcta
              ,ass.inpessoa
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Busca pelos dados da conta
      CURSOR cr_produto (pr_cdcooper IN tbcc_produtos_coop.cdcooper%TYPE
                        ,pr_cdprodut IN tbcc_produto.cdproduto%TYPE
                        ,pr_inpessoa IN tbcc_produtos_coop.inpessoa%TYPE
                        ,pr_cdtipcta IN tbcc_produtos_coop.tpconta%TYPE) IS
        SELECT prd.idfaixa_valor
              ,prc.vlminimo_adesao
              ,prc.vlmaximo_adesao
          FROM tbcc_produto prd
              ,tbcc_produtos_coop prc
         WHERE prd.cdproduto = prc.cdproduto
           AND prc.cdcooper  = pr_cdcooper
           AND prc.cdproduto = pr_cdprodut
           AND prc.inpessoa  = pr_inpessoa
           AND prc.tpconta   = pr_cdtipcta;
      rw_produto cr_produto%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_solcoord := 0;
      
      -- Buscar dados da conta
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se nao encontrar a conta
      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic := 9;
        RAISE vr_exc_saida;
      END IF;
      -- Fechar cursor
      CLOSE cr_crapass;
      
      -- Buscar dados da conta
      OPEN cr_produto (pr_cdcooper => pr_cdcooper
                      ,pr_cdprodut => pr_cdprodut
                      ,pr_inpessoa => rw_crapass.inpessoa
                      ,pr_cdtipcta => rw_crapass.cdtipcta);
      FETCH cr_produto INTO rw_produto;
      -- Se nao encontrar a conta
      IF cr_produto%NOTFOUND THEN
        vr_dscritic := 'Produto não encontrado.';
        RAISE vr_exc_saida;
      END IF;
      -- Fechar cursor
      CLOSE cr_produto;
      
      IF rw_produto.idfaixa_valor = 0 THEN
        RETURN;
      END IF;
      
      -- Verifica produtos que não necessitam que seja buscado o valor anterior
      IF pr_cdprodut NOT IN (12,13,14,15,16) THEN 
        -- Busca valor já contratado
        pc_busca_valor_contratado(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_cdprodut => pr_cdprodut
                                 ,pr_vlcontra => vr_vlcontra
                                 ,pr_cddchave => pr_cddchave
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
                                 
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Soma valor já contratado ao novo valor que está sendo contratado
        vr_vlcontra := vr_vlcontra + GENE0002.fn_char_para_number(pr_vlcontra);
      ELSE
        vr_vlcontra := GENE0002.fn_char_para_number(pr_vlcontra);
      END IF;
      
      -- Verifica se soma do valor contratado está 
      -- no range permitido para o tipo de conta
      IF vr_vlcontra >= rw_produto.vlminimo_adesao AND
         vr_vlcontra <= rw_produto.vlmaximo_adesao THEN 
        RETURN;
      ELSE -- Se nao gera critica
        IF pr_idorigem NOT IN(1,5) THEN 
           vr_dscritic := 'Valor contratado deve estar entre ' || to_char(rw_produto.vlminimo_adesao,'FM999G999G999G990D00') || 
                                                         ' e ' || to_char(rw_produto.vlmaximo_adesao,'FM999G999G999G990D00') || '.';
        ELSE
          IF vr_vlcontra < rw_produto.vlminimo_adesao THEN 
            vr_dscritic := 'Valor abaixo do minimo permitido para o tipo de conta. Necessario liberacao do coordenador.';
          ELSE
            vr_dscritic := 'Valor acima do maximo permitido para o tipo de conta. Necessario liberacao do coordenador.';
          END IF;
          pr_solcoord := 1;
        END IF;
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
        pr_dscritic := 'Erro geral na rotina da tela pc_valida_valor_de_adesao: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_valida_valor_de_adesao;
  
  PROCEDURE pc_valida_valor_adesao_empr(pr_nrdconta  IN crapass.nrdconta%TYPE --> Situacao
                                       ,pr_vlcontra  IN VARCHAR2              --> Valor contratado
                                       ,pr_dsctrliq  IN VARCHAR2              --> Contratos liquidados
                                       ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_valida_valor_adesao_empr
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Março/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para verificar se o valor contratado é permitido pelo tipo de conta
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
      vr_des_erro VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_possuipr  VARCHAR2(1);
      
      --Variaveis auxiliares
      vr_vlcontra NUMBER := 0;
      vr_vlsdeved NUMBER := 0;
      vr_qtprecal crapepr.qtprecal%TYPE;
      vr_dstextab VARCHAR2(1000);
      vr_inusatab BOOLEAN;
      vr_solcoord INTEGER;
      vr_clob     CLOB;   
      vr_xml_temp VARCHAR2(32726) := '';
      vr_mensagem VARCHAR2(200);
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      CURSOR cr_crapepr (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_dsctrliq IN VARCHAR2) IS
        SELECT t.nrctremp
          FROM crapepr t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta
           AND t.inliquid = 0
           AND t.inprejuz = 0
           -- Desconsidera o valor dos emprestimos marcados para liquidacao
           AND (TRIM(pr_dsctrliq) IS NULL
            OR TO_CHAR(t.nrctremp) NOT IN (SELECT regexp_substr(TRIM(pr_dsctrliq), '[^,]+', 1, LEVEL) item
                                   FROM dual
                            CONNECT BY LEVEL <= regexp_count(TRIM(pr_dsctrliq), '[^,]+')));
      
		  -- Cursor da data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      
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
      
      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
      
      --Buscar Indicador Uso tabela
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
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
        IF SUBSTR(vr_dstextab,1,1) = '0' THEN
          --Nao usa tabela
          vr_inusatab:= FALSE;
        ELSE
          --Nao usa tabela
          vr_inusatab:= TRUE;
        END IF;
      END IF;
      
      -- Buscar contratos de emprestimos nao liquidados 
      FOR rw_crapepr IN cr_crapepr (pr_cdcooper => vr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_dsctrliq => pr_dsctrliq) LOOP
        -- Buscar o saldo devedor
        EMPR0001.pc_calc_saldo_epr(pr_cdcooper   => vr_cdcooper         --> Codigo da Cooperativa
                                  ,pr_rw_crapdat => rw_crapdat          --> Vetor com dados de parametro (CRAPDAT)
                                  ,pr_cdprogra   => 'CADA0006'          --> Programa que solicitou o calculo
                                  ,pr_nrdconta   => pr_nrdconta         --> Numero da conta do emprestimo
                                  ,pr_nrctremp   => rw_crapepr.nrctremp --> Numero do contrato do emprestimo
                                  ,pr_inusatab   => vr_inusatab         --> Indicador de utilizacão da tabela de juros
                                  ,pr_vlsdeved   => vr_vlsdeved         --> Saldo devedor do emprestimo
                                  ,pr_qtprecal   => vr_qtprecal         --> Quantidade de parcelas do emprestimo
                                  ,pr_cdcritic   => vr_cdcritic         --> Codigo de critica encontrada
                                  ,pr_des_erro   => vr_des_erro);       --> Retorno de Erro
        
        -- Se ocorreu erro, gerar critica
        IF vr_cdcritic IS NOT NULL OR vr_des_erro IS NOT NULL THEN
          -- Zerar saldo devedor
          vr_vlsdeved := 0;
          -- Gerar critica
          RAISE vr_exc_saida;
        END IF;
        -- Somar os saldos devedores
        vr_vlcontra := vr_vlcontra + vr_vlsdeved;
        
      END LOOP;
      
      -- Somar o valor do emprestimo com o saldo devedor
      vr_vlcontra := vr_vlcontra + GENE0002.fn_char_para_number(pr_vlcontra);
      
      -- Chamar a rotina para validar valor de adesao do produto
      pc_valida_valor_de_adesao(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdprodut => 31
                               ,pr_vlcontra => TO_CHAR(vr_vlcontra)
                               ,pr_idorigem => vr_idorigem
                               ,pr_cddchave => 0
                               ,pr_solcoord => vr_solcoord
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
      
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        IF vr_solcoord = 1 THEN
          vr_mensagem := vr_dscritic;
        ELSE
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>'||
                                                   '<Root>'||
                                                          '<solcoord>'||vr_solcoord||'</solcoord>'||
                                                          '<mensagem>'||vr_mensagem||'</mensagem>'||
                                                   '</Root>'
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
        pr_dscritic := 'Erro geral na rotina da tela pc_valida_valor_adesao_empr: ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_valida_valor_adesao_empr;
  
  PROCEDURE pc_valida_valor_adesao_web(pr_nrdconta   IN crapass.nrdconta%TYPE --> Situacao
                                      ,pr_cdprodut   IN tbcc_produto.cdproduto%TYPE --> Codigo do operador
                                      ,pr_vlcontra   IN VARCHAR2              --> Valor contratado
                                      ,pr_cddchave   IN INTEGER               --> Cod. chave
                                      ,pr_xmllog     IN VARCHAR2 --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                      ,pr_retxml IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_valida_valor_adesao
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Março/18.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para verificar se o valor contratado é permitido pelo tipo de conta
    
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
      vr_solcoord INTEGER;
      vr_clob     CLOB;   
      vr_xml_temp VARCHAR2(32726) := '';
      vr_mensagem VARCHAR2(200);
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Busca pelos dados da conta
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.cdtipcta
              ,ass.inpessoa
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Busca pelos dados da conta
      CURSOR cr_produto (pr_cdcooper IN tbcc_produtos_coop.cdcooper%TYPE
                        ,pr_cdprodut IN tbcc_produto.cdproduto%TYPE
                        ,pr_inpessoa IN tbcc_produtos_coop.inpessoa%TYPE
                        ,pr_cdtipcta IN tbcc_produtos_coop.tpconta%TYPE) IS
        SELECT prd.idfaixa_valor
              ,prc.vlminimo_adesao
              ,prc.vlmaximo_adesao
          FROM tbcc_produto prd
              ,tbcc_produtos_coop prc
         WHERE prd.cdproduto = prd.cdproduto
           AND prc.cdcooper  = pr_cdcooper
           AND prc.cdproduto = pr_cdprodut
           AND prc.inpessoa  = pr_inpessoa
           AND prc.tpconta   = pr_cdtipcta;
      rw_produto cr_produto%ROWTYPE;
      
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
      
      pc_valida_valor_de_adesao(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdprodut => pr_cdprodut
                               ,pr_vlcontra => pr_vlcontra
                               ,pr_idorigem => vr_idorigem
                               ,pr_cddchave => pr_cddchave
                               ,pr_solcoord => vr_solcoord
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
      
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        IF vr_solcoord = 1 THEN
          vr_mensagem := vr_dscritic;
        ELSE
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?>'||
                                                   '<Root>'||
                                                          '<solcoord>'||vr_solcoord||'</solcoord>'||
                                                          '<mensagem>'||vr_mensagem||'</mensagem>'||
                                                   '</Root>'
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
        pr_dscritic := 'Erro geral na rotina da tela pc_valida_valor_adesao_web: ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_valida_valor_adesao_web;
  
  /*****************************************************************************/
  /**            Procedure para criar campo na tabela histor.                 **/
  /*****************************************************************************/
  PROCEDURE pc_cria_campo_hist(pr_nmtabela   IN tbcc_campo_historico.nmtabela_oracle%TYPE --> Nome da tabela
                              ,pr_nmdcampo   IN tbcc_campo_historico.nmcampo%TYPE         --> Nome do campo 
                              ,pr_idcampo   OUT tbcc_campo_historico.idcampo%TYPE         --> Retorna id do campo
                              ,pr_dscritic  OUT VARCHAR2) IS                              --> Retorna critica
     
  /* ..........................................................................
    --
    --  Programa : pc_cria_campo_hist
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Renato Darosci(Supero)
    --  Data     : Abril/2018.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para criar campo na tabela de históricos.   
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar campo historico
    CURSOR cr_campo_hist IS
      SELECT col.table_name
            ,col.column_name
            ,com.comments
            ,cmp.idcampo
        FROM all_tab_columns      col
            ,all_col_comments     com
            ,tbcc_campo_historico cmp
       WHERE col.owner       = 'CECRED'
         AND col.table_name  = upper(pr_nmtabela)
         AND col.column_name = upper(pr_nmdcampo)
         AND com.owner       = col.owner
         AND com.table_name  = col.table_name
         AND com.column_name = col.column_name
         AND col.table_name  = cmp.nmtabela_oracle(+)
         AND col.column_name = cmp.nmcampo(+)
       ORDER BY col.column_id;
    rw_campo_hist cr_campo_hist%ROWTYPE;
       
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;
    
  BEGIN
  
    --> Verificar se o campo existe na tabela
    OPEN  cr_campo_hist;
    FETCH cr_campo_hist INTO rw_campo_hist;
    
    --> Se nao existe na tabela, nao permite cadastra-lo
    IF cr_campo_hist%NOTFOUND THEN
      vr_dscritic := 'Campo '||UPPER(pr_nmdcampo)||' não existe na tabela '||UPPER(pr_nmtabela);
      RAISE vr_exc_erro;
    --> Se ja esta cadastrado, apenas retorna id
    ELSIF rw_campo_hist.idcampo IS NOT NULL THEN
      pr_idcampo := rw_campo_hist.idcampo;
    ELSE      
       --> Inserir na tabela
       BEGIN
         INSERT INTO tbcc_campo_historico
                     (nmtabela_oracle 
                     ,nmcampo 
                     ,dscampo)
              VALUES (UPPER(pr_nmtabela)     --> nmtabela_oracle
                     ,UPPER(pr_nmdcampo)     --> nmcampo 
                     ,rw_campo_hist.COMMENTS) --> dscampo      
             RETURNING idcampo INTO pr_idcampo;
       EXCEPTION 
         WHEN OTHERS THEN
           vr_dscritic := 'Não foi possivel cadastrar campo '||
                           UPPER(pr_nmtabela)||'.'||UPPER(pr_nmdcampo)||': '||SQLERRM;
           RAISE vr_exc_erro;
       END;    
    END IF;
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic; 
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao criar campo tbcc_campo_historico: '||SQLERRM;
  END pc_cria_campo_hist;
  
  
  /*****************************************************************************/
  /**            Procedure para gravar tabela de historico de conta           **/
  /*****************************************************************************/
  PROCEDURE pc_grava_dados_hist(pr_nmtabela    IN tbcc_campo_historico.nmtabela_oracle%TYPE  --> Nome da tela                              
                               ,pr_nmdcampo    IN tbcc_campo_historico.nmcampo%TYPE          --> Nome do campo
                               ,pr_cdcooper    IN tbcc_conta_historico.cdcooper%TYPE     DEFAULT 0 --> Cooperativa
                               ,pr_nrdconta    IN tbcc_conta_historico.nrdconta%TYPE     DEFAULT 0 --> Número da conta
                               ,pr_inpessoa    IN tbcc_conta_historico.inpessoa%TYPE     DEFAULT 0 --> Tipo de pessoa
                               ,pr_idseqttl    IN tbcc_conta_historico.idseqttl%TYPE     DEFAULT 0 --> Sequencia do titular
                               ,pr_cdtipcta    IN tbcc_conta_historico.cdtipo_conta%TYPE DEFAULT NULL --> Código do tipo de conta
                               ,pr_cdsituac    IN tbcc_conta_historico.cdsituacao%TYPE   DEFAULT NULL --> Código da situação
                               ,pr_cdprodut    IN tbcc_produtos_coop.cdproduto%TYPE      DEFAULT NULL --> Código do produto
                               ,pr_tpoperac    IN tbcc_conta_historico.tpoperacao%TYPE       --> Tipo de operacao (1-Inclusao/ 2-Alteracao/ 3-Exclusao)
                               ,pr_dsvalant    IN tbcc_conta_historico.dsvalor_anterior%TYPE --> Valor anterior
                               ,pr_dsvalnov    IN tbcc_conta_historico.dsvalor_novo%TYPE     --> Valor novo
                               ,pr_cdoperad    IN tbcc_conta_historico.cdoperad_altera%TYPE  --> Código do operador da ação
                               ,pr_dscritic   OUT VARCHAR2                                   --> Retornar Critica 
                                ) IS 
     
  /* ..........................................................................
    --
    --  Programa : pc_grava_dados_hist
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Renato Darosci(Supero)
    --  Data     : Abril/2018.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para gravar tabela de historico de contas
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
       
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION; 
    
    -- Id do campo de histórico
    vr_idcampo  tbcc_campo_historico.idcampo%TYPE;      
    
  BEGIN
    
    -- Se for alteração 
    IF pr_tpoperac = 2 THEN
      -- Verifica se o campo foi alterado
      IF NVL(pr_dsvalant, ' ') = NVL(pr_dsvalnov, ' ') THEN
        -- Não gerar histórico se não alterou o valor do campo
        RETURN;
      END IF;
    END IF;
  
    -- Chama a rotina para retornar o id do campo de historico
    pc_cria_campo_hist(pr_nmtabela   => pr_nmtabela   --> Nome da tela                              
                      ,pr_nmdcampo   => pr_nmdcampo   --> Nome do campo 
                      ,pr_idcampo    => vr_idcampo    --> Retorna id do campo
                      ,pr_dscritic   => vr_dscritic); 

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;     
  
    --> Inserir tabela
    BEGIN
      INSERT INTO tbcc_conta_historico
                      (cdcooper
                      ,nrdconta
                      ,inpessoa
                      ,idseqttl
                      ,cdproduto
                      ,dhalteracao
                      ,tpoperacao
                      ,idcampo
                      ,dsvalor_anterior
                      ,dsvalor_novo
                      ,cdoperad_altera
                      ,cdtipo_conta
                      ,cdsituacao)
               VALUES (pr_cdcooper   -- cdcooper
                      ,pr_nrdconta   -- nrdconta
                      ,pr_inpessoa   -- inpessoa
                      ,pr_idseqttl   -- idseqttl
                      ,pr_cdprodut   -- cdprodut
                      ,SYSDATE       -- dhalteracao
                      ,pr_tpoperac   -- tpoperacao
                      ,vr_idcampo    -- idcampo
                      ,pr_dsvalant   -- dsvalor_anterior
                      ,pr_dsvalnov   -- dsvalor_novo
                      ,pr_cdoperad   -- cdoperad_altera
                      ,pr_cdtipcta   -- cdtipo_conta
                      ,pr_cdsituac); -- cdsituacao
                  
    
    EXCEPTION 
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel gravar TBCC_CONTA_HISTORICO: '||SQLERRM; 
        RAISE vr_exc_erro;
    END;  
  
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao gravar TBCC_CONTA_HISTORICO: '||SQLERRM; 
  END pc_grava_dados_hist;
  
  --> Procedure para retornar as opçoes do dominio para o Ayllos WEB.
  PROCEDURE pc_lista_situacoes_conta_web(pr_xmllog   IN VARCHAR2             --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER         --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2            --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2            --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS        --> Erros do processo
  /* ..........................................................................
  --
  --  Programa : pc_lista_situacoes_conta_web
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : Lombardi
  --  Data     : Agosto/2017.                   Ultima atualizacao:
  --
  --  Dados referentes ao programa:
  --
  --   Frequencia: Sempre que for chamado
  --   Objetivo  : Procedure para retornar as situacoes de conta para o Ayllos WEB.
  --
  --
  --   Alteração :
  -- ..........................................................................*/

    ------------------> CURSORES <----------------

    CURSOR cr_situacao IS
      SELECT cdsituacao
            ,dssituacao
        FROM tbcc_situacao_conta
       ORDER BY cdsituacao;

    -----------------> VARIAVEIS <-----------------
    
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    
    -----------------> SUBPROGRAMAS <--------------

  BEGIN
    
    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><situacoes></situacoes></Root>');
    
    FOR rw_situacao IN cr_situacao LOOP
      -- Registros
      pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                         ,'/Root/situacoes'
                                         ,XMLTYPE('<situacao>'
                                                ||'  <cdsituacao>' || rw_situacao.cdsituacao || '</cdsituacao>'
                                                ||'  <dssituacao>' || rw_situacao.dssituacao || '</dssituacao>'
                                                ||'</situacao>'));
    END LOOP;

  EXCEPTION
    WHEN vr_exc_erro  THEN
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_dscritic := 'Erro nao tratado ao carregar dominio:'||SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_lista_situacoes_conta_web;

  PROCEDURE pc_valor_min_capital(pr_cdcooper          IN tbcc_tipo_conta_coop.cdcooper%TYPE --> codigo da cooperativa
                                ,pr_inpessoa          IN tbcc_tipo_conta_coop.inpessoa%TYPE --> tipo de pessoa
                                ,pr_cdtipo_conta      IN tbcc_tipo_conta_coop.cdtipo_conta%TYPE --> codigo do tipo de conta
                                ,pr_vlminimo_capital OUT tbcc_tipo_conta_coop.vlminimo_capital%TYPE --> descricao do tipo de conta
                                ,pr_des_erro         OUT VARCHAR2 --> Código da crítica
                                ,pr_dscritic         OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_valor_min_capital
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
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT 1
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Busca tipo de conta
      CURSOR cr_tipo_conta(pr_cdcooper IN tbcc_tipo_conta_coop.cdcooper%TYPE
                          ,pr_inpessoa IN tbcc_tipo_conta_coop.inpessoa%TYPE
                          ,pr_tpconta  IN tbcc_tipo_conta_coop.cdtipo_conta%TYPE) IS
        SELECT cta.vlminimo_capital
          FROM tbcc_tipo_conta_coop cta
         WHERE cta.cdcooper = pr_cdcooper
           AND cta.inpessoa = pr_inpessoa
           AND cta.cdtipo_conta = pr_tpconta;
      rw_tipo_conta cr_tipo_conta%ROWTYPE;
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Verifica tipo de conta
      IF cr_crapcop%NOTFOUND THEN
        vr_dscritic := 'Código da cooperativa inválido.';
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
      OPEN cr_tipo_conta(pr_cdcooper => pr_cdcooper
                        ,pr_inpessoa => pr_inpessoa
                        ,pr_tpconta  => pr_cdtipo_conta);
      FETCH cr_tipo_conta INTO rw_tipo_conta;
      
      IF cr_tipo_conta%NOTFOUND THEN
        CLOSE cr_tipo_conta;
        vr_dscritic := 'Tipo de conta não encontrado.';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_tipo_conta;
      
      -- Retorna descricao do tipo de conta
      pr_vlminimo_capital := rw_tipo_conta.vlminimo_capital;
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
        pr_dscritic := 'Erro geral na rotina pc_valor_min_capital: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_valor_min_capital;
  
  PROCEDURE pc_verifica_lib_blq_pre_aprov(pr_cdcooper  IN tbcc_situacao_conta_coop.cdcooper%TYPE --> codigo da cooperativa
                                         ,pr_nrdconta  IN tbepr_param_conta.nrdconta%TYPE --> Numero da conta
                                         ,pr_cdsitdct  IN tbcc_situacao_conta_coop.cdsituacao%TYPE --> codigo da situacao
                                         ,pr_des_erro OUT VARCHAR2 --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2) IS --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_verifica_lib_blq_pre_aprov
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Dezembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar descricao do tipo de conta.
    
        Observacao: -----
    
        Alteracoes: 01/06/2018 - Ajustar regra de bloqueio do pré-aprovado e ajustar
                                 tratamentos de erro. (Renato - Supero)
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variáveis auxiliares
      vr_possuipr VARCHAR2(1);
      
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'CADA0006'
                                ,pr_action => null);
      
      pr_des_erro := 'NOK';
      
      -- Verifica se a situação permite pre aprovado
      pc_permite_produto_situacao(pr_cdprodut => 25
                                 ,pr_cdcooper => pr_cdcooper
                                 ,pr_cdsitdct => pr_cdsitdct
                                 ,pr_possuipr => vr_possuipr
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
      
      -- Se ocorrer erro diferente de produto nao permitido
      IF vr_possuipr <> 'N' AND vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
      
      -- Se permitir
      IF vr_possuipr = 'S' THEN
        BEGIN
          -- Libera pre aprovado
          UPDATE tbepr_param_conta param
             SET param.flglibera_pre_aprv = 1
                ,param.idmotivo = NULL
                ,param.dtatualiza_pre_aprv = TRUNC(SYSDATE)
           WHERE param.cdcooper = pr_cdcooper
             AND param.nrdconta = pr_nrdconta
             AND param.flglibera_pre_aprv = 0 -- Não liberado...
             AND param.idmotivo = 67;         -- ... e com motivo 67 (bloqueio por situação de conta)
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao liberar pre-aprovado: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      ELSE
        BEGIN
          -- Bloqueado pre aprovado
          UPDATE tbepr_param_conta param
             SET param.flglibera_pre_aprv = 0
                ,param.idmotivo = 67
                ,param.dtatualiza_pre_aprv = TRUNC(SYSDATE)
           WHERE param.cdcooper = pr_cdcooper
             AND param.nrdconta = pr_nrdconta
             AND param.flglibera_pre_aprv = 1;  -- Liberado
             
          -- Se nenhum registro foi alterado, deve ser incluso o bloqueio
          IF SQL%ROWCOUNT = 0 THEN
            BEGIN
              INSERT INTO tbepr_param_conta(cdcooper
                                           ,nrdconta
                                           ,flglibera_pre_aprv
                                           ,dtatualiza_pre_aprv
                                           ,idmotivo)
                                     VALUES(pr_cdcooper    -- cdcooper
                                           ,pr_nrdconta    -- nrdconta
                                           ,0              -- flglibera_pre_aprv
                                           ,TRUNC(SYSDATE) -- dtatualiza_pre_aprv
                                           ,67 );          -- idmotivo
            EXCEPTION
              WHEN dup_val_on_index THEN
                -- Caso aconteça estouro de chave é devido ao fato de já existir registro
                -- de parametro e o mesmo já está indicando bloqueio.
                NULL;
              WHEN OTHERS THEN
                vr_dscritic := 'Erro incluir bloqueio pre-aprovado: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;
        
        EXCEPTION
          WHEN vr_exc_saida THEN
            RAISE vr_exc_saida;
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao bloquear pre-aprovado: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
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
        pr_dscritic := 'Erro geral na rotina pc_verifica_lib_blq_pre_aprov: ' || SQLERRM;
        ROLLBACK;
    END;
  END pc_verifica_lib_blq_pre_aprov;

END CADA0006;
/
