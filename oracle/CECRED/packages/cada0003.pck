CREATE OR REPLACE PACKAGE CECRED.CADA0003 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0003
  --  Sistema  : Rotinas acessadas pelas telas de cadastros Web
  --  Sigla    : CADA
  --  Autor    : Andrino Carlos de Souza Junior - RKAM
  --  Data     : Julho/2014.                   Ultima atualizacao: 04/08/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas utilizadas para as telas MATRIC, CONTAS e ATENDA referente a cadastros
  --
  --  Alteracoes: 04/08/2017 - Movido a rotina pc_busca_cnae para a TELA_CADCNA (Adriano).
  --
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Definicao do tipo de registro
  TYPE typ_reg_crapmun IS
  RECORD (idcidade crapmun.idcidade%TYPE
         ,cdestado crapmun.cdestado%TYPE
         ,cdcidade crapmun.idcidade%TYPE
         ,dscidade crapmun.dscidade%TYPE);

  -- Definicao do tipo de tabela registro
  TYPE typ_tab_crapmun IS TABLE OF typ_reg_crapmun INDEX BY PLS_INTEGER;

  -- Rotina para buscar o relacionamento de responsavel legal para usar usado no AyllosWeb
  PROCEDURE pc_busca_rlc_rsp_legal_web(pr_cdrelacionamento IN tbgen_cnae.cdcnae%TYPE --> Codigo do CNAE
                                      ,pr_dsrelacionamento IN tbgen_cnae.dscnae%TYPE --> Descricao do CNAE
                                      ,pr_nriniseq         IN PLS_INTEGER            --> Numero inicial do registro para enviar
                                      ,pr_nrregist         IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                                      ,pr_xmllog           IN VARCHAR2               --> XML com informações de LOG
                                      ,pr_cdcritic         OUT PLS_INTEGER           --> Código da crítica
                                      ,pr_dscritic         OUT VARCHAR2              --> Descrição da crítica
                                      ,pr_retxml           IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                      ,pr_nmdcampo         OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro         OUT VARCHAR2);            --> Erros do processo

  -- Rotina para buscar o relacionamento de responsavel legal para usar usado no Progress
  PROCEDURE pc_busca_rlc_rsp_legal(pr_cdrelacionamento IN tbgen_cnae.cdcnae%TYPE --> Codigo do CNAE
                                  ,pr_dsrelacionamento IN tbgen_cnae.dscnae%TYPE --> Descricao do CNAE
                                  ,pr_retxml           OUT CLOB                  --> Arquivo de retorno do XML
                                  ,pr_cdcritic         OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic         OUT VARCHAR2);            --> Descrição da crítica

  -- Rotina para retornar as contas permitidas para duplicacao
  PROCEDURE pc_lista_contas(pr_cdcooper IN crapass.cdcooper%TYPE  --> Codigo da cooperativa
                           ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE  --> Numero do CPF / CGC do cooperado
                           ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Rotina para duplicar a conta informada
  PROCEDURE pc_duplica_conta(pr_cdcooper     IN crapass.cdcooper%TYPE  --> Codigo da cooperativa
                            ,pr_nrdconta_org IN crapass.nrdconta%TYPE  --> Numero da conta de origem da copia
                            ,pr_nrdconta_dst IN crapass.nrdconta%TYPE  --> Numero da conta de destino da copia
                            ,pr_cdoperad IN  crapope.cdoperad%TYPE --> Operador que solicitou a duplicacao
                            ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Rotina para buscar os servicos de SAC para a tela ATENDA
  PROCEDURE pc_lista_servicos(pr_cdservico IN tbsac_servico.cdservico%TYPE --> Codigo do servico
                             ,pr_nmservico IN tbsac_servico.nmservico%TYPE --> Nome do servico
                             ,pr_nriniseq IN PLS_INTEGER                   --> Numero inicial do registro para enviar
                             ,pr_nrregist IN PLS_INTEGER                   --> Numero de registros que deverao ser retornados
                             ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  FUNCTION fn_busca_servico (pr_cdproduto IN tbcc_produtos_coop.cdproduto%TYPE) RETURN VARCHAR2;

  PROCEDURE pc_consulta_servicos (pr_cdcooper   IN crapcop.cdcooper%TYPE
                                 ,pr_tpproduto  IN tbcc_produtos_coop.tpproduto%TYPE  --> tipo de produto
                                 ,pr_tpconta    IN tbcc_produtos_coop.tpconta%TYPE    --> tipo de conta
                                 ,pr_xmllog     IN VARCHAR2                           --> XML com informações de LOG
                                 ,pr_cdcritic   OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                 ,pr_dscritic   OUT VARCHAR2                          --> Descricao da critica
                                 ,pr_retxml     IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                 ,pr_nmdcampo   OUT VARCHAR2                          --> Nome do campo com erro
                                 ,pr_des_erro   OUT VARCHAR2);                        --> Erros do processo

  PROCEDURE pc_valida_consistencia (pr_cdcooper   IN crapcop.cdcooper%TYPE
                                   ,pr_tpproduto  IN tbcc_produtos_coop.tpproduto%TYPE  --> tipo de produto
                                   ,pr_tpconta    IN tbcc_produtos_coop.tpconta%TYPE    --> tipo de conta
                                   ,pr_servico    IN VARCHAR2                           --> produtos aderidos
                                   ,pr_xmllog     IN VARCHAR2                           --> XML com informações de LOG
                                   ,pr_cdcritic   OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                   ,pr_dscritic   OUT VARCHAR2                          --> Descricao da critica
                                   ,pr_retxml     IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                   ,pr_nmdcampo   OUT VARCHAR2                          --> Nome do campo com erro
                                   ,pr_des_erro   OUT VARCHAR2);

  PROCEDURE pc_inclui_servicos (pr_cdcooper   IN crapcop.cdcooper%TYPE
                               ,pr_tpproduto  IN tbcc_produtos_coop.tpproduto%TYPE  --> tipo de produto
                               ,pr_tpconta    IN tbcc_produtos_coop.tpconta%TYPE    --> tipo de conta
                               ,pr_servicos   IN VARCHAR2                           --> produtos aderidos
                               ,pr_xmllog     IN VARCHAR2                           --> XML com informações de LOG
                               ,pr_cdcritic   OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                               ,pr_dscritic   OUT VARCHAR2                          --> Descricao da critica
                               ,pr_retxml     IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                               ,pr_nmdcampo   OUT VARCHAR2                          --> Nome do campo com erro
                               ,pr_des_erro   OUT VARCHAR2);                        --> Erros do processo

  PROCEDURE pc_servicos_oferecidos(pr_nrdconta IN crapass.nrdconta%TYPE         --> Numero da conta
                                  ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  -- Atualiza a tabela de produtos oferecidos com as escolhas do usuario na tela ATENDA
  PROCEDURE pc_atualiza_produto_oferecido(pr_nrdconta IN crapass.nrdconta%TYPE         --> Numero da conta
                                         ,pr_cdproduto IN tbcc_produto.cdproduto%TYPE  --> Codigo do produto
                                         ,pr_inofertado IN tbcc_produto_oferecido.inofertado%TYPE --> Indicador de produto ofertado
                                         ,pr_inaderido IN tbcc_produto_oferecido.inaderido%TYPE --> Indicador se o produto foi aderido
                                         ,pr_inadesao_externa IN tbcc_produto_oferecido.inadesao_externa%TYPE --> Indicador de adesao em outra instituicao
                                         ,pr_dtvencimento IN VARCHAR2                  --> Data de venvimento do produto na outra instituicao
                                         ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  -- Atualiza a tabela de produtos oferecidos com os produtos obrigatorios que foram oferecidos na tela ATENDA
  PROCEDURE pc_produtos_obrigatorios(pr_nrdconta IN crapass.nrdconta%TYPE         --> Numero da conta
                                    ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo

  -- Rotina para listar os creditos recebidos dos ultimos 7 meses
  PROCEDURE pc_lista_cred_recebidos(pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Rotina geral de insert, update, select e delete da tela ATENDA da opção Atendimento SAC
  PROCEDURE pc_registro_servicos(pr_cddopcao      IN VARCHAR2              --> Tipo de acao que sera executada (A - ALteracao / C - Consulta / E - Exclur / I - Inclur)
                                ,pr_nrdconta      IN crapcbr.cdbircon%TYPE --> Numero da conta
                                ,pr_dtatendimento IN VARCHAR2              --> Data do atendimento
                                ,pr_hratendimento IN VARCHAR2              --> Hora do atendimento
                                ,pr_cdservico     IN tbsac_registro_servico.cdservico%TYPE --> Codigo do servico solicitado
                                ,pr_dsservico     IN tbsac_registro_servico.dsservico_solicitado%TYPE --> Descricao do servico solicitado
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);         --> Erros do processo

  -- Rotina geral de insert, update, select e delete da tela ATENDA da opção Atendimento SAC
  PROCEDURE pc_busca_servicos_ativos(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - ALteracao / C - Consulta / E - Exclur / I - Inclur)
                                    ,pr_nrdconta IN crapcbr.cdbircon%TYPE --> Numero da conta
                                    ,pr_nrregist IN INTEGER               --Numero Registros
                                    ,pr_nriniseq IN INTEGER               --Numero Sequencia Inicial
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) ;        --> Erros do processo

  -- Rotina para veririfcar se é o primeiro acesso a tela Produtos
  PROCEDURE pc_primeiro_acesso(pr_nrdconta      IN crapcbr.cdbircon%TYPE --> Numero da conta
                              ,pr_xmllog        IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic      OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic      OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml        IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo      OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro      OUT VARCHAR2);         --> Erros do processo

  PROCEDURE pc_encerra_cadastramento (pr_cdcooper IN crapcop.cdcooper%TYPE --> cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE --> numero da conta
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  PROCEDURE pc_retorna_consultores(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           --> Descrição do erro
  
  PROCEDURE pc_retorna_consultor_pa(pr_cdcooper    IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                                   ,pr_cdconsultor IN tbcc_consultor.cdconsultor%TYPE --> Codigo do Consultor
                                   ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                                   ,pr_cdcritic    OUT PLS_INTEGER                    --> Código da crítica
                                   ,pr_dscritic    OUT VARCHAR2                       --> Descrição da crítica
                                   ,pr_retxml      IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                                   ,pr_nmdcampo    OUT VARCHAR2                       --> Nome do campo com erro
                                   ,pr_des_erro    OUT VARCHAR2);                     --> Descrição do erro
  
  PROCEDURE pc_incluir_consultor(pr_cdcooper IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                                ,pr_cdconsul IN tbcc_consultor.cdconsultor%TYPE --> Código do Consultor
                                ,pr_cdoperad IN tbcc_consultor.cdoperad%TYPE    --> Código do Operador
                                --Informações de P.A.
                                ,pr_xmllog   IN VARCHAR2                        --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                    --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2                       --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                       --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);                     --> Descrição do erro

  PROCEDURE pc_retorna_agencia(pr_cdcooper    IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                              ,pr_cdagenci    IN crapage.cdagenci%TYPE           --> Codigo da Agencia
                              ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                              ,pr_cdcritic    OUT PLS_INTEGER                    --> Código da crítica
                              ,pr_dscritic    OUT VARCHAR2                       --> Descrição da crítica
                              ,pr_retxml      IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                              ,pr_nmdcampo    OUT VARCHAR2                       --> Nome do campo com erro
                              ,pr_des_erro    OUT VARCHAR2);

  PROCEDURE pc_retorna_operador(pr_cdcooper    IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                               ,pr_cdoperad    IN crapope.cdoperad%TYPE           --> Codigo da Agencia
                               ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                               ,pr_cdcritic    OUT PLS_INTEGER                    --> Código da crítica
                               ,pr_dscritic    OUT VARCHAR2                       --> Descrição da crítica
                               ,pr_retxml      IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                               ,pr_nmdcampo    OUT VARCHAR2                       --> Nome do campo com erro
                               ,pr_des_erro    OUT VARCHAR2);

  PROCEDURE pc_incluir_agencia(pr_cdcooper IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                              ,pr_cdconsul IN tbcc_consultor.cdconsultor%TYPE --> Código do Consultor
                              ,pr_cdagenci IN crapage.cdagenci%TYPE           --> Código da Agencia
                              ,pr_xmllog   IN VARCHAR2                        --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER                    --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2                       --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                       --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);                     --> Descrição do erro
  
  PROCEDURE pc_inativa_consultor(pr_cdcooper IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                                ,pr_cdconsul IN tbcc_consultor.cdconsultor%TYPE --> Código do Consultor
                                ,pr_xmllog   IN VARCHAR2                        --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                    --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2                       --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                       --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);                     --> Descrição do erro
  
  PROCEDURE pc_retorna_contas(pr_cdcooper       IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                             ,pr_cdconsultororg IN tbcc_consultor.cdconsultor%TYPE --> Codigo do Consultor
                             ,pr_cdconsultordst IN tbcc_consultor.cdconsultor%TYPE --> Codigo do Consultor
                             ,pr_xmllog         IN VARCHAR2                        --> XML com informações de LOG
                             ,pr_cdcritic       OUT PLS_INTEGER                    --> Código da crítica
                             ,pr_dscritic       OUT VARCHAR2                       --> Descrição da crítica
                             ,pr_retxml         IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                             ,pr_nmdcampo       OUT VARCHAR2                       --> Nome do campo com erro
                             ,pr_des_erro       OUT VARCHAR2);                     --> Descrição do erro
  
  PROCEDURE pc_transfere_conta(pr_cdcooper       IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                              ,pr_cdconsultordst IN tbcc_consultor.cdconsultor%TYPE --> Codigo do Consultor
                              ,pr_nrdconta       IN crapass.nrdconta%TYPE           --> Número da conta
                              ,pr_cdoperad       IN crapope.cdoperad%TYPE           --> Código do Operador
                              ,pr_xmllog         IN VARCHAR2                        --> XML com informações de LOG
                              ,pr_cdcritic       OUT PLS_INTEGER                    --> Código da crítica
                              ,pr_dscritic       OUT VARCHAR2                       --> Descrição da crítica
                              ,pr_retxml         IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                              ,pr_nmdcampo       OUT VARCHAR2                       --> Nome do campo com erro
                              ,pr_des_erro       OUT VARCHAR2);                     --> Descrição do erro
  
  PROCEDURE pc_consulta_conta(pr_cdcooper    IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                             ,pr_nrdconta    IN crapass.nrdconta%TYPE           --> Codigo da Agencia
                             ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                             ,pr_cdcritic    OUT PLS_INTEGER                    --> Código da crítica
                             ,pr_dscritic    OUT VARCHAR2                       --> Descrição da crítica
                             ,pr_retxml      IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                             ,pr_nmdcampo    OUT VARCHAR2                       --> Nome do campo com erro
                             ,pr_des_erro    OUT VARCHAR2);                     --> Descrição do erro

  PROCEDURE pc_consulta_operadores(pr_cdoperador  IN crapope.cdoperad%TYPE           --> Codigo do Operador
                                  ,pr_nmoperador  IN crapope.nmoperad%TYPE           --> Nome do Operador
                                  ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                                  ,pr_cdcritic    OUT PLS_INTEGER                    --> Código da crítica
                                  ,pr_dscritic    OUT VARCHAR2                       --> Descrição da crítica
                                  ,pr_retxml      IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                                  ,pr_nmdcampo    OUT VARCHAR2                       --> Nome do campo com erro
                                  ,pr_des_erro    OUT VARCHAR2);                     --> Descrição do erro

  PROCEDURE pc_consulta_agencias(pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo do Operador
                                ,pr_nmextage  IN crapage.nmextage%TYPE --> Nome do Operador
                                ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro  OUT VARCHAR2);           --> Descrição do erro
  
  PROCEDURE pc_consulta_consultores_org(pr_cdconsultororg IN tbcc_consultor.cdconsultor%TYPE --> Codigo do Consultor
                                       ,pr_cdoperadororg  IN crapope.cdoperad%TYPE           --> Codigo do Operador
                                       ,pr_nmoperadororg  IN crapope.nmoperad%TYPE           --> Nome do Operador
                                       ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                                       ,pr_cdcritic    OUT PLS_INTEGER                    --> Código da crítica
                                       ,pr_dscritic    OUT VARCHAR2                       --> Descrição da crítica
                                       ,pr_retxml      IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                                       ,pr_nmdcampo    OUT VARCHAR2                       --> Nome do campo com erro
                                       ,pr_des_erro    OUT VARCHAR2);                     --> Descrição do erro

  PROCEDURE pc_consulta_consultores_dst(pr_cdconsultordst IN tbcc_consultor.cdconsultor%TYPE --> Codigo do Consultor
                                       ,pr_cdoperadordst  IN crapope.cdoperad%TYPE           --> Codigo do Operador
                                       ,pr_nmoperadordst  IN crapope.nmoperad%TYPE           --> Nome do Operador
                                       ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                                       ,pr_cdcritic    OUT PLS_INTEGER                    --> Código da crítica
                                       ,pr_dscritic    OUT VARCHAR2                       --> Descrição da crítica
                                       ,pr_retxml      IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                                       ,pr_nmdcampo    OUT VARCHAR2                       --> Nome do campo com erro
                                       ,pr_des_erro    OUT VARCHAR2);                     --> Descrição do erro

  PROCEDURE pc_ativa_inativa_consultor(pr_cdcooper IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                                      ,pr_cdconsul IN tbcc_consultor.cdconsultor%TYPE --> Código do Consultor
                                      ,pr_xmllog   IN VARCHAR2                        --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER                    --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2                       --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2                       --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);                     --> Descrição do erro
  
  PROCEDURE pc_consulta_consultores(pr_cdconsultor IN tbcc_consultor.cdconsultor%TYPE --> Codigo do Consultor
                                   ,pr_cdoperador  IN crapope.cdoperad%TYPE           --> Codigo do Operador
                                   ,pr_nmoperador  IN crapope.nmoperad%TYPE           --> Nome do Operador
                                   ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                                   ,pr_cdcritic    OUT PLS_INTEGER                    --> Código da crítica
                                   ,pr_dscritic    OUT VARCHAR2                       --> Descrição da crítica
                                   ,pr_retxml      IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                                   ,pr_nmdcampo    OUT VARCHAR2                       --> Nome do campo com erro
                                   ,pr_des_erro    OUT VARCHAR2);                     --> Descrição do erro
  
  -- Rotina para gerar impressao de declaracao de pessoa exposta politicamente
  PROCEDURE pc_imp_dec_pep(pr_tpexposto        IN pls_integer
                          ,pr_cdocpttl         IN pls_integer
                          ,pr_cdrelacionamento IN pls_integer
                          ,pr_dtinicio         IN VARCHAR2
                          ,pr_dttermino        IN VARCHAR2
                          ,pr_nmempresa        IN VARCHAR2
                          ,pr_nrcnpj_empresa   IN VARCHAR2
                          ,pr_nmpolitico       IN VARCHAR2
                          ,pr_nrcpf_politico   IN VARCHAR2
                          ,pr_nmextttl         IN VARCHAR2
                          ,pr_rsocupa          IN VARCHAR2
                          ,pr_nrcpfcgc         IN VARCHAR2
                          ,pr_dsrelacionamento IN VARCHAR2
                          ,pr_nrdconta         IN VARCHAR2
                          ,pr_cidade           IN VARCHAR2

                          ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                          ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                          ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                          ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                          ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro  OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_email_troca_pa(pr_cdcooper IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                             ,pr_nrdconta IN crapass.nrdconta%TYPE           --> Numero da conta
                             ,pr_cdageant IN crapass.cdagenci%TYPE           --> Codigo da agencia anterior
                             ,pr_cdagenci IN crapass.cdagenci%TYPE           --> Codigo da agencia nova
                             ,pr_xmllog   IN VARCHAR2                        --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER                    --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2                       --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                       --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);                     --> Descrição do erro

  -- Retorna se cheque tem devolucao automatica ou nao
  PROCEDURE pc_verifica_sit_dev(pr_cdcooper IN  crapcop.cdcooper%TYPE, --> Cooperativa
                                 pr_nrdconta IN  crapass.nrdconta%TYPE, --> Conta/Dv
                                 pr_flgdevolu_autom OUT PLS_INTEGER);    --> Devolucao automatica ou nao

  -- Retorna se cheque tem devolucao automatica ou nao, por XML
  PROCEDURE pc_verifica_sit_dev_xml(pr_cdcooper IN  crapcop.cdcooper%TYPE, --> Cooperativa
                                     pr_nrdconta IN  crapass.nrdconta%TYPE, --> Conta/Dv
                                     pr_xmllog   IN VARCHAR2,           --> XML com informações de LOG
                                     pr_cdcritic OUT PLS_INTEGER,       --> Código da crítica
                                     pr_dscritic OUT VARCHAR2,          --> Descrição da crítica
                                     pr_retxml   IN OUT NOCOPY XMLType, --> Arquivo de retorno do XML
                                     pr_nmdcampo OUT VARCHAR2,          --> Nome do campo com erro
                                     pr_des_erro OUT VARCHAR2);         --> Erros do processo                             
                                     
  -- Gravar registros na tabela tbchq_param_conta
  PROCEDURE pc_grava_tbchq_param_conta(pr_cddopcao IN VARCHAR2,               --> Opcao I/A
                                       pr_cdcooper IN  crapcop.cdcooper%TYPE, --> Cooperativa
                                       pr_nrdconta IN  crapass.nrdconta%TYPE, --> Conta/Dv
                                       pr_flgdevolu_autom IN NUMBER,          --> Devolve automatico ou nao
                                       pr_cdoperad IN VARCHAR2,               --> Operador
                                       pr_cdopecor IN VARCHAR2,               --> Operador Coordenador
                                       pr_dscritic OUT VARCHAR2);             --> Critica
                                       
  -- Gravar registros na tabela tbchq_param_conta, por xml
  PROCEDURE pc_grava_tbchq_param_conta_xml(pr_cddopcao IN VARCHAR2,               --> Opcao I/A
                                           pr_cdcooper IN  crapcop.cdcooper%TYPE, --> Cooperativa
                                           pr_nrdconta IN  crapass.nrdconta%TYPE, --> Conta/Dv
                                           pr_flgdevolu_autom IN NUMBER,          --> Devolve automatico ou nao
                                           pr_cdoperad IN VARCHAR2,               --> Operador
                                           pr_cdopecor IN VARCHAR2,               --> Operador Coordenador
                                           pr_xmllog   IN VARCHAR2,               --> XML com informações de LOG
                                           pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                           pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                           pr_retxml   IN OUT NOCOPY XMLType,     --> Arquivo de retorno do XML
                                           pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                           pr_des_erro OUT VARCHAR2);             --> Erros do processo   

  PROCEDURE pc_busca_cidades(pr_idcidade     IN crapmun.idcidade%TYPE --> Identificador unico do cadstro de cidade
                            ,pr_cdcidade     IN crapmun.cdcidbge%TYPE --> Codigo da cidade CETIP/IBGE/CORREIOS/SFN
                            ,pr_dscidade     IN crapmun.dscidade%TYPE --> Nome da cidade
                            ,pr_cdestado     IN crapmun.cdestado%TYPE --> Codigo da UF
                            ,pr_infiltro     IN PLS_INTEGER --> 1-CETIP / 2-IBGE / 3-CORREIOS / 4-SFN
                            ,pr_intipnom     IN PLS_INTEGER --> 1-SEM ACENTUACAO / 2-COM ACENTUACAO
                            ,pr_tab_crapmun OUT typ_tab_crapmun --> PLTABLE com os dados
                            ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic    OUT VARCHAR2); --> Descricao da critica

  PROCEDURE pc_lista_cidades(pr_idcidade IN crapmun.idcidade%TYPE --> Identificador unico do cadstro de cidade
                            ,pr_cdcidade IN crapmun.cdcidbge%TYPE --> Codigo da cidade CETIP/IBGE/CORREIOS/SFN
                            ,pr_dscidade IN crapmun.dscidade%TYPE --> Nome da cidade
                            ,pr_cdestado IN crapmun.cdestado%TYPE --> Codigo da UF
                            ,pr_infiltro IN PLS_INTEGER           --> 1-CETIP / 2-IBGE / 3-CORREIOS / 4-SFN
                            ,pr_intipnom IN PLS_INTEGER           --> 1-SEM ACENTUACAO / 2-COM ACENTUACAO
                            ,pr_nriniseq IN PLS_INTEGER           --> Numero inicial do registro para enviar
                            ,pr_nrregist IN PLS_INTEGER           --> Numero de registros que deverao ser retornados
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);           --> Erros do processo 

	-- Function para retornar código da cidade
	FUNCTION fn_busca_codigo_cidade(pr_cdestado IN crapmun.cdestado%TYPE
		                             ,pr_dscidade IN crapmun.dscidade%TYPE) RETURN INTEGER;

  -- Procedimento para carga do arquivo Konviva para tabela com informações dos colaboradores
  PROCEDURE pc_integra_colaboradores;

END CADA0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CADA0003 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0003
  --  Sistema  : Rotinas acessadas pelas telas de cadastros Web
  --  Sigla    : CADA
  --  Autor    : Andrino Carlos de Souza Junior - RKAM
  --  Data     : Julho/2014.                   Ultima atualizacao: 04/08/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas utilizadas para as telas MATRIC, CONTAS e ATENDA referente a cadastros
  --
  -- Alteracoes: 26/11/2015 - Ajuste na Duplicacao de conta. Colocar a DTMVTOAN na CRAPSDA
  --               
  --             04/12/2015 - Inclusao de parametro pr_flserasa na procedure pc_busca_cnae. (Jaison/Andrino)
  --
  --             14/01/2016 - #350828 Rotina pc_imp_dec_pep para gerar impressao de declaracao de pessoa exposta politicamente (Carlos)
  --
  --             01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
  --                          Transferencia entre PAs (Heitor - RKAM)
  --
  --
  --             11/02/2016 - Correcao nos parametros das procedures de consulta de operadores
  --                          Chamado 385409 (Heitor - RKAM)
  --
  --             29/02/2016 - Trocando o campo flpolexp para inpolexp conforme
  --                          solicitado no chamado 402159 (Kelvin)
  --
  --             17/03/2016 - Ajuste na rotina pc_lista_cred_recebidos para buscar apenas 
  --                          lancamentos com históricos específicos, conforme solicitado                           
  --                          no chamado 417965 (Kelvin).
  -- 
  --             06/05/2016 - Removendo lixo das consultas anteriores na variável 
  --                          de cotas minimas na rotina pc_duplica_cont, para RESOLVER 
  --                          o problema do chamado 441211. (Kelvin)
  --             17/06/2016 - Inclusão de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)
  --
  --             02/08/2016 - Inclusao insitage 3-Temporariamente Indisponivel. 
  --                          Criacao da pc_busca_cidades. (Jaison/Anderson)
  --
  --             19/08/2016 - Ajustes referentes a Melhoria 69 - Devolucao automatica 
  --                          de cheques (Lucas Ranghetti #484923)
  --
  --             03/11/2016 - Ajuste realizado na fn_produto_habilitado para validar contas de 
  --                          assinatura multiplas, onde por acidente foi comentado no cursor
  --                          uma regra que não incluia as assinaturas multiplas, conforme 
  --                          solicitado no chamado 548898. (Kelvin)                              
  --
  --             16/11/2016 - Inclusao do UPPER(dscnae) na pesquisa por texto. (Jaison/Anderson)
  --
  --             29/11/2016 - Retirado COMMIT da procedure pc_grava_tbchq_param_conta
  --                          pois estava ocasionando problemas na abertura de contas 
  --                          na MATRIC criando registros com PA zerado (Tiago/Thiago).
  --
  --			 19/01/2016 - Adicionada function fn_busca_codigo_cidade. (Reinert)
  --
  --             21/02/2017 - Removido um dos meses exibido pela rotina pc_lista_cred_recebidos,
  --                          pois a tela é semestral e estava sendo exibido 7 meses, conforme 
  --                          solicitadono chamado 599051. (Kelvin)                            
  --                          
  --
  --             21/02/2017 - Ajuste para tratar os valores a serem enviados para
  --                          geração do relatório
  --                          (Adriano - SD 614408).
  --                         
  --             17/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
  --
  --             25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
  --		                  crapass, crapttl, crapjur 
  -- 						 (Adriano - P339).
  --
  --             04/08/2017 - Movido a rotina pc_busca_cnae para a TELA_CADCNA (Adriano).
  --
  --             28/08/2017 - Criando opcao de solicitar relacionamento caso cnpj informado
  --                          esteja cadastrado na cooperativa. (Kelvin)
  ---------------------------------------------------------------------------------------------------------------

  CURSOR cr_tbchq_param_conta(pr_cdcooper crapcop.cdcooper%TYPE
                             ,pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT tbchq.flgdevolu_autom
      FROM tbchq_param_conta tbchq
     WHERE tbchq.cdcooper = pr_cdcooper
       AND tbchq.nrdconta = pr_nrdconta;
    rw_tbchq_param_conta cr_tbchq_param_conta%ROWTYPE;


  -- Rotina para buscar o relacionamento de responsavel legal para execucao via progress
  PROCEDURE pc_busca_rlc_rsp_legal(pr_cdrelacionamento IN tbgen_cnae.cdcnae%TYPE --> Codigo do CNAE
                                  ,pr_dsrelacionamento IN tbgen_cnae.dscnae%TYPE --> Descricao do CNAE
                                  ,pr_retxml           OUT CLOB                  --> Arquivo de retorno do XML
                                  ,pr_cdcritic         OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic         OUT VARCHAR2) IS          --> Descrição da crítica
    -- Variaveis de retorno
    vr_xmllog   VARCHAR2(500);
    vr_retxml   XMLType;
    vr_nmdcampo VARCHAR2(500);
    vr_des_erro VARCHAR2(500);
  BEGIN
    -- Chama a rotina original
    pc_busca_rlc_rsp_legal_web(pr_cdrelacionamento => pr_cdrelacionamento
                              ,pr_dsrelacionamento => pr_dsrelacionamento
                              ,pr_nriniseq         => 1
                              ,pr_nrregist         => 99999
                              ,pr_xmllog           => NULL
                              ,pr_cdcritic         => pr_cdcritic
                              ,pr_dscritic         => pr_dscritic
                              ,pr_retxml           => vr_retxml
                              ,pr_nmdcampo         => vr_nmdcampo
                              ,pr_des_erro         => vr_des_erro);
    -- Se nao ocorreu erro efetua a gravacao na tabela de interface
    IF pr_cdcritic IS NULL AND pr_dscritic IS NULL THEN
      pr_retxml := vr_retxml.getclobval();
    END IF;

  END;

  -- Rotina para buscar o relacionamento de responsavel legal
  PROCEDURE pc_busca_rlc_rsp_legal_web(pr_cdrelacionamento IN tbgen_cnae.cdcnae%TYPE --> Codigo do CNAE
                                      ,pr_dsrelacionamento IN tbgen_cnae.dscnae%TYPE --> Descricao do CNAE
                                      ,pr_nriniseq         IN PLS_INTEGER            --> Numero inicial do registro para enviar
                                      ,pr_nrregist         IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                                      ,pr_xmllog           IN VARCHAR2               --> XML com informações de LOG
                                      ,pr_cdcritic         OUT PLS_INTEGER           --> Código da crítica
                                      ,pr_dscritic         OUT VARCHAR2              --> Descrição da crítica
                                      ,pr_retxml           IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                      ,pr_nmdcampo         OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro         OUT VARCHAR2) IS          --> Erros do processo

      -- Cursor sobre a tabela do CNAE
      CURSOR cr_rlc_resp_legal IS
        SELECT cdrelacionamento,
               gene0007.fn_caract_acento(dsrelacionamento) dsrelacionamento,
               count(1) over() retorno
          FROM tbcadast_relacion_resp_legal
         WHERE cdrelacionamento = decode(nvl(pr_cdrelacionamento,0),0,cdrelacionamento, pr_cdrelacionamento)
           AND (trim(pr_dsrelacionamento) IS NULL
            OR  dsrelacionamento LIKE '%'||pr_dsrelacionamento||'%')
         ORDER BY cdrelacionamento;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_posreg   PLS_INTEGER := 0;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
    BEGIN

        -- Monta documento XML de ERRO
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

        -- Loop sobre a tabela de relacionamentos
        FOR rw_rlc_resp_legal IN cr_rlc_resp_legal LOOP

          -- Incrementa o contador de registros
          vr_posreg := vr_posreg + 1;

          -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
          IF vr_posreg = 1 THEN
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<Relacionamento qtregist="' || rw_rlc_resp_legal.retorno || '">');
          END IF;

          -- Enviar somente se a linha for superior a linha inicial
          IF nvl(pr_nriniseq,0) <= vr_posreg THEN

            -- Carrega os dados
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<inf>'||
                                                            '<cdrelacionamento>' || rw_rlc_resp_legal.cdrelacionamento ||'</cdrelacionamento>'||
                                                            '<dsrelacionamento>' || rw_rlc_resp_legal.dsrelacionamento ||'</dsrelacionamento>'||
                                                         '</inf>');
            vr_contador := vr_contador + 1;
          END IF;

          -- Deve-se sair se o total de registros superar o total solicitado
          EXIT WHEN vr_contador > nvl(pr_nrregist,99999);

        END LOOP;

        -- Se nao possuir nenhum registro, envia a quantidade de registros zerada
        IF vr_posreg = 0 THEN
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<Relacionamento qtregist="0">');
        END IF;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</Relacionamento></Dados>'
                               ,pr_fecha_xml      => TRUE);

        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na busca do Rlc Resp. Legal: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_busca_rlc_rsp_legal_web;


  -- Rotina geral de insert, update, delete da tela ATENDA da opção Atendimento SAC
  PROCEDURE pc_registro_servicos(pr_cddopcao      IN VARCHAR2              --> Tipo de acao que sera executada (A - ALteracao / C - Consulta / E - Exclur / I - Inclur)
                                ,pr_nrdconta      IN crapcbr.cdbircon%TYPE --> Numero da conta
                                ,pr_dtatendimento IN VARCHAR2              --> Data do atendimento
                                ,pr_hratendimento IN VARCHAR2              --> Hora do atendimento
                                ,pr_cdservico     IN tbsac_registro_servico.cdservico%TYPE --> Codigo do servico solicitado
                                ,pr_dsservico     IN tbsac_registro_servico.dsservico_solicitado%TYPE --> Descricao do servico solicitado
                                ,pr_xmllog        IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic      OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic      OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml        IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo      OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro      OUT VARCHAR2) IS         --> Erros do processo

    -- Selecionar os dados do atendimento SAC
    CURSOR cr_registro(pr_cdcooper      IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta      IN crapass.nrdconta%TYPE
                      ,pr_dtatendimento IN VARCHAR2
                      ,pr_hratendimento IN VARCHAR2) IS
    SELECT cdcooper
          ,nrdconta
          ,TO_CHAR(dtatendimento,'DD/MM/YYYY') dtatendimento
          ,TO_CHAR(dtatendimento,'HH24:MI') hratendimento
          ,cdoperad
          ,cdservico
          ,dsservico_solicitado
      FROM tbsac_registro_servico
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = DECODE(nvl(pr_nrdconta,0),0,nrdconta,pr_nrdconta)
       AND TO_CHAR(dtatendimento,'DD/MM/YYYY') = DECODE(pr_dtatendimento,NULL,TO_CHAR(dtatendimento,'DD/MM/YYYY'),pr_dtatendimento)
       AND TO_CHAR(dtatendimento,'HH24:MI') = DECODE(pr_hratendimento,NULL,TO_CHAR(dtatendimento,'HH24:MI'),pr_hratendimento)
           ORDER BY dtatendimento DESC;
    rw_registro cr_registro%ROWTYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Variaveis de log
    vr_cdoperad VARCHAR2(100);
    vr_cdcooper NUMBER;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis gerais
    vr_dtatendimento DATE;

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

  BEGIN

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

      --Verifica se foi passado uma conta
      IF pr_nrdconta = 0     OR
         pr_nrdconta IS NULL THEN

        vr_dscritic := 'Conta invalida.';
        pr_nmdcampo := 'dtatendimento';

        RAISE vr_exc_saida;

      END IF;

      --Verifica se foi passado uma opcao
      IF pr_cddopcao = ' '   OR
         pr_cddopcao IS NULL THEN

        vr_dscritic := 'Opcao invalida.';
        pr_nmdcampo := 'dtatendimento';

        RAISE vr_exc_saida;

      END IF;

      --Verifica se foi passado um servico
      IF pr_cdservico = 0     OR
         pr_cdservico IS NULL THEN

        vr_dscritic := 'Codigo do servico invalido.';
        pr_nmdcampo := 'cdservico';

        RAISE vr_exc_saida;

      END IF;

      --Verifica se foi passado uma data
      IF pr_dtatendimento = ' '   OR
         pr_dtatendimento IS NULL THEN

        vr_dscritic := 'Data invalida.';
        pr_nmdcampo := 'dtatendimento';

        RAISE vr_exc_saida;

      END IF;

      --Verifica se foi passado uma data valida
      BEGIN

        vr_dtatendimento:= TO_DATE(pr_dtatendimento,'DD/MM/YYYY');

      EXCEPTION
        WHEN OTHERS THEN

          vr_dscritic := 'Data invalida.';
          pr_nmdcampo := 'dtatendimento';

          RAISE vr_exc_saida;
      END;

      --Verifica se foi passado um horario valido
      BEGIN

        vr_dtatendimento:= TO_DATE(pr_hratendimento,'hh24:mi');

      EXCEPTION
        WHEN OTHERS THEN

          vr_dscritic := 'Horario invalido.';
          pr_nmdcampo := 'hratendimento';

          RAISE vr_exc_saida;
      END;

      OPEN cr_registro(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_dtatendimento => pr_dtatendimento
                      ,pr_hratendimento => pr_hratendimento);

      FETCH cr_registro INTO rw_registro;

      -- Se não encontrar
      IF cr_registro%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_registro;

        IF pr_cddopcao <> 'I' THEN

          vr_dscritic := 'Atividade nao econtrada.';
          pr_nmdcampo := 'dtatendimento';

          RAISE vr_exc_saida;

        END IF;

      ELSE
        -- Fechar o cursor
        CLOSE cr_registro;

        IF pr_cddopcao = 'I' THEN

          vr_dscritic := 'Ja existe atividade cadastrada para esta data/hora.';
          pr_nmdcampo := 'dtatendimento';

          RAISE vr_exc_saida;

        END IF;
      END IF;

      -- Verifica o tipo de acao que sera executada
      CASE pr_cddopcao
        WHEN 'A' THEN -- Alteracao

          BEGIN
            -- Atualizacao de registro de atividade
            UPDATE tbsac_registro_servico
               SET cdservico = pr_cdservico
                  ,dsservico_solicitado = pr_dsservico
             WHERE cdcooper = vr_cdcooper
               AND nrdconta = pr_nrdconta
               AND TO_CHAR(dtatendimento,'DD/MM/YYYY') = pr_dtatendimento
               AND TO_CHAR(dtatendimento,'HH24:MI') = pr_hratendimento;

          -- Verifica se houve problema na atualizacao do registro
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao atualizar TBSAC_REGISTRO_SERVICO: ' || sqlerrm;
              pr_nmdcampo := 'dtatendimento';

              RAISE vr_exc_saida;

          END;

        WHEN 'E' THEN -- Exclusao

          -- Efetua a exclusao do atendimento SAC
          BEGIN
            DELETE tbsac_registro_servico
             WHERE cdcooper = vr_cdcooper
               AND nrdconta = pr_nrdconta
               AND TO_CHAR(dtatendimento,'DD/MM/YYYY') = pr_dtatendimento
               AND TO_CHAR(dtatendimento,'HH24:MI') = pr_hratendimento;

          -- Verifica se houve problema na delecao do registro
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao excluir TBSAC_REGISTRO_SERVICO: ' || sqlerrm;
              pr_nmdcampo := 'dtatendimento';

              RAISE vr_exc_saida;
          END;

        WHEN 'I' THEN -- Inclusao

          -- Efetua a inclusao do atendimento SAC
          BEGIN
            INSERT INTO tbsac_registro_servico(cdcooper
                                              ,nrdconta
                                              ,dtatendimento
                                              ,cdoperad
                                              ,cdservico
                                              ,dsservico_solicitado)
                  VALUES(vr_cdcooper
                        ,pr_nrdconta
                        ,to_date(pr_dtatendimento||pr_hratendimento,'dd/mm/yyyyhh24:mi')
                        ,vr_cdoperad
                        ,pr_cdservico
                        ,pr_dsservico);
          -- Verifica se houve problema na insercao de registros
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao inserir TBSAC_REIGSTRO_SERVICO: ' || sqlerrm;
              pr_nmdcampo := 'dtatendimento';

              RAISE vr_exc_saida;

          END;

      END CASE;

  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em TBSAC_REGISTRO_SERVICO: ' || SQLERRM;
      pr_nmdcampo := 'dtatendimento';

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_registro_servicos;


  -- Rotina consultar servicos
  PROCEDURE pc_busca_servicos_ativos(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - ALteracao / C - Consulta / E - Exclur / I - Inclur)
                                    ,pr_nrdconta IN crapcbr.cdbircon%TYPE --> Numero da conta
                                    ,pr_nrregist IN INTEGER               --Numero Registros
                                    ,pr_nriniseq IN INTEGER               --Numero Sequencia Inicial
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

    -- Selecionar os dados do atendimento SAC
    CURSOR cr_registro(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT tbsac_registro_servico.cdcooper
          ,tbsac_registro_servico.nrdconta
          ,TO_CHAR(tbsac_registro_servico.dtatendimento,'DD/MM/YYYY') dataAtendimento
          ,TO_CHAR(tbsac_registro_servico.dtatendimento,'HH24:MI') horaAtendimento
          ,tbsac_registro_servico.cdoperad
          ,tbsac_registro_servico.cdservico
          ,tbsac_registro_servico.dsservico_solicitado
          ,tbsac_servico.nmservico
          ,(crapope.cdoperad || ' - ' || crapope.nmoperad) nmoperad
      FROM tbsac_servico
          ,crapope
          ,tbsac_registro_servico
     WHERE tbsac_registro_servico.cdservico = tbsac_servico.cdservico
       AND tbsac_registro_servico.cdcooper  = crapope.cdcooper
       AND tbsac_registro_servico.cdoperad  = crapope.cdoperad
       AND tbsac_registro_servico.cdcooper  = pr_cdcooper
       AND tbsac_registro_servico.nrdconta  = pr_nrdconta
           ORDER BY dtatendimento DESC;
    rw_registro cr_registro%ROWTYPE;

    --Variaveis Locais
    vr_qtregist INTEGER;
    vr_nrregist INTEGER := pr_nrregist;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Variaveis de log
    vr_cdoperad VARCHAR2(100);
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis gerais
    vr_contador PLS_INTEGER := 0;

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

  BEGIN

    gene0004.pc_extrai_dados(pr_xml => pr_retxml
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

    --Verifica se foi passado uma conta
    IF pr_nrdconta = 0     OR
       pr_nrdconta IS NULL THEN

      vr_dscritic := 'Conta invalida.';

      RAISE vr_exc_saida;

    END IF;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    -- Loop sobre o cadastro de contingencia
    FOR rw_registro IN cr_registro(pr_cdcooper => vr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta) LOOP

      --Incrementar contador
      vr_qtregist:= nvl(vr_qtregist,0) + 1;

      -- controles da paginacao
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
        --Proximo
        CONTINUE;
      END IF;

      IF vr_nrregist > 0 THEN

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0        , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtatendimento', pr_tag_cont => rw_registro.dataAtendimento, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'hratendimento', pr_tag_cont => rw_registro.horaAtendimento, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdservico', pr_tag_cont => rw_registro.cdservico, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsservico_solicitado', pr_tag_cont => rw_registro.dsservico_solicitado, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmservico', pr_tag_cont => rw_registro.nmservico, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmoperad', pr_tag_cont => rw_registro.nmoperad, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_registro.cdoperad, pr_des_erro => vr_dscritic);

      END IF;

      vr_contador := vr_contador + 1;

      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1;

    END LOOP;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Dados'             --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    --Retorno OK
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_saida THEN

      --Gera mensagem de erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      --Retorno NOK
      pr_des_erro := 'NOK';

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      --Gera mensagem de erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em TBSAC_REGISTRO_SERVICO: ' || SQLERRM;

      --Retorno NOK
      pr_des_erro := 'NOK';

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_busca_servicos_ativos;

  -- Rotina para buscar os servicos de SAC para a tela ATENDA
  PROCEDURE pc_lista_servicos(pr_cdservico IN tbsac_servico.cdservico%TYPE --> Codigo do servico
                             ,pr_nmservico IN tbsac_servico.nmservico%TYPE --> Nome do servico
                             ,pr_nriniseq IN PLS_INTEGER                   --> Numero inicial do registro para enviar
                             ,pr_nrregist IN PLS_INTEGER                   --> Numero de registros que deverao ser retornados
                             ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo

    -- Cursor sobre os servicos do SAC
    CURSOR cr_servico IS
    SELECT cdservico
          ,GENE0007.fn_caract_acento(nmservico) nmservico
          ,COUNT(1) OVER() retorno
      FROM tbsac_servico
     WHERE cdservico = DECODE(nvl(pr_cdservico,0),0,cdservico, pr_cdservico)
       AND (TRIM(pr_nmservico) IS NULL
        OR nmservico LIKE '%'||pr_nmservico||'%')
           ORDER BY nmservico;

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;

    -- Variaveis gerais
    vr_contador PLS_INTEGER := 0;
    vr_posreg   PLS_INTEGER := 0;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB;

  BEGIN

    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

    -- Loop sobre a tabela de servicos do SAC
    FOR rw_servico IN cr_servico LOOP

      -- Incrementa o contador de registros
      vr_posreg := vr_posreg + 1;

      -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
      IF vr_posreg = 1 THEN
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<Servico qtregist="' || rw_servico.retorno || '">');
      END IF;

      -- Enviar somente se a linha for superior a linha inicial
      IF nvl(pr_nriniseq,0) <= vr_posreg THEN

        -- Carrega os dados
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<inf>'||
                                                        '<cdservico>' || rw_servico.cdservico ||'</cdservico>'||
                                                        '<nmservico>' || rw_servico.nmservico ||'</nmservico>'||
                                                     '</inf>');

        vr_contador := vr_contador + 1;

      END IF;

      -- Deve-se sair se o total de registros superar o total solicitado
      EXIT WHEN vr_contador > nvl(pr_nrregist,99999);

    END LOOP;

    -- Se nao possuir nenhum registro, envia a quantidade de registros zerada
    IF vr_posreg = 0 THEN
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Servico qtregist="0">');
    END IF;

    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</Servico></Dados>'
                           ,pr_fecha_xml      => TRUE);

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);

  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina PC_LISTA_SERVICOS: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_lista_servicos;


  -- Rotina para retornar as contas permitidas para duplicacao
  PROCEDURE pc_lista_contas(pr_cdcooper IN crapass.cdcooper%TYPE  --> Codigo da cooperativa
                           ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE  --> Numero do CPF / CGC do cooperado
                           ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

    
    CURSOR cr_tbcadast_pessoa(pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
      SELECT pss.dtconsulta_rfb dtconsultaRfb      
            ,pss.nrcpfcgc 
            ,pss.cdsituacao_rfb cdsituacaoRfb
            ,pss.nmpessoa
            ,pss.nmpessoa_receita nmpessoaReceita
            ,psf.tpsexo
            ,psf.dtnascimento
            ,psf.tpdocumento
            ,psf.nrdocumento
            ,psf.idorgao_expedidor idorgaoExpedidor
            ,psf.cduf_orgao_expedidor cdufOrgaoExpedidor
            ,psf.dtemissao_documento dtemissaoDocumento
            ,psf.tpnacionalidade
            ,psf.cdnacionalidade
            ,psf.inhabilitacao_menor inhabilitacaoMenor
            ,psf.dthabilitacao_menor dthabilitacaoMenor
            ,psf.cdestado_civil cdestadoCivil 
            ,pre.cdocupacao cdNaturezaOcupacao
            ,pre.nrcadastro cdCadastroEmpresa 
            ,pssMae.Nmpessoa nmmae
            ,pssConjugue.Nmpessoa nmconjugue
            ,pssPai.Nmpessoa nmpai
            ,munNaturalidade.dscidade naturalidadeDsCidade
            ,munNaturalidade.cdestado naturalidadeCdEstado
            ,(SELECT nrddd
                FROM (SELECT ptlComercialDdd.nrddd 
                            ,ptlComercialDdd.Idpessoa 
                        FROM tbcadast_pessoa_telefone ptlComercialDdd
                       WHERE ptlComercialDdd.tptelefone = 3
                       ORDER BY ptlComercialDdd.Idpessoa, ptlComercialDdd.Nrseq_Telefone)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) comercialNrddd 
            ,(SELECT Nrtelefone
                FROM (SELECT ptlComercialTelefone.Nrtelefone 
                            ,ptlComercialTelefone.Idpessoa 
                        FROM tbcadast_pessoa_telefone ptlComercialTelefone
                       WHERE ptlComercialTelefone.tptelefone = 3
                       ORDER BY ptlComercialTelefone.Idpessoa, ptlComercialTelefone.Nrseq_Telefone)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) comercialNrTelefone  
            ,(SELECT nrddd
                FROM (SELECT ptlResidencialDdd.nrddd 
                            ,ptlResidencialDdd.Idpessoa 
                        FROM tbcadast_pessoa_telefone ptlResidencialDdd
                       WHERE ptlResidencialDdd.tptelefone = 1
                       ORDER BY ptlResidencialDdd.Idpessoa, ptlResidencialDdd.Nrseq_Telefone)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) residencialNrddd                   
            
            ,(SELECT Nrtelefone
                FROM (SELECT ptlResidencialTelefone.Nrtelefone 
                            ,ptlResidencialTelefone.Idpessoa 
                        FROM tbcadast_pessoa_telefone ptlResidencialTelefone
                       WHERE ptlResidencialTelefone.tptelefone = 1
                       ORDER BY ptlResidencialTelefone.Idpessoa, ptlResidencialTelefone.Nrseq_Telefone)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) residencialNrTelefone                 
            ,(SELECT cdoperadora
                FROM (SELECT ptlCelularOperadora.cdoperadora 
                            ,ptlCelularOperadora.Idpessoa 
                        FROM tbcadast_pessoa_telefone ptlCelularOperadora
                       WHERE ptlCelularOperadora.tptelefone = 2
                       ORDER BY ptlCelularOperadora.Idpessoa, ptlCelularOperadora.Nrseq_Telefone)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) celularCdOperadora                                            
            ,(SELECT nrddd
                FROM (SELECT ptlCelularDdd.nrddd 
                            ,ptlCelularDdd.Idpessoa 
                        FROM tbcadast_pessoa_telefone ptlCelularDdd
                       WHERE ptlCelularDdd.tptelefone = 2
                       ORDER BY ptlCelularDdd.Idpessoa, ptlCelularDdd.Nrseq_Telefone)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) celularNrDdd            
            ,(SELECT Nrtelefone
                FROM (SELECT ptlCelularTelefone.Nrtelefone 
                            ,ptlCelularTelefone.Idpessoa 
                        FROM tbcadast_pessoa_telefone ptlCelularTelefone
                       WHERE ptlCelularTelefone.tptelefone = 2
                       ORDER BY ptlCelularTelefone.Idpessoa, ptlCelularTelefone.Nrseq_Telefone)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) celularNrTelefone
            ,(SELECT Dsemail
                FROM (SELECT pemEmail.Dsemail 
                            ,pemEmail.Idpessoa 
                        FROM tbcadast_pessoa_email pemEmail
                       ORDER BY pemEmail.Idpessoa, pemEmail.Nrseq_Email)
               WHERE Idpessoa = pss.idpessoa
                 AND ROWNUM = 1) dsdemail     
            ,penResidencial.nrcep residencialNrCep             
            ,penResidencial.nmlogradouro residencialNmLogradouro   
            ,penResidencial.nrlogradouro residencialNrLogradouro  
            ,penResidencial.dscomplemento residencialDsComplemento   
            ,penResidencial.nmbairro residencialNmBairro    
            ,munResidencial.Cdestado residencialCdEstado
            ,munResidencial.Dscidade residencialDsCidade    
            ,penResidencial.tporigem_cadastro residencialTporigem
            ,penCorrespondencia.nrcep correspondenciaNrCep             
            ,penCorrespondencia.nmlogradouro correspondenciaNmLogradouro   
            ,penCorrespondencia.nrlogradouro correspondenciaNrLogradouro  
            ,penCorrespondencia.dscomplemento correspondenciaDsComplemento   
            ,penCorrespondencia.nmbairro correspondenciaNmBairro    
            ,munCorrespondencia.Cdestado correspondenciaCdEstado
            ,munCorrespondencia.Dscidade correspondenciaDsCidade
            ,penCorrespondencia.tporigem_cadastro correspondenciaTporigem 
            ,penComercial.nrcep comercialNrCep             
            ,penComercial.nmlogradouro comercialNmLogradouro   
            ,penComercial.nrlogradouro comercialNrLogradouro  
            ,penComercial.dscomplemento comercialDsComplemento   
            ,penComercial.nmbairro comercialNmBairro    
            ,munComercial.Cdestado comercialCdEstado
            ,munComercial.Dscidade comercialDsCidade    
            ,penComercial.tporigem_cadastro comercialTporigem
            ,nac.dsnacion
            ,oxp.cdorgao_expedidor cdExpedidor
            ,pju.nmfantasia
            ,pju.nrinscricao_estadual nrInscricao
            ,pju.nrlicenca_ambiental nrLicenca
            ,pju.cdnatureza_juridica cdNatureza
            ,pju.cdsetor_economico cdSetor
            ,pju.cdramo_atividade cdRamo
            ,pju.Cdcnae
            ,pju.dtinicio_atividade dtInicioAtividade
        FROM tbcadast_pessoa pss
            ,tbcadast_pessoa_fisica psf
            ,tbcadast_pessoa_relacao prlConjugue
            ,tbcadast_pessoa pssConjugue
            ,tbcadast_pessoa_relacao prlPai
            ,tbcadast_pessoa pssPai
            ,tbcadast_pessoa_relacao prlMae
            ,tbcadast_pessoa pssMae
            ,crapmun munNaturalidade
            ,tbcadast_pessoa_endereco penResidencial
            ,crapmun munResidencial
            ,tbcadast_pessoa_endereco penCorrespondencia
            ,crapmun munCorrespondencia
            ,tbcadast_pessoa_endereco penComercial
            ,crapmun munComercial
            ,crapnac nac
            ,tbgen_orgao_expedidor oxp 
            ,tbcadast_pessoa_juridica pju 
            ,tbcadast_pessoa_renda pre
       WHERE psf.idpessoa(+)                  = pss.idpessoa
         AND prlConjugue.Idpessoa(+)          = pss.idpessoa
         AND prlConjugue.tprelacao(+)         = 1
         AND pssConjugue.Idpessoa(+)          = prlConjugue.Idpessoa_Relacao   
         AND prlPai.Idpessoa(+)               = pss.idpessoa
         AND prlPai.tprelacao(+)              = 3
         AND pssPai.Idpessoa(+)               = prlPai.Idpessoa_Relacao   
         AND prlMae.Idpessoa(+)               = pss.idpessoa
         AND prlMae.tprelacao(+)              = 4
         AND pssMae.Idpessoa(+)               = prlMae.Idpessoa_Relacao   
         AND munNaturalidade.idcidade(+)      = psf.cdnaturalidade  
         AND penResidencial.idpessoa(+)       = pss.idpessoa
         AND penResidencial.tpendereco(+)     = 10   
         AND munResidencial.Idcidade(+)       = penResidencial.Idcidade     
         AND penCorrespondencia.idpessoa(+)   = pss.idpessoa
         AND penCorrespondencia.tpendereco(+) = 13     
         AND munCorrespondencia.Idcidade(+)   = penCorrespondencia.Idcidade
         AND penComercial.idpessoa(+)         = pss.idpessoa
         AND penComercial.tpendereco(+)       = 9   
         AND munComercial.Idcidade(+)         = penComercial.Idcidade   
         AND nac.cdnacion(+)  = psf.cdnacionalidade
         AND oxp.idorgao_expedidor(+) = psf.idorgao_expedidor
         AND pju.idpessoa(+) = pss.idpessoa
         AND pre.idpessoa(+)           = pss.idpessoa 
         AND pre.nrseq_renda(+)        = 1            
         AND pss.nrcpfcgc = pr_nrcpfcgc;
       
      rw_tbcadast_pessoa cr_tbcadast_pessoa%ROWTYPE;
      
    -- Cursor sobre a tabela de associados que podem possuir contas duplicadas
    CURSOR cr_crapass IS
      SELECT nrdconta,
             dtadmiss
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrcpfcgc = pr_nrcpfcgc
         AND dtdemiss IS NULL -- Nao exibir demitidos
         AND dtelimin IS NULL -- Nao exibir contas que possuam valores eliminados
         AND cdsitdtl NOT IN (5,6,7,8) -- Nao exibir contas com prejuizo
         AND cdsitdtl NOT IN (2,4,6,8) -- Titular da conta bloqueado
       ORDER BY dtadmiss DESC;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      
      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_flgdpcnt      NUMBER;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
      -- Criar cabeçalho do XML
      
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      
      vr_flgdpcnt := 1; --Continua operacao normalmente.
      
      OPEN cr_tbcadast_pessoa(pr_nrcpfcgc);
        FETCH cr_tbcadast_pessoa
          INTO rw_tbcadast_pessoa;
        -- Criar cabeçalho do XML
        
        IF cr_tbcadast_pessoa%FOUND THEN          
          
          CLOSE cr_tbcadast_pessoa;          
          
          -- Loop sobre as versoes do questionario de microcredito
          FOR rw_crapass IN cr_crapass LOOP
            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => gene0002.fn_mask_conta(rw_crapass.nrdconta), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtadmiss', pr_tag_cont => to_char(rw_crapass.dtadmiss,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);

            vr_contador := vr_contador + 1;
            
          END LOOP; 
          
          IF vr_contador > 0 THEN
            vr_flgdpcnt := 2; --Duplicar conta
          ELSE
            
            vr_flgdpcnt := 3; --Relacionamento
            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'infcadastro', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dtconsultarfb', pr_tag_cont => to_char(rw_tbcadast_pessoa.dtconsultaRfb,'DD/MM/RRRR'),  pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => rw_tbcadast_pessoa.nrcpfcgc,  pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdsituacaoRfb', pr_tag_cont => rw_tbcadast_pessoa.cdsituacaoRfb, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmpessoa', pr_tag_cont => rw_tbcadast_pessoa.nmpessoa, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmpessoaReceita', pr_tag_cont => rw_tbcadast_pessoa.nmpessoaReceita,  pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'tpsexo', pr_tag_cont => rw_tbcadast_pessoa.tpsexo, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dtnascimento', pr_tag_cont => to_char(rw_tbcadast_pessoa.dtnascimento,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'tpdocumento', pr_tag_cont => rw_tbcadast_pessoa.tpdocumento, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrdocumento', pr_tag_cont => rw_tbcadast_pessoa.nrdocumento, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'idorgaoExpedidor', pr_tag_cont => rw_tbcadast_pessoa.idorgaoExpedidor,  pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdufOrgaoExpedidor', pr_tag_cont => rw_tbcadast_pessoa.cdufOrgaoExpedidor, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dtemissaoDocumento', pr_tag_cont => to_char(rw_tbcadast_pessoa.dtemissaoDocumento,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'tpnacionalidade', pr_tag_cont => rw_tbcadast_pessoa.tpnacionalidade, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'inhabilitacaoMenor', pr_tag_cont => rw_tbcadast_pessoa.inhabilitacaoMenor, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dthabilitacaoMenor', pr_tag_cont => to_char(rw_tbcadast_pessoa.dthabilitacaoMenor,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdestadoCivil', pr_tag_cont => rw_tbcadast_pessoa.cdestadoCivil, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmmae', pr_tag_cont => rw_tbcadast_pessoa.nmmae,  pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmconjugue', pr_tag_cont => rw_tbcadast_pessoa.nmconjugue, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmpai', pr_tag_cont => rw_tbcadast_pessoa.nmpai,  pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'naturalidadeDsCidade', pr_tag_cont => rw_tbcadast_pessoa.naturalidadeDsCidade, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'naturalidadeCdEstado', pr_tag_cont => rw_tbcadast_pessoa.naturalidadeCdEstado,  pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'residencialNrddd', pr_tag_cont => rw_tbcadast_pessoa.residencialNrddd, pr_des_erro => vr_dscritic);            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'comercialNrTelefone', pr_tag_cont => rw_tbcadast_pessoa.comercialNrTelefone, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'comercialNrddd', pr_tag_cont => rw_tbcadast_pessoa.comercialNrddd, pr_des_erro => vr_dscritic);            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'residencialNrTelefone', pr_tag_cont => rw_tbcadast_pessoa.residencialNrTelefone, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'celularCdOperadora', pr_tag_cont => rw_tbcadast_pessoa.celularCdOperadora, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'celularNrDdd', pr_tag_cont => rw_tbcadast_pessoa.celularNrDdd, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'celularNrTelefone', pr_tag_cont => rw_tbcadast_pessoa.celularNrTelefone, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'residencialNrCep', pr_tag_cont => rw_tbcadast_pessoa.residencialNrCep, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'residencialNmLogradouro', pr_tag_cont => rw_tbcadast_pessoa.residencialNmLogradouro, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'residencialNrLogradouro', pr_tag_cont => rw_tbcadast_pessoa.residencialNrLogradouro, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'residencialDsComplemento', pr_tag_cont => rw_tbcadast_pessoa.residencialDsComplemento, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'residencialNmBairro', pr_tag_cont => rw_tbcadast_pessoa.residencialNmBairro, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'residencialCdEstado', pr_tag_cont => rw_tbcadast_pessoa.residencialCdEstado, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'residencialDsCidade', pr_tag_cont => rw_tbcadast_pessoa.residencialDsCidade, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'residencialTporigem', pr_tag_cont => rw_tbcadast_pessoa.residencialTporigem, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'correspondenciaNrCep', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaNrCep, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'correspondenciaNmLogradouro', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaNmLogradouro, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'correspondenciaNrLogradouro', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaNrLogradouro, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'correspondenciaDsComplemento', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaDsComplemento, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'correspondenciaNmBairro', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaNmBairro, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'correspondenciaCdEstado', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaCdEstado, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'correspondenciaDsCidade', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaDsCidade, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'correspondenciaTporigem', pr_tag_cont => rw_tbcadast_pessoa.correspondenciaTporigem, pr_des_erro => vr_dscritic);            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'comercialNrCep', pr_tag_cont => rw_tbcadast_pessoa.comercialNrCep, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'comercialNmLogradouro', pr_tag_cont => rw_tbcadast_pessoa.comercialNmLogradouro, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'comercialNrLogradouro', pr_tag_cont => rw_tbcadast_pessoa.comercialNrLogradouro, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'comercialDsComplemento', pr_tag_cont => rw_tbcadast_pessoa.comercialDsComplemento, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'comercialNmBairro', pr_tag_cont => rw_tbcadast_pessoa.comercialNmBairro, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'comercialCdEstado', pr_tag_cont => rw_tbcadast_pessoa.comercialCdEstado, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'comercialDsCidade', pr_tag_cont => rw_tbcadast_pessoa.comercialDsCidade, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'comercialTporigem', pr_tag_cont => rw_tbcadast_pessoa.comercialTporigem, pr_des_erro => vr_dscritic);                        
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dsnacion', pr_tag_cont => rw_tbcadast_pessoa.dsnacion, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdExpedidor', pr_tag_cont => rw_tbcadast_pessoa.cdExpedidor, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dsdemail', pr_tag_cont => rw_tbcadast_pessoa.dsdemail, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nmfantasia', pr_tag_cont => rw_tbcadast_pessoa.nmfantasia, pr_des_erro => vr_dscritic);                                   
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrInscricao', pr_tag_cont => rw_tbcadast_pessoa.nrInscricao, pr_des_erro => vr_dscritic);            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'nrLicenca', pr_tag_cont => rw_tbcadast_pessoa.nrLicenca, pr_des_erro => vr_dscritic);            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdNatureza', pr_tag_cont => rw_tbcadast_pessoa.cdNatureza, pr_des_erro => vr_dscritic);            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdSetor', pr_tag_cont => rw_tbcadast_pessoa.cdSetor, pr_des_erro => vr_dscritic);            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdRamo', pr_tag_cont => rw_tbcadast_pessoa.cdRamo, pr_des_erro => vr_dscritic);            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdCnae', pr_tag_cont => rw_tbcadast_pessoa.cdCnae, pr_des_erro => vr_dscritic);            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'dtInicioAtividade', pr_tag_cont => to_char(rw_tbcadast_pessoa.dtInicioAtividade,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdNaturezaOcupacao', pr_tag_cont => rw_tbcadast_pessoa.cdNaturezaOcupacao, pr_des_erro => vr_dscritic);                         
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdNacionalidade', pr_tag_cont => rw_tbcadast_pessoa.cdNacionalidade, pr_des_erro => vr_dscritic);            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'infcadastro', pr_posicao => 0, pr_tag_nova => 'cdCadastroEmpresa', pr_tag_cont => rw_tbcadast_pessoa.cdCadastroEmpresa, pr_des_erro => vr_dscritic);            
             
          END IF;
            
        END IF;        
        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'flgopcao', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'flgopcao', pr_posicao => 0, pr_tag_nova => 'flgdpcnt', pr_tag_cont => vr_flgdpcnt, pr_des_erro => vr_dscritic);
      
    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_lista_conta: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_lista_contas;

  -- Rotina auxiliar para transferencia de contas
  PROCEDURE pc_transfere_cotas(pr_cdcooper     IN crapass.cdcooper%TYPE  --> Codigo da cooperativa
                              ,pr_nrdconta_org IN crapass.nrdconta%TYPE  --> Numero da conta de origem da copia
                              ,pr_nrdconta_dst IN crapass.nrdconta%TYPE  --> Numero da conta de destino da copia
                              ,pr_dtmvtolt     IN DATE                   --> Data do movimento
                              ,pr_vlcapmin     IN crapcot.vldcotas%TYPE  --> Capital minimo para transferencia de cotas
                              ,pr_cdcritic    OUT PLS_INTEGER            --> Código da crítica
                              ,pr_dscritic    OUT VARCHAR2) IS           --> Descrição da crítica

      -- Cursor sobre a tabela de lotes
      CURSOR cr_craplot IS
        SELECT tplotmov,
               dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrdolote,
               nrseqdig,
               vlinfodb,
               vlcompdb,
               ROWID
          FROM craplot
         WHERE craplot.cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND cdagenci = 1
           AND cdbccxlt = 100
           AND nrdolote = 8008;
      rw_craplot cr_craplot%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

    BEGIN
      -- Efetua o processo sobre a tabela de lote
      OPEN cr_craplot;
      FETCH cr_craplot INTO rw_craplot;
      IF cr_craplot%NOTFOUND THEN
        -- Insere a tabela de lote
        BEGIN
          INSERT INTO craplot
            (dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             tplotmov,
             cdcooper)
          VALUES
            (pr_dtmvtolt,
             1,
             100,
             8008,
             2,
             pr_cdcooper)
           RETURNING dtmvtolt,
                     cdagenci,
                     cdbccxlt,
                     nrdolote,
                     nrseqdig,
                     ROWID
                INTO rw_craplot.dtmvtolt,
                     rw_craplot.cdagenci,
                     rw_craplot.cdbccxlt,
                     rw_craplot.nrdolote,
                     rw_craplot.nrseqdig,
                     rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na CRAPLOT: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      ELSE
        IF rw_craplot.tplotmov <> 2 THEN
          vr_cdcritic := 62; -- Tipo de lote errado
          CLOSE cr_craplot;
          RAISE vr_exc_saida;
        END IF;
      END IF;
      CLOSE cr_craplot;

      -- Insere o lancamento de cotas / capital para a conta de origem
      BEGIN
        INSERT INTO craplct
          (cdcooper,
           dtmvtolt,
           cdagenci,
           cdbccxlt,
           nrdolote,
           nrdconta,
           nrdocmto,
           cdhistor,
           nrseqdig,
           vllanmto,
           nrctrpla,
           qtlanmfx)
         VALUES
          (pr_cdcooper,
           pr_dtmvtolt,
           1,
           100,
           8008,
           pr_nrdconta_org,
           rw_craplot.nrseqdig + 1,
           86,
           rw_craplot.nrseqdig + 1,
           pr_vlcapmin,
           0,
           0);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPLCT_org: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Atualiza a tabela de cotas da conta de origem
      BEGIN
        UPDATE crapcot
           SET vldcotas = vldcotas - pr_vlcapmin
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta_org;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPCOT_org: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Atualiza as variaveis do lote
      rw_craplot.vlinfodb := nvl(rw_craplot.vlinfodb,0) + pr_vlcapmin;
      rw_craplot.vlcompdb := nvl(rw_craplot.vlcompdb,0) + pr_vlcapmin;


      -- Insere o lancamento de cotas / capital para a conta de destino
      BEGIN
        INSERT INTO craplct
          (cdcooper,
           dtmvtolt,
           cdagenci,
           cdbccxlt,
           nrdolote,
           nrdconta,
           nrdocmto,
           cdhistor,
           nrseqdig,
           vllanmto,
           nrctrpla,
           qtlanmfx)
         VALUES
          (pr_cdcooper,
           pr_dtmvtolt,
           1,
           100,
           8008,
           pr_nrdconta_dst,
           rw_craplot.nrseqdig + 2,
           67,
           rw_craplot.nrseqdig + 2,
           pr_vlcapmin,
           0,
           0);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPLCT_dst: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Atualiza a tabela de cotas da conta de destino
      BEGIN
        UPDATE crapcot
           SET vldcotas = vldcotas + pr_vlcapmin
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta_dst;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPCOT_dst: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Atualiza a tabela de lotes
      BEGIN
        UPDATE craplot
           SET nrseqdig = nrseqdig + 2,
               qtinfoln = qtinfoln + 2,
               qtcompln = qtcompln + 2,
               vlinfocr = vlinfocr + pr_vlcapmin,
               vlcompcr = vlcompcr + pr_vlcapmin
         WHERE ROWID = rw_craplot.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPLOT: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_transfere_cotas: ' || SQLERRM;
  END pc_transfere_cotas;

  -- Rotina para duplicar a conta informada
  PROCEDURE pc_duplica_conta(pr_cdcooper     IN crapass.cdcooper%TYPE  --> Codigo da cooperativa
                            ,pr_nrdconta_org IN crapass.nrdconta%TYPE  --> Numero da conta de origem da copia
                            ,pr_nrdconta_dst IN crapass.nrdconta%TYPE  --> Numero da conta de destino da copia
                            ,pr_cdoperad IN  crapope.cdoperad%TYPE --> Operador que solicitou a duplicacao
                            ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

    /* ..........................................................................
    --
    --  Programa : pc_duplica_conta
    --  Sistema  : Rotinas acessadas pelas telas de cadastros Web
    --  Sigla    : CADA
    --  Autor    : 
    --  Data     :                      Ultima atualizacao: 24/07/2017
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Rotina para duplicar informações do cadastro do cooperado.
    --
    --  Alteracoes:  24/07/2017 - Alterar cdoedptl para idorgexp.
    --                            PRJ339-CRM  (Odirlei-AMcom)
    -- .............................................................................*/

      -- Cursor sobre a tabela de associados
      CURSOR cr_crapass IS
        SELECT inpessoa,
               nrcpfcgc,
               cdnacion,
               dsproftl,
               nmprimtl
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta_org;
      rw_crapass cr_crapass%ROWTYPE;

      -- Busca o telefone comercial para PJ
      CURSOR cr_craptfc IS
        SELECT nrdddtfc,
               nrtelefo
          FROM craptfc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta_org
           AND idseqttl = 1
           AND cdseqtfc = 1;
      rw_craptfc cr_craptfc%ROWTYPE;

      -- Cursor sobre a tabela de datas
      rw_crapdat  btch0001.cr_crapdat%ROWTYPE;

      -- Cursor sobre as matriculas
      CURSOR cr_crapmat IS
        SELECT vlcapini
          FROM crapmat
         WHERE cdcooper = pr_cdcooper
         ORDER BY progress_recid;
      rw_crapmat cr_crapmat%ROWTYPE;

      /* Cursor generico de parametrizacao */
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                       ,pr_nmsistem IN craptab.nmsistem%TYPE
                       ,pr_tptabela IN craptab.tptabela%TYPE
                       ,pr_cdempres IN craptab.cdempres%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE
                       ,pr_tpregist IN craptab.tpregist%TYPE) IS
        SELECT tab.dstextab
          FROM craptab tab
         WHERE tab.cdcooper = pr_cdcooper
           AND upper(tab.nmsistem) = pr_nmsistem
           AND upper(tab.tptabela) = pr_tptabela
           AND tab.cdempres = pr_cdempres
           AND upper(tab.cdacesso) = pr_cdacesso
           AND tab.tpregist = pr_tpregist;
      rw_craptab cr_craptab%ROWTYPE;

      -- Cursor para verificar se existe recadastro na conta
      CURSOR cr_crapalt(pr_dtrecadast PLS_INTEGER) IS
        SELECT 1
          FROM crapalt a
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta_org
           AND tpaltera = 1
           AND a.dtaltera > rw_crapdat.dtmvtolt - pr_dtrecadast;
      rw_crapalt cr_crapalt%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_tab_erro      gene0001.typ_tab_erro;
      vr_des_reto      VARCHAR2(10);


      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_vlcapmin crapmat.vlcapini%TYPE; --> Valor de capital minumo para a conta

      -- Variaveis para a duplicacao da conta
      vr_numero VARCHAR2(10);
      vr_nrdconta crapass.nrdconta%TYPE;
      vr_nrcalcul crapass.nrdconta%TYPE;
      vr_calculo  PLS_INTEGER;
      vr_peso     PLS_INTEGER;
      vr_resto    PLS_INTEGER;
      vr_digito   PLS_INTEGER;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

    BEGIN
      -- Sera o modulo de execucao
      GENE0001.pc_informa_acesso(pr_module => 'MATRIC'
                                ,pr_action => 'CADA0003.pc_duplica_conta');

      -- Busca a data do sistema
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      -- Busca os dados do associado
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;
      -- Se nao encontrar o associado, encerra o programa com erro
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Conta de origem inexistente!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapass;

      -- Le tabela de dias de recadastro
      OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'GENERI'
                     ,pr_cdempres => pr_cdcooper
                     ,pr_cdacesso => 'ATUALIZCAD'
                     ,pr_tpregist => 0);
      FETCH cr_craptab INTO rw_craptab;
      CLOSE cr_craptab;

      -- Verifica se a conta esta recadastrada
      OPEN cr_crapalt(rw_craptab.dstextab);
      FETCH cr_crapalt INTO rw_crapalt;
      IF cr_crapalt%NOTFOUND THEN
        CLOSE cr_crapalt;
        vr_dscritic := 'Conta de origem '||gene0002.fn_mask_conta(pr_nrdconta_org)|| ' precisa ser recadastrada antes da duplicacao!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapalt;

      -- Cria a tabela de transferencia de contas
      BEGIN
        INSERT INTO craptrf
          (cdcooper,
           nrdconta,
           nrsconta,
           dttransa,
           insittrs,
           tptransa,
           cdoperad,
           hrtransa)
         VALUES
          (pr_cdcooper,
           pr_nrdconta_org,
           pr_nrdconta_dst,
           rw_crapdat.dtmvtolt,
           2, --Feito
           2, --Duplicacao
           pr_cdoperad,
           to_char(SYSDATE,'sssss'));
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao criar CRAPTRF: '||SQLERRM;
      END;

      /*** Cria Conta de Investimento ***/
      vr_nrcalcul := 600000000 + pr_nrdconta_dst;
      vr_calculo  := 0;
      vr_peso     := 9;
      FOR vr_posicao IN REVERSE 1..(LENGTH(vr_nrcalcul) - 1) LOOP

          vr_calculo := vr_calculo + (SUBSTR(vr_nrcalcul,
                                       vr_posicao,1)) * vr_peso;
          vr_peso := vr_peso - 1;
          IF vr_peso = 1 THEN
            vr_peso := 9;
          END IF;
      END LOOP;
      vr_resto := MOD(vr_calculo,11);
      IF vr_resto > 9   THEN
        vr_digito := 0;
      ELSE
        vr_digito := vr_resto;
      END IF;
      vr_numero := SUBSTR(to_char(vr_nrcalcul,'fm000000000'),1,8) || vr_digito;
      vr_nrcalcul := vr_numero;

      -- Insere o Associado
      BEGIN
        INSERT INTO crapass
          (cdagenci,
           nrdconta,
           cdcooper,
           nrmatric,
           cdsexotl,
           nrcadast,
           nmprimtl,
           dtnasctl,
           cdnacion,
           dsproftl,
           dtadmiss,
           dtdemiss,
           nrcpfcgc,
           cdsitdtl,
           inpessoa,
           tpdocptl,
           nrdocptl,
           idorgexp,
           cdufdptl,
           dtemdptl,
           nmpaiptl,
           nmmaeptl,
           dsfiliac,
           indnivel,
           inmatric,
           tpavsdeb,
           nrctainv,
           dtultalt,   -- Os campos daqui em diante foram colocados novos
           dtadmemp,
           dtmvtolt,
           cdsitdct,
           cdtipcta,
           dtcnsspc,
           dtdsdspc,
           inadimpl,
           inedvmto,
           inlbacen,
           iniscpmf,
           tpvincul,
           dtcnscpf,
           cdsitcpf,
           inccfcop,
           dtccfcop,
           indrisco,
           dtcnsscr,
           nrnotatl,
           inrisctl,
           dtrisctl,
           cdclcnae,
           nmttlrfb,
           inconrfb,
           cdbcochq,
           cdsecext,
           hrinicad,
           cdopeori,
           cdageori,
           dtinsori)
        SELECT cdagenci,
               pr_nrdconta_dst,
               cdcooper,
               nrmatric,
               cdsexotl,
               nrcadast,
               nmprimtl,
               dtnasctl,
               cdnacion,
               dsproftl,
               rw_crapdat.dtmvtolt, -- COnforme Sarah, utilizar a data atual para a data de Admissao
               dtdemiss,
               nrcpfcgc,
               cdsitdtl,
               inpessoa,
               tpdocptl,
               nrdocptl,
               idorgexp,
               cdufdptl,
               dtemdptl,
               nmpaiptl,
               nmmaeptl,
               dsfiliac,
               1,
               2,
               0,
               vr_nrcalcul,
               dtultalt,
               dtadmemp,
               rw_crapdat.dtmvtolt,
               cdsitdct,
               cdtipcta,
               dtcnsspc,
               dtdsdspc,
               inadimpl,
               inedvmto,
               inlbacen,
               iniscpmf,
               tpvincul,
               dtcnscpf,
               cdsitcpf,
               inccfcop,
               dtccfcop,
               indrisco,
               dtcnsscr,
               nrnotatl,
               inrisctl,
               dtrisctl,
               cdclcnae,
               nmttlrfb,
               inconrfb,
               cdbcochq,
               cdsecext,
               to_char(SYSDATE,'sssss'), 
               pr_cdoperad, -- INICIO - Alteracoes referentes a M181 - Rafael Maciel (RKAM)"
               NVL((select cdpactra from crapope where cdoperad = pr_cdoperad and cdcooper = pr_cdcooper), 0),
               SYSDATE -- FIM - Alteracoes referentes a M181 - Rafael Maciel (RKAM)"
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta_org;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPASS: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Insere a tabela de alteracao para nao solicitar recadastro
      BEGIN
        INSERT INTO crapalt
          (nrdconta,
           dtaltera,
           cdoperad,
           dsaltera,
           tpaltera,
           flgctitg,
           cdcooper)
         VALUES
          (pr_nrdconta_dst,
           rw_crapdat.dtmvtolt,
           pr_cdoperad,
           'Duplicacao com base na conta '||gene0002.fn_mask_conta(pr_nrdconta_org),
           1,
           2,
           pr_cdcooper);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPALT: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Insere o endereco
      BEGIN
        INSERT INTO crapenc
          (cdcooper,
           nrdconta,
           idseqttl,
           cdseqinc,
           tpendass,
           dsendere,
           nrendere,
           complend,
           nmbairro,
           nmcidade,
           cdufende,
           nrcepend,
           incasprp,
           dtinires,
           vlalugue,
           nrcxapst,
           nranores,
           dtaltenc,
           nrdoapto,
           cddbloco,
           idorigem)
        SELECT cdcooper,
               pr_nrdconta_dst,
               1,
               cdseqinc,
               tpendass,
               dsendere,
               nrendere,
               complend,
               nmbairro,
               nmcidade,
               cdufende,
               nrcepend,
               incasprp,
               dtinires,
               vlalugue,
               nrcxapst,
               nranores,
               dtaltenc,
               nrdoapto,
               cddbloco,
               idorigem
          FROM crapenc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta_org
           AND idseqttl = 1;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPENC: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Insere os contatos e procuradores
      BEGIN
        INSERT INTO crapavt
          (nrdconta,
           nrctremp,
           nrcpfcgc,
           nmdavali,
           nrcpfcjg,
           nmconjug,
           tpdoccjg,
           nrdoccjg,
           tpdocava,
           nrdocava,
           dsendres##1,
           dsendres##2,
           nrfonres,
           dsdemail,
           tpctrato,
           nrcepend,
           nmcidade,
           cdufresd,
           dtmvtolt,
           cdcooper,
           cdnacion,
           nrendere,
           complend,
           nmbairro,
           nrcxapst,
           nrtelefo,
           nmextemp,
           cddbanco,
           cdagenci,
           dsproftl,
           nrdctato,
           idorgexp,
           dtemddoc,
           cdufddoc,
           dtvalida,
           nmmaecto,
           nmpaicto,
           dtnascto,
           dsnatura,
           cdsexcto,
           cdestcvl,
           flgimpri,
           dsrelbem##1,
           dsrelbem##2,
           dsrelbem##3,
           dsrelbem##4,
           dsrelbem##5,
           dsrelbem##6,
           persemon##1,
           persemon##2,
           persemon##3,
           persemon##4,
           persemon##5,
           persemon##6,
           qtprebem##1,
           qtprebem##2,
           qtprebem##3,
           qtprebem##4,
           qtprebem##5,
           qtprebem##6,
           vlprebem##1,
           vlprebem##2,
           vlprebem##3,
           vlprebem##4,
           vlprebem##5,
           vlprebem##6,
           vlrdobem##1,
           vlrdobem##2,
           vlrdobem##3,
           vlrdobem##4,
           vlrdobem##5,
           vlrdobem##6,
           vlrenmes,
           vledvmto,
           dtadmsoc,
           persocio,
           flgdepec,
           vloutren,
           dsoutren,
           inhabmen,
           dthabmen,
           inpessoa,
           dtdrisco,
           qtopescr,
           qtifoper,
           vltotsfn,
           vlopescr,
           vlprejuz)
        SELECT pr_nrdconta_dst,
               nrctremp,
               nrcpfcgc,
               nmdavali,
               nrcpfcjg,
               nmconjug,
               tpdoccjg,
               nrdoccjg,
               tpdocava,
               nrdocava,
               dsendres##1,
               dsendres##2,
               nrfonres,
               dsdemail,
               tpctrato,
               nrcepend,
               nmcidade,
               cdufresd,
               dtmvtolt,
               cdcooper,
               cdnacion,
               nrendere,
               complend,
               nmbairro,
               nrcxapst,
               nrtelefo,
               nmextemp,
               cddbanco,
               cdagenci,
               dsproftl,
               nrdctato,
               idorgexp,
               dtemddoc,
               cdufddoc,
               dtvalida,
               nmmaecto,
               nmpaicto,
               dtnascto,
               dsnatura,
               cdsexcto,
               cdestcvl,
               1,
               dsrelbem##1,
               dsrelbem##2,
               dsrelbem##3,
               dsrelbem##4,
               dsrelbem##5,
               dsrelbem##6,
               persemon##1,
               persemon##2,
               persemon##3,
               persemon##4,
               persemon##5,
               persemon##6,
               qtprebem##1,
               qtprebem##2,
               qtprebem##3,
               qtprebem##4,
               qtprebem##5,
               qtprebem##6,
               vlprebem##1,
               vlprebem##2,
               vlprebem##3,
               vlprebem##4,
               vlprebem##5,
               vlprebem##6,
               vlrdobem##1,
               vlrdobem##2,
               vlrdobem##3,
               vlrdobem##4,
               vlrdobem##5,
               vlrdobem##6,
               vlrenmes,
               vledvmto,
               dtadmsoc,
               persocio,
               flgdepec,
               vloutren,
               dsoutren,
               inhabmen,
               dthabmen,
               inpessoa,
               dtdrisco,
               qtopescr,
               qtifoper,
               vltotsfn,
               vlopescr,
               vlprejuz
          FROM crapavt
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta_org
           AND tpctrato IN (5, 6); --Contatos e Procuradores
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPAVT: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Efetua o loop sobre a tabela de controle de documentos digitalizados
      FOR x IN 1..7 LOOP
        -- Insere na tabela de documentos digitalizados - GED
        BEGIN
          INSERT INTO crapdoc
            (cdcooper,
             nrdconta,
             flgdigit,
             dtmvtolt,
             tpdocmto,
             idseqttl)
           VALUES
            (pr_cdcooper,
             pr_nrdconta_dst,
             0,
             rw_crapdat.dtmvtolt,
             x,
             1);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na CRAPDOC: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      END LOOP;

      -- Se for pessoa fisica, cria o primeiro titular
      IF rw_crapass.inpessoa = 1 THEN
        BEGIN
          INSERT INTO crapttl
            (nrdconta,
             cdcooper,
             idseqttl,
             nmextttl,
             inpessoa,
             nrcpfcgc,
             cdnacion,
             dtnasttl,
             cdsexotl,
             cdgraupr,
             cdestcvl,
             cdempres,
             dsproftl,
             tpdocttl,
             nrdocttl,
             idorgexp,
             cdufdttl,
             dtemdttl,
             nmmaettl,
             nmpaittl,
             dsnatura,
             cdufnatu,
             tpnacion,
             cdocpttl,
             flgimpri,
             nmtalttl,
             grescola,
             cdfrmttl,
             cdnatopc,
             tpcttrab,
             nmextemp,
             nrcpfemp,
             dtadmemp,
             cdnvlcgo,
             vlsalari,
             indnivel,
             dtcnscpf,
             cdsitcpf,
             inhabmen,
             dthabmen,
             dtdememp,
             cdturnos,
             tpdrendi##1,
             tpdrendi##2,
             tpdrendi##3,
             tpdrendi##4,
             tpdrendi##5,
             tpdrendi##6,
             vldrendi##1,
             vldrendi##2,
             vldrendi##3,
             vldrendi##4,
             vldrendi##5,
             vldrendi##6,
             dsinfadi,
             nrinfcad,
             nrpatlvr,
             inpolexp,
             dsjusren,
             nrcadast)
          SELECT pr_nrdconta_dst,
                 cdcooper,
                 idseqttl,
                 nmextttl,
                 rw_crapass.inpessoa,
                 rw_crapass.nrcpfcgc,
                 rw_crapass.cdnacion,
                 dtnasttl,
                 cdsexotl,
                 0,
                 cdestcvl,
                 cdempres,
                 rw_crapass.dsproftl,
                 tpdocttl,
                 nrdocttl,
                 idorgexp,
                 cdufdttl,
                 dtemdttl,
                 nmmaettl,
                 nmpaittl,
                 dsnatura,
                 cdufnatu,
                 tpnacion,
                 cdocpttl,
                 1,
                 nmtalttl,
                 grescola,
                 cdfrmttl,
                 cdnatopc,
                 tpcttrab,
                 nmextemp,
                 nrcpfemp,
                 dtadmemp,
                 cdnvlcgo,
                 vlsalari,
                 indnivel,
                 dtcnscpf,
                 cdsitcpf,
                 inhabmen,
                 dthabmen,
                 dtdememp,
                 cdturnos,
                 tpdrendi##1,
                 tpdrendi##2,
                 tpdrendi##3,
                 tpdrendi##4,
                 tpdrendi##5,
                 tpdrendi##6,
                 vldrendi##1,
                 vldrendi##2,
                 vldrendi##3,
                 vldrendi##4,
                 vldrendi##5,
                 vldrendi##6,
                 dsinfadi,
                 nrinfcad,
                 nrpatlvr,
                 inpolexp,
                 dsjusren,
                 nrcadast
            FROM crapttl
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta_org
             AND idseqttl = 1;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na CRAPTTL: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Insere o conjuge
        BEGIN
          INSERT INTO crapcje
            (cdcooper,
             nrdconta,
             idseqttl,
             nmconjug,
             nrcpfcjg,
             dtnasccj,
             tpdoccje,
             nrdoccje,
             idorgexp,
             cdufdcje,
             dtemdcje,
             grescola,
             cdfrmttl,
             cdnatopc,
             cdocpcje,
             tpcttrab,
             nmextemp,
             dsproftl,
             cdnvlcgo,
             nrfonemp,
             nrramemp,
             cdturnos,
             dtadmemp,
             vlsalari,
             nrdocnpj,
             nrctacje,
             dsendcom)
          SELECT cdcooper,
                 pr_nrdconta_dst,
                 idseqttl,
                 nmconjug,
                 nrcpfcjg,
                 dtnasccj,
                 tpdoccje,
                 nrdoccje,
                 idorgexp,
                 cdufdcje,
                 dtemdcje,
                 grescola,
                 cdfrmttl,
                 cdnatopc,
                 cdocpcje,
                 tpcttrab,
                 nmextemp,
                 dsproftl,
                 cdnvlcgo,
                 nrfonemp,
                 nrramemp,
                 cdturnos,
                 dtadmemp,
                 vlsalari,
                 nrdocnpj,
                 nrctacje,
                 dsendcom
            FROM crapcje
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta_org
             AND idseqttl = 1;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na CRAPCJE: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

      ELSE -- Se for PJ
        -- Insere a tabela de pessoas juridicas
        BEGIN
          INSERT INTO crapjur
            (cdcooper,
             nrdconta,
             nmfansia,
             nmextttl,
             nrinsest,
             natjurid,
             dtiniatv,
             qtfilial,
             qtfuncio,
             nmtalttl,
             vlcaprea,
             dtregemp,
             nrregemp,
             orregemp,
             dtinsnum,
             nrcdnire,
             flgrefis,
             dsendweb,
             nrinsmun,
             cdseteco,
             vlfatano,
             cdmodali,
             cdrmativ,
             cdempres,
             nrinfcad,
             nrperger,
             nrpatlvr,
             nrlicamb)
          SELECT cdcooper,
                 pr_nrdconta_dst,
                 nmfansia,
                 rw_crapass.nmprimtl,
                 nrinsest,
                 natjurid,
                 dtiniatv,
                 qtfilial,
                 qtfuncio,
                 nmtalttl,
                 vlcaprea,
                 dtregemp,
                 nrregemp,
                 orregemp,
                 dtinsnum,
                 nrcdnire,
                 flgrefis,
                 dsendweb,
                 nrinsmun,
                 cdseteco,
                 vlfatano,
                 cdmodali,
                 cdrmativ,
                 cdempres,
                 nrinfcad,
                 nrperger,
                 nrpatlvr,
                 nrlicamb
            FROM crapjur
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta_org;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na CRAPJUR: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Insere na tabela de dados financeiros de PJ
        BEGIN
          INSERT INTO crapjfn
            (cdcooper,
             nrdconta,
             mesftbru##1,
             mesftbru##2,
             mesftbru##3,
             mesftbru##4,
             mesftbru##5,
             mesftbru##6,
             mesftbru##7,
             mesftbru##8,
             mesftbru##9,
             mesftbru##10,
             mesftbru##11,
             mesftbru##12,
             anoftbru##1,
             anoftbru##2,
             anoftbru##3,
             anoftbru##4,
             anoftbru##5,
             anoftbru##6,
             anoftbru##7,
             anoftbru##8,
             anoftbru##9,
             anoftbru##10,
             anoftbru##11,
             anoftbru##12,
             vlrftbru##1,
             vlrftbru##2,
             vlrftbru##3,
             vlrftbru##4,
             vlrftbru##5,
             vlrftbru##6,
             vlrftbru##7,
             vlrftbru##8,
             vlrftbru##9,
             vlrftbru##10,
             vlrftbru##11,
             vlrftbru##12,
             vlrctbru,
             vlctdpad,
             vldspfin,
             ddprzrec,
             ddprzpag,
             vlcxbcaf,
             vlctarcb,
             vlrestoq,
             vloutatv,
             vlrimobi,
             vlfornec,
             vloutpas,
             vldivbco,
             cddbanco##1,
             cddbanco##2,
             cddbanco##3,
             cddbanco##4,
             cddbanco##5,
             dstipope##1,
             dstipope##2,
             dstipope##3,
             dstipope##4,
             dstipope##5,
             vlropera##1,
             vlropera##2,
             vlropera##3,
             vlropera##4,
             vlropera##5,
             garantia##1,
             garantia##2,
             garantia##3,
             garantia##4,
             garantia##5,
             dsvencto##1,
             dsvencto##2,
             dsvencto##3,
             dsvencto##4,
             dsvencto##5,
             dtaltjfn##1,
             dtaltjfn##2,
             dtaltjfn##3,
             dtaltjfn##4,
             dtaltjfn##5,
             cdopejfn##1,
             cdopejfn##2,
             cdopejfn##3,
             cdopejfn##4,
             cdopejfn##5,
             mesdbase,
             anodbase,
             dsinfadi##1,
             dsinfadi##2,
             dsinfadi##3,
             dsinfadi##4,
             dsinfadi##5,
             perfatcl)
           SELECT cdcooper,
                  pr_nrdconta_dst,
                  mesftbru##1,
                  mesftbru##2,
                  mesftbru##3,
                  mesftbru##4,
                  mesftbru##5,
                  mesftbru##6,
                  mesftbru##7,
                  mesftbru##8,
                  mesftbru##9,
                  mesftbru##10,
                  mesftbru##11,
                  mesftbru##12,
                  anoftbru##1,
                  anoftbru##2,
                  anoftbru##3,
                  anoftbru##4,
                  anoftbru##5,
                  anoftbru##6,
                  anoftbru##7,
                  anoftbru##8,
                  anoftbru##9,
                  anoftbru##10,
                  anoftbru##11,
                  anoftbru##12,
                  vlrftbru##1,
                  vlrftbru##2,
                  vlrftbru##3,
                  vlrftbru##4,
                  vlrftbru##5,
                  vlrftbru##6,
                  vlrftbru##7,
                  vlrftbru##8,
                  vlrftbru##9,
                  vlrftbru##10,
                  vlrftbru##11,
                  vlrftbru##12,
                  vlrctbru,
                  vlctdpad,
                  vldspfin,
                  ddprzrec,
                  ddprzpag,
                  vlcxbcaf,
                  vlctarcb,
                  vlrestoq,
                  vloutatv,
                  vlrimobi,
                  vlfornec,
                  vloutpas,
                  vldivbco,
                  cddbanco##1,
                  cddbanco##2,
                  cddbanco##3,
                  cddbanco##4,
                  cddbanco##5,
                  dstipope##1,
                  dstipope##2,
                  dstipope##3,
                  dstipope##4,
                  dstipope##5,
                  vlropera##1,
                  vlropera##2,
                  vlropera##3,
                  vlropera##4,
                  vlropera##5,
                  garantia##1,
                  garantia##2,
                  garantia##3,
                  garantia##4,
                  garantia##5,
                  dsvencto##1,
                  dsvencto##2,
                  dsvencto##3,
                  dsvencto##4,
                  dsvencto##5,
                  dtaltjfn##1,
                  dtaltjfn##2,
                  dtaltjfn##3,
                  dtaltjfn##4,
                  dtaltjfn##5,
                  cdopejfn##1,
                  cdopejfn##2,
                  cdopejfn##3,
                  cdopejfn##4,
                  cdopejfn##5,
                  mesdbase,
                  anodbase,
                  dsinfadi##1,
                  dsinfadi##2,
                  dsinfadi##3,
                  dsinfadi##4,
                  dsinfadi##5,
                  perfatcl
             FROM crapjfn
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta_org;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na CRAPJFN: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        BEGIN
          INSERT INTO crapepa
            (cdcooper,
             nrdconta,
             nrdocsoc,
             nrctasoc,
             nmfansia,
             nrinsest,
             natjurid,
             dtiniatv,
             qtfilial,
             qtfuncio,
             dsendweb,
             cdseteco,
             cdmodali,
             cdrmativ,
             vledvmto,
             dtadmiss,
             dtmvtolt,
             persocio,
             nmprimtl)
           SELECT cdcooper,
                  pr_nrdconta_dst,
                  nrdocsoc,
                  nrctasoc,
                  nmfansia,
                  nrinsest,
                  natjurid,
                  dtiniatv,
                  qtfilial,
                  qtfuncio,
                  dsendweb,
                  cdseteco,
                  cdmodali,
                  cdrmativ,
                  vledvmto,
                  dtadmiss,
                  dtmvtolt,
                  persocio,
                  nmprimtl
             FROM crapepa
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta_org;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na CRAPEPA: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

      END IF;

      -- Cria o responsavel legal
      BEGIN
        INSERT INTO crapcrl
          (cdcooper,
           nrctamen,
           nrcpfmen,
           idseqmen,
           nrdconta,
           nrcpfcgc,
           nmrespon,
           idorgexp,
           cdufiden,
           dtemiden,
           dtnascin,
           cddosexo,
           cdestciv,
           cdnacion,
           dsnatura,
           cdcepres,
           dsendres,
           nrendres,
           dscomres,
           dsbaires,
           nrcxpost,
           dscidres,
           dsdufres,
           nmpairsp,
           nmmaersp,
           tpdeiden,
           nridenti,
           dtmvtolt,
           flgimpri,
           cdrlcrsp)
        SELECT cdcooper,
               pr_nrdconta_dst,
               nrcpfmen,
               idseqmen,
               nrdconta,
               nrcpfcgc,
               nmrespon,
               idorgexp,
               cdufiden,
               dtemiden,
               dtnascin,
               cddosexo,
               cdestciv,
               cdnacion,
               dsnatura,
               cdcepres,
               dsendres,
               nrendres,
               dscomres,
               dsbaires,
               nrcxpost,
               dscidres,
               dsdufres,
               nmpairsp,
               nmmaersp,
               tpdeiden,
               nridenti,
               dtmvtolt,
               flgimpri,
               cdrlcrsp
          FROM crapcrl
         WHERE cdcooper = pr_cdcooper
           AND nrctamen = pr_nrdconta_org;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPCLR: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Cria os dependentes
      BEGIN
        INSERT INTO crapdep
          (cdcooper,
           nrdconta,
           idseqdep,
           nmdepend,
           dtnascto,
           tpdepend)
         SELECT cdcooper,
                pr_nrdconta_dst,
                idseqdep,
                nmdepend,
                dtnascto,
                tpdepend
           FROM crapdep
          WHERE cdcooper = pr_cdcooper
            AND nrdconta = pr_nrdconta_org
            AND idseqdep = 1;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPDEP: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Insere os telefones
      BEGIN
        INSERT INTO craptfc
          (cdcooper,
           nrdconta,
           idseqttl,
           cdseqtfc,
           cdopetfn,
           nrdddtfc,
           tptelefo,
           nmpescto,
           prgqfalt,
           nrtelefo,
           nrdramal,
           secpscto,
           idsittfc,
           idorigem)
         SELECT cdcooper,
                pr_nrdconta_dst,
                idseqttl,
                cdseqtfc,
                cdopetfn,
                nrdddtfc,
                tptelefo,
                nmpescto,
                'A',
                nrtelefo,
                nrdramal,
                secpscto,
                idsittfc,
                idorigem
           FROM craptfc
          WHERE cdcooper = pr_cdcooper
            AND nrdconta = pr_nrdconta_org
            AND idseqttl = 1;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPTFC: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Insere os emails
      BEGIN
        INSERT INTO crapcem
          (nrdconta,
           dsdemail,
           cddemail,
           dtmvtolt,
           hrtransa,
           cdcooper,
           idseqttl,
           prgqfalt,
           nmpescto,
           secpscto)
         SELECT pr_nrdconta_dst,
                dsdemail,
                cddemail,
                rw_crapdat.dtmvtolt,
                to_char(SYSDATE,'sssss'),
                cdcooper,
                idseqttl,
                prgqfalt,
                nmpescto,
                secpscto
           FROM crapcem
          WHERE cdcooper = pr_cdcooper
            AND nrdconta = pr_nrdconta_org
            AND idseqttl = 1;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPCEM: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Insere os bens
      BEGIN
        INSERT INTO crapbem
          (cdcooper,
           nrdconta,
           idseqttl,
           dtmvtolt,
           cdoperad,
           dtaltbem,
           idseqbem,
           dsrelbem,
           persemon,
           qtprebem,
           vlrdobem,
           vlprebem)
         SELECT cdcooper,
                pr_nrdconta_dst,
                idseqttl,
                rw_crapdat.dtmvtolt,
                pr_cdoperad,
                dtaltbem,
                idseqbem,
                dsrelbem,
                persemon,
                qtprebem,
                vlrdobem,
                vlprebem
           FROM crapbem
          WHERE cdcooper = pr_cdcooper
            AND nrdconta = pr_nrdconta_org
            AND idseqttl = 1;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPBEM: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

/*      -- Insere os dados do sistema financeiro nacional
      BEGIN
        INSERT INTO crapsfn
          (nrcpfcgc,
           inpessoa,
           dtabtcct,
           cddbanco,
           cdageban,
           dgdconta,
           dtmvtolt,
           cdoperad,
           hrtransa,
           nrdconta,
           nminsfin,
           cdcooper,
           nrseqdig,
           tpregist,
           insitcta,
           dtdemiss,
           cdmotdem,
           cdagenci)
         SELECT nrcpfcgc,
                inpessoa,
                rw_crapdat.dtmvtolt,
                cddbanco,
                cdageban,
                dgdconta,
                rw_crapdat.dtmvtolt,
                pr_cdoperad,
                to_char(SYSDATE,'sssss'),
                pr_nrdconta_dst,
                nminsfin,
                cdcooper,
                nrseqdig,
                tpregist,
                insitcta,
                dtdemiss,
                cdmotdem,
                cdagenci
           FROM crapsfn
          WHERE cdcooper = pr_cdcooper
            AND nrdconta = pr_nrdconta_org;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPSFN: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Insere os dados do sistema financeiro nacional
      BEGIN
        INSERT INTO gncpicf
          (nrcpfcgc,
           inpessoa,
           dtabtcct,
           cddbanco,
           cdageban,
           dgdconta,
           dtmvtolt,
           cdoperad,
           hrtransa,
           nrdconta,
           nminsfin,
           cdcooper,
           nrseqdig,
           tpregist,
           cdmotdem,
           cdagenci)
         SELECT nrcpfcgc,
                inpessoa,
                rw_crapdat.dtmvtolt,
                cddbanco,
                cdageban,
                dgdconta,
                rw_crapdat.dtmvtolt,
                pr_cdoperad,
                to_char(SYSDATE,'sssss'),
                pr_nrdconta_dst,
                nminsfin,
                cdcooper,
                nrseqdig,
                tpregist,
                cdmotdem,
                cdagenci
           FROM gncpicf
          WHERE cdcooper = pr_cdcooper
            AND nrdconta = pr_nrdconta_org;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na GNCPICF: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
*/

      -- Cria a tabela de saldos
      BEGIN
        INSERT INTO crapsld
          (dtrefere,
           nrdconta,
           cdcooper,
           qtddsdev,
           dtdsdclq,
           dtrefext)
        VALUES
          (rw_crapdat.dtmvtoan,
           pr_nrdconta_dst,
           pr_cdcooper,
           0,
           NULL,
           rw_crapdat.dtmvtolt - to_char(rw_crapdat.dtmvtolt,'DD'));
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPSLD: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Cria a tabela de cotas
      BEGIN
        INSERT INTO crapcot
          (nrdconta,
           cdcooper)
        VALUES
          (pr_nrdconta_dst,
           pr_cdcooper);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPCOT: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Insere na tabela de saldo do dia
      BEGIN
        INSERT INTO crapsda
          (dtmvtolt,
           nrdconta,
           cdcooper)
        VALUES
          (rw_crapdat.dtmvtoan,
           pr_nrdconta_dst,
           pr_cdcooper);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPSDA: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Busca o valor das cotas com base nas matriculas
      OPEN cr_crapmat;
      FETCH cr_crapmat INTO rw_crapmat;
      CLOSE cr_crapmat;

      --Limpa o lixo da consulta anterior
      rw_craptab.dstextab := NULL;
      
      -- Le tabela de valor minimo do capital
      OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'USUARI'
                     ,pr_cdempres => 11
                     ,pr_cdacesso => 'VLRUNIDCAP'
                     ,pr_tpregist => 1);
      FETCH cr_craptab INTO rw_craptab;
      CLOSE cr_craptab;

      -- Se nao tiver tabela de parametrizacao, utiliza o valor da CRAPMAT
      IF rw_craptab.dstextab IS NULL THEN
        vr_vlcapmin := rw_crapmat.vlcapini;
      ELSE
        vr_vlcapmin := rw_craptab.dstextab;
      END IF;

      EXTR0001.pc_ver_capital(pr_cdcooper => pr_cdcooper -- Código da cooperativa
                             ,pr_cdagenci => 0 -- Código da agência
                             ,pr_nrdcaixa => 0 -- Número do caixa
                             ,pr_inproces => rw_crapdat.inproces -- Indicador do processo
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data de movimento
                             ,pr_dtmvtopr => rw_crapdat.dtmvtopr -- Data do programa
                             ,pr_cdprogra => 'TRANSF' -- Código do programa
                             ,pr_idorigem => 1 -- Origem do programa
                             ,pr_nrdconta => pr_nrdconta_org -- Número da conta
                             ,pr_vllanmto => vr_vlcapmin           -- Valor de lancamento
                             ,pr_des_reto => vr_des_reto -- Retorno OK/NOK
                             ,pr_tab_erro => vr_tab_erro);

      -- Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN

        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '|| pr_nrdconta_dst;
        ELSE
          vr_cdcritic:= NULL;
          vr_dscritic:= 'Retorno "NOK" na EXTR0001.pc_ver_capital e sem informação na pr_tab_erro, Conta: '|| pr_nrdconta_dst;

        END IF;

        -- Gera exceção
        RAISE vr_exc_saida;

      END IF;

      -- Seta flag de devolucao automatica de cheques
      pc_grava_tbchq_param_conta('I'              -- Opcao, Incluir
                                 ,pr_cdcooper     -- Cooperativa 
                                 ,pr_nrdconta_dst -- Numero da Conta 
                                 ,1               -- Flag devolucao automatica/ 1=sim/0=nao 
                                 ,pr_cdoperad     -- Operador   
                                 ,' '             -- Operador Coordenador 
                                 ,vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Efetua a transferencia de cotas da conta de origem para a conta de destino
      pc_transfere_cotas(pr_cdcooper     => pr_cdcooper
                        ,pr_nrdconta_org => pr_nrdconta_org
                        ,pr_nrdconta_dst => pr_nrdconta_dst
                        ,pr_dtmvtolt     => rw_crapdat.dtmvtolt
                        ,pr_vlcapmin     => vr_vlcapmin
                        ,pr_cdcritic     => pr_cdcritic
                        ,pr_dscritic     => pr_dscritic);
      IF nvl(pr_cdcritic,0) <> 0 OR pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Desfaz as alteracoes
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_lista_conta: ' || SQLERRM;

        -- Desfaz as alteracoes
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


    END pc_duplica_conta;

  -- Funcao para retornar se o produto esta habilitado
  FUNCTION fn_produto_habilitado(pr_cdcooper  tbcc_produto_oferecido.cdcooper%TYPE, --> Codigo da cooperativa
                                 pr_nrdconta  tbcc_produto_oferecido.nrdconta%TYPE, --> Numero da conta
                                 pr_cdproduto tbcc_produto_oferecido.cdproduto%TYPE)--> Codigo do produto
                     RETURN VARCHAR2 IS
      -- Registro sobre as datas
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Cursor sobre a tabela de associados
      CURSOR cr_crapass IS
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
        SELECT snh.vllimweb,
               snh.vllimted,
               snh.vllimvrb,
               snh.vllimtrf,
               snh.vllimpgo,
               ass.idastcjt
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

      rw_crapsnh cr_crapsnh%ROWTYPE;

      -- Cursor sobre os cartoes de credito
      CURSOR cr_crawcrd(pr_tpcartao PLS_INTEGER,  -- 0-BB, 1-Cecred
                        pr_inpessoa crapass.inpessoa%TYPE) IS
        SELECT dtsol2vi,
               insitcrd
          FROM crawcrd
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND (pr_tpcartao = 0 AND ((cdadmcrd <  10 OR cdadmcrd > 80) OR pr_inpessoa <> 1)
            OR  (pr_tpcartao = 1 AND (cdadmcrd >= 10 AND cdadmcrd <= 80)))
           AND insitcrd IN (1, -- Aprovado
                            2, -- Solicitado
                            3, -- Liberado
                            4, -- Em uso
                            5); -- Bloqueado
      rw_crawcrd cr_crawcrd%ROWTYPE;

      -- Cursor para busca de cartoes magneticos
      CURSOR cr_crapcrm IS
        SELECT 1
          FROM crapcrm
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND tpcarcta = 1
           AND cdsitcar IN  (1,2)
           AND dtvalcar > rw_crapdat.dtmvtolt;
      rw_crapcrm cr_crapcrm%ROWTYPE;

      -- Cursor sobre a tabela de emissao de boletos
      CURSOR cr_crapceb IS
        SELECT 1
          FROM crapceb
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND insitceb = 1;
      rw_crapceb cr_crapceb%ROWTYPE;

      -- Cursor sobre a tabela de debitos autorizados
      CURSOR cr_crapatr IS
        SELECT 1
          FROM crapatr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtfimatr IS NULL;
      rw_crapatr cr_crapatr%ROWTYPE;

      -- Cursor sobre a tabela de lancamento de cotas
      CURSOR cr_craplct IS
        SELECT 1
          FROM craplct
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND vllanmto > 1; -- Considerar apenas quando o lancamento eh superior a 1 real,
                             -- Pois este valor eh criado automaticamente na criacao da conta
      rw_craplct cr_craplct%ROWTYPE;

      -- Cursor sobre o plano de cotas
      CURSOR cr_crappla IS
        SELECT 1
          FROM crappla
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND cdsitpla = 1; -- Ativo
      rw_crappla cr_crappla%ROWTYPE;

      -- Cursor sobre o cadastro de poupanca programada
      CURSOR cr_craprpp IS
        SELECT 1
          FROM craprpp a
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtcancel IS NULL;
      rw_craprpp cr_craprpp%ROWTYPE;


      -- Cursor sobre a tabela de seguros de vida
      CURSOR cr_crapseg_vida IS
        SELECT 1
          FROM crapseg
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND cdsitseg IN (1,3) -- Ativo
           AND tpseguro = 3; -- Seguro de vida
      rw_crapseg_vida cr_crapseg_vida%ROWTYPE;

      -- Cursor sobre a tabela de seguros de casa
      CURSOR cr_crapseg_casa IS
        SELECT 1
          FROM crapseg
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND cdsitseg IN (1,3) -- Ativo
           AND tpseguro IN (1,11); -- Seguro de casa
      rw_crapseg_casa cr_crapseg_casa%ROWTYPE;

      -- Cursor sobre a tabela de consorcios
      CURSOR cr_crapcns IS
        SELECT 1
          FROM crapcns
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND flgativo = 1; -- Ativo
      rw_crapcns cr_crapcns%ROWTYPE;

      -- Cursor para verificar se conta possui convenio de folha de pagamento
      CURSOR cr_crapemp IS
        SELECT 1
          FROM crapemp
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND flgpgtib = 1; -- Ativo
      rw_crapemp cr_crapemp%ROWTYPE;

      -- Cursor para verificar se existe aplicacao
      CURSOR cr_aplicacao IS
        SELECT 1
          FROM craprda 
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND insaqtot = 0
         UNION ALL
        SELECT 1
          FROM craprac
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND idsaqtot = 0;
       rw_aplicacao cr_aplicacao%ROWTYPE;

      -- Variaveis de tratamento de erro
      vr_tab_erro      gene0001.typ_tab_erro;
      vr_des_reto      VARCHAR2(10);
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis gerais
      vr_tab_saldo_rdca cecred.apli0001.typ_tab_saldo_rdca; --> Record com os saldos de aplicacao
      vr_vlsldapl   crapapl.vlaplica%TYPE;                  --> Saldo da aplicacao
      vr_flgsacad   PLS_INTEGER;                            --> Indicador se possui DDA


    BEGIN

      -- Busca a data do sistema
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      IF pr_cdproduto = 1 THEN -- Acesso a internet
        -- Abre a tabela de senhas para ver se o usuario tem internet liberada
        OPEN cr_crapsnh(1); -- Internet
        FETCH cr_crapsnh INTO rw_crapsnh;
        -- Se nao encotrou, nao tem acesso
        IF cr_crapsnh%NOTFOUND THEN
          CLOSE cr_crapsnh;
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        CLOSE cr_crapsnh;
        RETURN 'S'; -- Retorna como produto aderido
      ELSIF pr_cdproduto = 2 THEN -- Acesso ao tele saldo
        -- Abre a tabela de senhas para ver se o usuario tem tele saldo liberado
        OPEN cr_crapsnh(2); -- Tele Saldo
        FETCH cr_crapsnh INTO rw_crapsnh;
        -- Se nao encotrou, nao tem acesso
        IF cr_crapsnh%NOTFOUND THEN
          CLOSE cr_crapsnh;
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        CLOSE cr_crapsnh;
        RETURN 'S'; -- Retorna como produto aderido
      ELSIF pr_cdproduto = 3 THEN -- Aplicacao
        OPEN cr_aplicacao;
        FETCH cr_aplicacao INTO rw_aplicacao;
        IF cr_aplicacao%FOUND THEN
          CLOSE cr_aplicacao;
          RETURN 'S';
        END IF;
        CLOSE cr_aplicacao;
        RETURN 'N';

        /* Nao usar a rotina abaixo, pois degrada a performance
        apli0002.pc_obtem_dados_aplicacoes(pr_cdcooper => pr_cdcooper,
                                           pr_cdagenci => 0,
                                           pr_nrdcaixa => 0,
                                           pr_cdoperad => 1,
                                           pr_nmdatela => ' ',
                                           pr_idorigem => 1, -- Ayllos
                                           pr_nrdconta => pr_nrdconta,
                                           pr_idseqttl => 1, -- Primeiro titular
                                           pr_nraplica => 0,
                                           pr_cdprogra => ' ',
                                           pr_flgerlog => 0,
                                           pr_dtiniper => NULL,
                                           pr_dtfimper => NULL,
                                           pr_vlsldapl => vr_vlsldapl,
                                           pr_des_reto => vr_des_reto,
                                           pr_tab_saldo_rdca => vr_tab_saldo_rdca,
                                           pr_tab_erro => vr_tab_erro);
        -- Se retornar com saldo de aplicacao retorna como produto aderido
        IF nvl(vr_vlsldapl,0) > 0 THEN
          RETURN 'S';
        ELSE
          RETURN 'N';
        END IF;
        */
      ELSIF pr_cdproduto IN (4,       -- Cartao de credito
                             24) THEN -- Cartao de Credito Empresarial
        -- Abre a tabela de associados
        OPEN cr_crapass;
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;

        -- Abre a tabela de cartoes de credito
        OPEN cr_crawcrd(0, rw_crapass.inpessoa); -- Diferente de Cecred
        FETCH cr_crawcrd INTO rw_crawcrd;
        -- Se nao encotrou, nao possui cartao liberado
        IF cr_crawcrd%NOTFOUND THEN
          CLOSE cr_crawcrd;
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        CLOSE cr_crawcrd;
        RETURN 'S'; -- Retorna como produto aderido

      ELSIF pr_cdproduto = 5 THEN -- Cartao magnetico
        -- Abre a tabela de cartoes magneticos
        OPEN cr_crapcrm;
        FETCH cr_crapcrm INTO rw_crapcrm;
        -- Se nao encotrou, nao possui nenhum cartao
        IF cr_crapcrm%NOTFOUND THEN
          CLOSE cr_crapcrm;
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        CLOSE cr_crapcrm;
        RETURN 'S'; -- Retorna como produto aderido

      ELSIF pr_cdproduto = 6 THEN -- Emissao de boletos
        -- Abre a tabela de cartoes magneticos
        OPEN cr_crapceb;
        FETCH cr_crapceb INTO rw_crapceb;
        -- Se nao encotrou, nao possui nenhum boleto
        IF cr_crapceb%NOTFOUND THEN
          CLOSE cr_crapceb;
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        CLOSE cr_crapceb;
        RETURN 'S'; -- Retorna como produto aderido

      ELSIF pr_cdproduto = 7 THEN -- Consorcio
        -- Abre a tabela de consorcios
        OPEN cr_crapcns;
        FETCH cr_crapcns INTO rw_crapcns;
        -- Se nao encotrou, nao possui consorcio
        IF cr_crapcns%NOTFOUND THEN
          CLOSE cr_crapcns;
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        CLOSE cr_crapcns;
        RETURN 'S'; -- Retorna como produto aderido

      ELSIF pr_cdproduto = 8 THEN -- Convenio folha de pagamento
        -- Abre a tabela de convenio de folha
        OPEN cr_crapemp;
        FETCH cr_crapemp INTO rw_crapemp;
        -- Se nao encotrou, nao possui convenio
        IF cr_crapemp%NOTFOUND THEN
          CLOSE cr_crapemp;
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        CLOSE cr_crapemp;
        RETURN 'S'; -- Retorna como produto aderido

      ELSIF pr_cdproduto = 9 THEN -- DDA
        -- Abre a tabela de associados
        OPEN cr_crapass;
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;

        -- Busca as informacoes de DDA
        ddda0001.pc_verifica_sacado_DDA(pr_tppessoa => rw_crapass.tppessoa,
                                        pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                        pr_flgsacad => vr_flgsacad,
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic);
        IF nvl(vr_flgsacad,0) = 1 THEN
          RETURN 'S'; -- Retorna como produto aderido
        ELSE
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;

      ELSIF pr_cdproduto = 10 THEN -- Debito Automatico
        -- Abre a tabela de debitos automaticos
        OPEN cr_crapatr;
        FETCH cr_crapatr INTO rw_crapatr;
        -- Se nao encotrou, nao possui nenhum debito automatico
        IF cr_crapatr%NOTFOUND THEN
          CLOSE cr_crapatr;
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        CLOSE cr_crapatr;
        RETURN 'S'; -- Retorna como produto aderido

      ELSIF pr_cdproduto = 11 THEN -- Domicilio Bancario
        RETURN NULL; -- Conforme conversado com a Sarah, nao deve aparecer se esta aderido ou nao

      ELSIF pr_cdproduto = 12 THEN -- Integralizacao do Capital
        -- Abre a tabela de lancamento de cotas
        OPEN cr_craplct;
        FETCH cr_craplct INTO rw_craplct;
        -- Se nao encotrou, nao possui nenhum lancamento de cotas
        IF cr_craplct%NOTFOUND THEN
          CLOSE cr_craplct;
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        CLOSE cr_craplct;
        RETURN 'S'; -- Retorna como produto aderido

      ELSIF pr_cdproduto = 13 THEN -- Limite de Credito
        -- Abre a tabela de associados
        OPEN cr_crapass;
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;

        -- Se possuir valor de limite de credito maior que zeros
        IF nvl(rw_crapass.vllimcre,0) > 0 THEN
          RETURN 'S'; -- Retorna como produto aderido
        END IF;

        RETURN 'N'; -- Retorna como produto nao aderido

      ELSIF pr_cdproduto = 14 THEN -- Limites Internet
        -- Abre a tabela de senhas para ver se o usuario tem internet liberada
        OPEN cr_crapsnh(1); -- Internet
        FETCH cr_crapsnh INTO rw_crapsnh;
        -- Se nao encotrou, nao tem acesso e nao tem limite
        IF cr_crapsnh%NOTFOUND THEN
          CLOSE cr_crapsnh;
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        CLOSE cr_crapsnh;

        -- Verifica se tem algum limite liberado
        IF nvl(rw_crapsnh.vllimweb,0) + nvl(rw_crapsnh.vllimted,0)+ nvl(rw_crapsnh.vllimvrb,0) +
           nvl(rw_crapsnh.vllimtrf,0) + nvl(rw_crapsnh.vllimpgo,0) > 0 THEN
          RETURN 'S'; -- Retorna como produto aderido
        END IF;

        RETURN 'N'; -- Retorna como produto nao aderido

      ELSIF pr_cdproduto = 15 THEN -- Plano de cotas
        -- Abre a tabela de plano de cotas
        OPEN cr_crappla;
        FETCH cr_crappla INTO rw_crappla;
        -- Se nao encotrou, nao possui nenhum plano de cotas
        IF cr_crappla%NOTFOUND THEN
          CLOSE cr_crappla;
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        CLOSE cr_crappla;
        RETURN 'S'; -- Retorna como produto aderido

      ELSIF pr_cdproduto = 16 THEN -- Poupanca programada
        -- Abre a tabela de plano de cotas
        OPEN cr_craprpp;
        FETCH cr_craprpp INTO rw_craprpp;
        -- Se nao encotrou, nao possui nenhum plano de cotas
        IF cr_craprpp%NOTFOUND THEN
          CLOSE cr_craprpp;
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        CLOSE cr_craprpp;
        RETURN 'S'; -- Retorna como produto aderido

      ELSIF pr_cdproduto = 17 THEN -- Seguro Auto
        RETURN NULL; -- Eh no sistema SICREDI. Nao tem como verificar

      ELSIF pr_cdproduto = 18 THEN -- Seguro de Vida
        -- Abre a tabela de Seguros
        OPEN cr_crapseg_vida;
        FETCH cr_crapseg_vida INTO rw_crapseg_vida;
        -- Se nao encotrou, nao possui nenhum seguro de vida
        IF cr_crapseg_vida%NOTFOUND THEN
          CLOSE cr_crapseg_vida;
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        CLOSE cr_crapseg_vida;
        RETURN 'S'; -- Retorna como produto aderido

      ELSIF pr_cdproduto = 19 THEN -- Seguro de casa
        -- Abre a tabela de Seguros
        OPEN cr_crapseg_casa;
        FETCH cr_crapseg_casa INTO rw_crapseg_casa;
        -- Se nao encotrou, nao possui nenhum seguro de casa
        IF cr_crapseg_casa%NOTFOUND THEN
          CLOSE cr_crapseg_casa;
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        CLOSE cr_crapseg_casa;
        RETURN 'S'; -- Retorna como produto aderido

      ELSIF pr_cdproduto = 20 THEN -- Guia de boas vindas
        -- Abre a tabela de associados
        OPEN cr_crapass;
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;

        -- Se nao possuir data de questionario entrege (ATENDA/RELACIONAMENTO/QUESTIONARIO)
        IF rw_crapass.dtentqst IS NULL THEN
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        RETURN 'S'; -- Retorna como produto aderido

      ELSIF pr_cdproduto = 21 THEN -- Cartao Credito CECRED
        -- Abre a tabela de cartoes de credito
        OPEN cr_crawcrd(1,0); -- Cartao Cecred
        FETCH cr_crawcrd INTO rw_crawcrd;
        -- Se nao encotrou, nao possui cartao liberado
        IF cr_crawcrd%NOTFOUND THEN
          CLOSE cr_crawcrd;
          RETURN 'N'; -- Retorna como produto nao aderido
        END IF;
        CLOSE cr_crawcrd;
        RETURN 'S'; -- Retorna como produto aderido

      ELSIF pr_cdproduto = 22 THEN -- Seguro Vida em Grupo
        RETURN NULL; -- Nao sera verificado

      ELSIF pr_cdproduto = 23 THEN -- Seguro Empresarial
        RETURN NULL; -- Nao sera verificado

      END IF;

      RETURN NULL;

    END fn_produto_habilitado;


  -- Retornar a descricao do produto
  FUNCTION fn_busca_servico (pr_cdproduto IN tbcc_produtos_coop.cdproduto%TYPE) RETURN VARCHAR2 IS

    CURSOR cr_servico IS
      SELECT  tbcc_produto.dsproduto
        FROM  tbcc_produto
        WHERE tbcc_produto.cdproduto = pr_cdproduto;
    rw_tbcc_produto cr_servico%ROWTYPE;

  BEGIN
    OPEN cr_servico;
    FETCH cr_servico INTO rw_tbcc_produto;
    CLOSE cr_servico;
    RETURN rw_tbcc_produto.dsproduto;
  END fn_busca_servico;

  -- Rotina para exibir os produtos disponiveis na tela ATENDA
  PROCEDURE pc_servicos_oferecidos(pr_nrdconta IN crapass.nrdconta%TYPE         --> Numero da conta
                                  ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo

    -- Cursor sobre os dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.inpessoa,
             crapass.cdtipcta,
             crapttl.dtnasttl
        FROM crapttl,
             crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta
         AND crapttl.cdcooper (+)= crapass.cdcooper
         AND crapttl.nrdconta (+)= crapass.nrdconta
         AND crapttl.idseqttl (+)= 1;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor sobre os produtos oferecidos
    CURSOR cr_produtos_coop(pr_tpconta  IN tbcc_produtos_coop.tpconta%TYPE
                           ,pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT tbcc_produto.cdproduto,
             tbcc_produto.dsproduto,
             decode(tbcc_produtos_coop.tpproduto,1,'obrigatorio','opcional') tpproduto,
             row_number() over (partition by tbcc_produtos_coop.tpproduto
                     order by tbcc_produtos_coop.tpproduto) nrreg
        FROM tbcc_produto,
             tbcc_produtos_coop
       WHERE tbcc_produtos_coop.cdcooper = pr_cdcooper
         AND tbcc_produtos_coop.tpconta  = pr_tpconta
         AND tbcc_produto.cdproduto      = tbcc_produtos_coop.cdproduto
       ORDER BY tbcc_produtos_coop.tpproduto,
                tbcc_produtos_coop.nrordem_exibicao;

    -- Cursor sobre os produtos oferecidos para a conta
    CURSOR cr_produto_oferecido(pr_cdproduto IN tbcc_produto.cdproduto%TYPE
                               ,pr_cdcooper IN crapcop.cdcooper%TYPE
                               ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inadesao_externa,
             dtvencimento
        FROM tbcc_produto_oferecido
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND cdproduto = pr_cdproduto;
    rw_produto_oferecido cr_produto_oferecido%ROWTYPE;

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;

    -- Variaveis de log
    vr_cdoperad VARCHAR2(100);
    vr_cdcooper NUMBER;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis gerais
    vr_contador      PLS_INTEGER := 0;
    vr_contador_tipo PLS_INTEGER := -1;
    vr_tpconta   tbcc_produtos_coop.tpconta%TYPE; --> Tipo de conta
    vr_check_adesao_externa VARCHAR2(1);          --> Indica se deve ficar habilitado o checkbox de habilitacao externa (outras instituicoes)
    vr_check_vencto         VARCHAR2(1);          --> Indica se deve ficar habilitado o campo de data de vencimento

  BEGIN

    gene0004.pc_extrai_dados(pr_xml => pr_retxml
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

    -- Abre o cursor de associados
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);

    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Associado nao encontrado!';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapass;

    -- Atualiza o tipo de conta
    IF rw_crapass.cdtipcta = 5 THEN -- Cheque Salario
      vr_tpconta := 2; -- Conta Salario
    ELSIF rw_crapass.dtnasttl IS NOT NULL AND
      TRUNC((to_char(sysdate,'yyyymmdd') - to_char(rw_crapass.dtnasttl,'yyyymmdd')) / 10000) < 18 THEN
      vr_tpconta := 3; -- Conta de menor
    ELSIF rw_crapass.cdtipcta IN (6,7,17,18) THEN -- Conta de aplicacao
      vr_tpconta := 4; -- Conta Aplicacao
    ELSIF rw_crapass.inpessoa = 1 THEN --PF
      vr_tpconta := 1; -- Conta PF
    ELSE
      vr_tpconta := 5; -- Conta PJ
    END IF;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    -- Efetua o loop sobre os produtos
    FOR rw_produtos_coop IN cr_produtos_coop(pr_tpconta => vr_tpconta
                                            ,pr_cdcooper => vr_cdcooper) LOOP

      -- Se for o primeiro registro do tipo, abre o nó de tipo
      IF rw_produtos_coop.nrreg = 1 THEN

        -- Incrementa o contador
        vr_contador_tipo := vr_contador_tipo + 1;
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0,                pr_tag_nova => 'tipo', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'tipo' , pr_posicao => vr_contador_tipo, pr_tag_nova => 'tpproduto', pr_tag_cont => rw_produtos_coop.tpproduto , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'tipo' , pr_posicao => vr_contador_tipo, pr_tag_nova => 'servicos',  pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      END IF;

      -- Atualiza o indicador de adesao externa
      IF rw_produtos_coop.cdproduto IN ( 4, -- Cartao Magnetico
                                         6, -- Cobranca bancaria
                                         7, -- Consorcio
                                         8, -- Convenio Folha de pagamento
                                         9, -- DDA
                                        10, -- Debito Automatico
                                        11, -- Domicilio bancario
                                        17, -- Seguro auto
                                        18, -- Seguro de vida
                                        19) THEN -- Seguro Residencia
        vr_check_adesao_externa := 'S';
      ELSE
        vr_check_adesao_externa := 'N';
      END IF;

      -- Atualiza o indicador de data de vencimento
      IF rw_produtos_coop.cdproduto IN (17, -- Seguro auto
                                        19) THEN -- Seguro Residencia
        vr_check_vencto := 'S';
      ELSE
        vr_check_vencto := 'N';
      END IF;


      -- Busca os dados de produtos oferecidos na conta
      OPEN cr_produto_oferecido(pr_cdproduto => rw_produtos_coop.cdproduto
                               ,pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => pr_nrdconta);

      FETCH cr_produto_oferecido INTO rw_produto_oferecido;

      CLOSE cr_produto_oferecido;

      -- Insere os servicos
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'servicos', pr_posicao => vr_contador_tipo, pr_tag_nova => 'servico', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'servico' , pr_posicao => vr_contador, pr_tag_nova => 'cdproduto', pr_tag_cont => rw_produtos_coop.cdproduto, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'servico' , pr_posicao => vr_contador, pr_tag_nova => 'dsproduto', pr_tag_cont => rw_produtos_coop.dsproduto, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'servico' , pr_posicao => vr_contador, pr_tag_nova => 'flativo'  , pr_tag_cont => fn_produto_habilitado(pr_cdcooper => vr_cdcooper,
                                                                                                                                                                        pr_nrdconta => pr_nrdconta,
                                                                                                                                                                        pr_cdproduto=> rw_produtos_coop.cdproduto), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'servico' , pr_posicao => vr_contador, pr_tag_nova => 'checkadesaoexterna', pr_tag_cont => vr_check_adesao_externa, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'servico' , pr_posicao => vr_contador, pr_tag_nova => 'checkvencto', pr_tag_cont => vr_check_vencto, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'servico' , pr_posicao => vr_contador, pr_tag_nova => 'inadesaoexterna', pr_tag_cont => nvl(rw_produto_oferecido.inadesao_externa,'N'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'servico' , pr_posicao => vr_contador, pr_tag_nova => 'dtvencto', pr_tag_cont => to_char(rw_produto_oferecido.dtvencimento,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);

      -- Incrementa o contador de servicos
      vr_contador := vr_contador + 1;

    END LOOP;

  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina PC_SERVICOS_OFERECIDOS: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_servicos_oferecidos;

  -- Atualiza a tabela de produtos oferecidos com os produtos obrigatorios que foram oferecidos na tela ATENDA
  PROCEDURE pc_produtos_obrigatorios(pr_nrdconta IN crapass.nrdconta%TYPE         --> Numero da conta
                                    ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo
      -- Cursor sobre os dados do associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.inpessoa,
               crapass.cdtipcta,
               crapttl.dtnasttl
          FROM crapttl,
               crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta
           AND crapttl.cdcooper (+)= crapass.cdcooper
           AND crapttl.nrdconta (+)= crapass.nrdconta
           AND crapttl.idseqttl (+)= 1;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor sobre os produtos oferecidos
      CURSOR cr_produtos_coop(pr_tpconta IN tbcc_produtos_coop.tpconta%TYPE
                             ,pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT tbcc_produto.cdproduto,
               tbcc_produto.dsproduto,
               decode(tbcc_produtos_coop.tpproduto,1,'obrigatorio','opcional') tpproduto,
               row_number() over (partition by tbcc_produtos_coop.tpproduto
                       order by tbcc_produtos_coop.tpproduto) nrreg
          FROM tbcc_produto,
               tbcc_produtos_coop
         WHERE tbcc_produtos_coop.cdcooper = pr_cdcooper
           AND tbcc_produtos_coop.tpconta  = pr_tpconta
           AND tbcc_produto.cdproduto      = tbcc_produtos_coop.cdproduto
         ORDER BY tbcc_produtos_coop.tpproduto,
                  tbcc_produtos_coop.nrordem_exibicao;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis de log
      vr_cdoperad VARCHAR2(100);
      vr_cdcooper NUMBER;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis gerais
      vr_tpconta   tbcc_produtos_coop.tpconta%TYPE; --> Tipo de conta
      vr_retxml    xmltype;                         --> Variavel temporaria de retorno

  BEGIN

      gene0004.pc_extrai_dados(pr_xml => pr_retxml
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

      -- Abre o cursor de associados
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);

      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Associado nao encontrado!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapass;

      -- Atualiza o tipo de conta
      IF rw_crapass.cdtipcta = 5 THEN -- Cheque Salario
        vr_tpconta := 2; -- Conta Salario
      ELSIF rw_crapass.dtnasttl IS NOT NULL AND
        TRUNC((to_char(sysdate,'yyyymmdd') - to_char(to_date(rw_crapass.dtnasttl),'yyyymmdd')) / 10000) < 18 THEN
        vr_tpconta := 3; -- Conta de menor
      ELSIF rw_crapass.cdtipcta IN (6,7,17,18) THEN -- Conta de aplicacao
        vr_tpconta := 4; -- Conta Aplicacao
      ELSIF rw_crapass.inpessoa = 1 THEN --PF
        vr_tpconta := 1; -- Conta PF
      ELSE
        vr_tpconta := 5; -- Conta PJ
      END IF;

      -- Efetua o loop sobre os produtos
      FOR rw_produtos_coop IN cr_produtos_coop(pr_tpconta => vr_tpconta
                                              ,pr_cdcooper => vr_cdcooper) LOOP

        -- Insere o produto oferecido
        pc_atualiza_produto_oferecido(pr_nrdconta => pr_nrdconta,
                                      pr_cdproduto => rw_produtos_coop.cdproduto,
                                      pr_inofertado => 'S',
                                      pr_inaderido => NULL,
                                      pr_inadesao_externa => 'N',
                                      pr_dtvencimento => NULL,
                                      pr_xmllog => pr_xmllog,
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic,
                                      pr_retxml => vr_retxml,
                                      pr_nmdcampo => pr_nmdcampo,
                                      pr_des_erro => pr_des_erro);

        -- Se ocorreu erro, cancela a rotina
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END LOOP;
    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina PC_PRODUTOS_OBRIGATORIOS: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_produtos_obrigatorios;

  -- Atualiza a tabela de produtos oferecidos com as escolhas do usuario na tela ATENDA
  PROCEDURE pc_atualiza_produto_oferecido(pr_nrdconta IN crapass.nrdconta%TYPE         --> Numero da conta
                                         ,pr_cdproduto IN tbcc_produto.cdproduto%TYPE  --> Codigo do produto
                                         ,pr_inofertado IN tbcc_produto_oferecido.inofertado%TYPE --> Indicador de produto ofertado
                                         ,pr_inaderido IN tbcc_produto_oferecido.inaderido%TYPE --> Indicador se o produto foi aderido
                                         ,pr_inadesao_externa IN tbcc_produto_oferecido.inadesao_externa%TYPE --> Indicador de adesao em outra instituicao
                                         ,pr_dtvencimento IN VARCHAR2                  --> Data de venvimento do produto na outra instituicao
                                         ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2) IS                 --> Erros do processo
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis de log
      vr_cdoperad VARCHAR2(100);
      vr_cdcooper NUMBER;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis gerais
      vr_inaderido     tbcc_produto_oferecido.inaderido%TYPE; -- Indicador de produto aderido
    BEGIN

      gene0004.pc_extrai_dados(pr_xml => pr_retxml
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

      -- Se nao foi informado parametro de adesao, deve-se buscar no sistema
      IF pr_inaderido IS NULL THEN
        -- Verifica se o produto foi aderido
        vr_inaderido := nvl(fn_produto_habilitado(vr_cdcooper, pr_nrdconta, pr_cdproduto),'N');
      ELSE
        vr_inaderido := pr_inaderido;
      END IF;

      -- Insere na tabela de produtos oferecidos
      BEGIN
        INSERT INTO tbcc_produto_oferecido
          (cdcooper,
           nrdconta,
           cdproduto,
           inofertado,
           inaderido,
           inadesao_externa,
           dtvencimento)
         VALUES
          (vr_cdcooper,
           pr_nrdconta,
           pr_cdproduto,
           pr_inofertado,
           vr_inaderido,
           pr_inadesao_externa,
           to_date(pr_dtvencimento,'DD/MM/YYYY'));
      EXCEPTION
        WHEN dup_val_on_index THEN
          -- Se ja existir, deve-se apenas atualizar
          BEGIN
            UPDATE tbcc_produto_oferecido
               SET inadesao_externa = pr_inadesao_externa,
                   dtvencimento     = to_date(pr_dtvencimento,'DD/MM/YYYY')
                   -- Nao deve-se atualizar os inofertado e inaderido porque estes campos
                   -- devem ficar com a situacao do primeiro cadastro
             WHERE cdcooper = vr_cdcooper
               AND nrdconta = pr_nrdconta
               AND cdproduto = pr_cdproduto;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCC_PRODUTO_OFERECIDO: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir TBCC_PRODUTO_OFERECIDO: '||SQLERRM;
          RAISE vr_exc_saida;
      END;


    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina PC_ATUALIZA_PRODUTO: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_atualiza_produto_oferecido;

  PROCEDURE pc_busca_conteudo_campo(pr_retxml    IN OUT NOCOPY XMLType,    --> XML de retorno da operadora
                                    pr_nrcampo   IN VARCHAR2,              --> Campo a ser buscado no XML
                                    pr_indcampo  IN VARCHAR2,              --> Tipo de dado: S=String, D=Data, N=Numerico
                                    pr_retorno  OUT VARCHAR2,              --> Retorno do campo do xml
                                    pr_dscritic IN OUT VARCHAR2) IS        --> Texto de erro/critica encontrada

   /* .............................................................................

         Programa: pc_busca_conteudo_campo
         Sistema : Rotinas para cadastros
         Sigla   : CRED
         Autor   : Tiago Castro (RKAM)
         Data    : Julho/2015.                         Ultima atualizacao:

         Dados referentes ao programa:

         Frequencia: Sempre que for chamado.
         Objetivo  : Rotinas para manutenção (cadastro) dos dados para sistema Web/genérico

         Alteracoes:

      ............................................................................. */

      vr_dscritic   VARCHAR2(4000); --> descricao do erro
      vr_exc_saida  EXCEPTION; --> Excecao prevista
      vr_tab_xml   gene0007.typ_tab_tagxml; --> PL Table para armazenar conteúdo XML
    BEGIN
      -- Busca a informacao no XML
      gene0007.pc_itera_nodos(pr_xpath      => pr_nrcampo
                             ,pr_xml        => pr_retxml
                             ,pr_list_nodos => vr_tab_xml
                             ,pr_des_erro   => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Se encontrou mais de um registro, deve dar mensagem de erro
      IF  vr_tab_xml.count > 1 THEN
        vr_dscritic := 'Mais de um registro XML encontrado.';
        RAISE vr_exc_saida;
      ELSIF vr_tab_xml.count = 1 THEN -- Se encontrou, retornar o texto
        IF pr_indcampo = 'D' THEN -- Se o tipo de dado for Data, transformar para data
          -- Se for tudo zeros, desconsiderar
          IF vr_tab_xml(0).tag IN ('00000000','0')  THEN
            pr_retorno := NULL;
          ELSE
            pr_retorno := to_date(vr_tab_xml(0).tag,'yyyymmdd');
          END IF;
        ELSE
          pr_retorno := replace(vr_tab_xml(0).tag,'.',',');
        END IF;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro ao buscar campo '||pr_nrcampo||'. '||vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao buscar campo '||pr_nrcampo||'. '||SQLERRM;
    END;

     PROCEDURE pc_consulta_servicos(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                   ,pr_tpproduto  IN tbcc_produtos_coop.tpproduto%TYPE  --> tipo de produto
                                   ,pr_tpconta    IN tbcc_produtos_coop.tpconta%TYPE    --> tipo de conta
                                   ,pr_xmllog     IN VARCHAR2                           --> XML com informações de LOG
                                   ,pr_cdcritic   OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                   ,pr_dscritic   OUT VARCHAR2                          --> Descricao da critica
                                   ,pr_retxml     IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                   ,pr_nmdcampo   OUT VARCHAR2                          --> Nome do campo com erro
                                   ,pr_des_erro   OUT VARCHAR2) IS

    /* .............................................................................

         Programa: pc_consulta_servicos
         Sistema : Rotinas para cadastros
         Sigla   : CRED
         Autor   : Tiago Castro (RKAM)
         Data    : Julho/2015.                         Ultima atualizacao: 30/03/2016

         Dados referentes ao programa:

         Frequencia: Sempre que for chamado.
         Objetivo  : Rotinas para manutenção (cadastro) dos dados para sistema Web/genérico

         Alteracoes: 30/03/2016 - Alterado para filtrar apenas os produtos ativos
		                          para oferta via tela atenda. (Anderson)

      ............................................................................. */

      -- busca servicos aderidos
      CURSOR cr_prod_aderidos IS
        SELECT tbcc_produtos_coop.cdproduto,
               tbcc_produtos_coop.nrordem_exibicao,
               tbcc_produto.dsproduto
        FROM   tbcc_produtos_coop,
               tbcc_produto
        WHERE  tbcc_produto.cdproduto = tbcc_produtos_coop.cdproduto
        AND    tbcc_produtos_coop.cdcooper  = pr_cdcooper
        AND    tbcc_produtos_coop.tpconta   = pr_tpconta
        AND    tbcc_produtos_coop.tpproduto = pr_tpproduto
        ORDER  BY tbcc_produtos_coop.nrordem_exibicao;

      -- busca servicos disponiveis
      CURSOR cr_prod_dispo IS
        SELECT tbcc_produto.cdproduto,
               tbcc_produto.dsproduto
        FROM   tbcc_produto
		WHERE  tbcc_produto.flgitem_soa = 1  /* Somente os produtos cuja flag "item ofertado na tela atenda" esteja marcada */
        ORDER BY tbcc_produto.dsproduto;

      vr_texto_completo VARCHAR2(32600);           --> Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_des_xml        CLOB;                      --> XML tbcc_produto

      -- exceptions
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

    BEGIN
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      vr_texto_completo := NULL;
      -- inicia xml
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'<?xml version="1.0" encoding="utf-8"?><root>');
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'<servicos>');
      -- varre todos os servicos disponiveis
      FOR rw_tbcc_produto IN cr_prod_dispo LOOP
        -- cria xml com servicos disponiveis
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                        '<disponiveis>'||
                                        '  <codigo>'  ||rw_tbcc_produto.cdproduto||'</codigo>'||
                                        '  <produto>' ||rw_tbcc_produto.dsproduto||'</produto>'||
                                        '</disponiveis>');
      END LOOP;
      -- varre todos os servicos aderidos
      FOR tbcc_produtos_coop IN cr_prod_aderidos LOOP
        -- cria xml com servicos aderidos
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                        '<aderidos>'||
                                        '  <codigo>'  ||tbcc_produtos_coop.cdproduto||'</codigo>'||
                                        '  <produto>'  ||tbcc_produtos_coop.dsproduto||'</produto>'||
                                        '  <exibicao>'  ||tbcc_produtos_coop.nrordem_exibicao||'</exibicao>'||
                                        '</aderidos>');
      END LOOP;
      -- fecha tag servicos
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'</servicos>');
      -- fecha tag principal
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'</root>');
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'', TRUE);
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_des_xml);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
    EXCEPTION
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Devolvemos código e critica encontradas das variaveis locais
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || upper(pr_dscritic) || '</Erro></Root>');
          ROLLBACK;
        WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 0;
          pr_dscritic := sqlerrm;
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||upper(pr_dscritic) ||'</Erro></Root>');
          ROLLBACK;
    END pc_consulta_servicos;

    PROCEDURE pc_valida_consistencia (pr_cdcooper   IN crapcop.cdcooper%TYPE
                                   ,pr_tpproduto  IN tbcc_produtos_coop.tpproduto%TYPE  --> tipo de produto
                                   ,pr_tpconta    IN tbcc_produtos_coop.tpconta%TYPE    --> tipo de conta
                                   ,pr_servico    IN VARCHAR2                           --> produtos aderidos
                                   ,pr_xmllog     IN VARCHAR2                           --> XML com informações de LOG
                                   ,pr_cdcritic   OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                   ,pr_dscritic   OUT VARCHAR2                          --> Descricao da critica
                                   ,pr_retxml     IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                   ,pr_nmdcampo   OUT VARCHAR2                          --> Nome do campo com erro
                                   ,pr_des_erro   OUT VARCHAR2)IS

    /* .............................................................................

         Programa: pc_valida_consistencia
         Sistema : Rotinas para cadastros
         Sigla   : CRED
         Autor   : Tiago Castro (RKAM)
         Data    : Julho/2015.                         Ultima atualizacao:

         Dados referentes ao programa:

         Frequencia: Sempre que for chamado.
         Objetivo  : Rotinas para manutenção (cadastro) dos dados para sistema Web/genérico

         Alteracoes:

      ............................................................................. */

    -- busca se ja existe o mesmo servico cadastrado para outro tipo de servico

     vr_quebra   LONG DEFAULT pr_servico || ';'; --> armazena string com os codigos dos servicos
     vr_idx      NUMBER; -- indice para quebra de string
     vr_cdproduto  INTEGER; --> codigo so servico

    CURSOR cr_consistencia IS
      SELECT  decode(tbcc_produtos_coop.tpproduto,1, 'Obrigatorio', 'Opcional')tpproduto
      FROM    tbcc_produtos_coop
      WHERE   tbcc_produtos_coop.cdcooper   = pr_cdcooper
      AND     tbcc_produtos_coop.tpconta    = pr_tpconta
      AND     tbcc_produtos_coop.cdproduto  = vr_cdproduto
      AND     tbcc_produtos_coop.tpproduto  <> pr_tpproduto;

    rw_tbcc_produtos_coop cr_consistencia%ROWTYPE; --> tipo de servico



    BEGIN
      LOOP
        -- Identifica ponto de quebra inicial
        vr_idx := instr(vr_quebra, ';');
        -- Clausula de saída para o loop
        exit WHEN nvl(vr_idx, 0) = 0;
        vr_cdproduto := trim(substr(vr_quebra, 1, vr_idx - 1));
        -- Atualiza a variável com a string integral eliminando o bloco quebrado
        vr_quebra := substr(vr_quebra, vr_idx + LENGTH(';'));

        -- busca se existe inconsistencia
        OPEN cr_consistencia;
        FETCH cr_consistencia INTO rw_tbcc_produtos_coop;
        CLOSE cr_consistencia;
        -- se existir inconsistencia deve retornar erro.
        IF rw_tbcc_produtos_coop.tpproduto IS NOT NULL THEN
          pr_dscritic := 'Servico '|| fn_busca_servico(vr_cdproduto)||' ja esta parametrizado como '||rw_tbcc_produtos_coop.tpproduto;
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || upper(pr_dscritic) || '</Erro></Root>');
        END IF;
      END LOOP;
    END pc_valida_consistencia;

    PROCEDURE pc_inclui_servicos (pr_cdcooper   IN crapcop.cdcooper%TYPE
                                 ,pr_tpproduto  IN tbcc_produtos_coop.tpproduto%TYPE  --> tipo de produto
                                 ,pr_tpconta    IN tbcc_produtos_coop.tpconta%TYPE    --> tipo de conta
                                 ,pr_servicos   IN VARCHAR2                           --> produtos aderidos
                                 ,pr_xmllog     IN VARCHAR2                           --> XML com informações de LOG
                                 ,pr_cdcritic   OUT crapcri.cdcritic%TYPE             --> Codigo da critica
                                 ,pr_dscritic   OUT VARCHAR2                          --> Descricao da critica
                                 ,pr_retxml     IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                 ,pr_nmdcampo   OUT VARCHAR2                          --> Nome do campo com erro
                                 ,pr_des_erro   OUT VARCHAR2) IS


    /* .............................................................................

         Programa: pc_inclui_servicos
         Sistema : Rotinas para cadastros
         Sigla   : CRED
         Autor   : Tiago Castro (RKAM)
         Data    : Julho/2015.                         Ultima atualizacao:

         Dados referentes ao programa:

         Frequencia: Sempre que for chamado.
         Objetivo  : Rotinas para manutenção (cadastro) dos dados para sistema Web/genérico

         Alteracoes:

      ............................................................................. */

      vr_cdproduto  INTEGER; --> codigo so servico
      vr_contador   INTEGER; --> contador para armazenar ordem de exibicao na tela cadsoa

      vr_texto_completo VARCHAR2(32600);           --> Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_des_xml        CLOB;                      --> XML tbcc_produto

      vr_quebra   LONG DEFAULT pr_servicos || ';'; --> armazena string com os codigos dos servicos
      vr_idx      NUMBER; -- indice para quebra de string

      -- exceptions
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

    BEGIN

      pc_valida_consistencia(pr_cdcooper  => pr_cdcooper
                         , pr_tpproduto => pr_tpproduto
                         , pr_tpconta   => pr_tpconta
                         , pr_servico   => pr_servicos
                         , pr_xmllog    => pr_xmllog
                         , pr_cdcritic  => vr_cdcritic
                         , pr_dscritic  => vr_dscritic
                         , pr_retxml    => pr_retxml
                         , pr_nmdcampo  => pr_nmdcampo
                         , pr_des_erro  => pr_des_erro);
      IF vr_dscritic  IS NOT NULL THEN
          RAISE vr_exc_saida;
      END IF;

      -- Primeiro sempre exclui o cadastro para poder inserir novamente
      BEGIN
        DELETE FROM tbcc_produtos_coop
        WHERE tbcc_produtos_coop.cdcooper  = pr_cdcooper
        AND   tbcc_produtos_coop.tpconta   = pr_tpconta
        AND   tbcc_produtos_coop.tpproduto = pr_tpproduto;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'pc_inclui_servicos - Erro ao excluir dados.' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      -- Inicializa o contador de consultas
      vr_contador := 1;
      LOOP
        -- Identifica ponto de quebra inicial
        vr_idx := instr(vr_quebra, ';');
        -- Clausula de saída para o loop
        exit WHEN nvl(vr_idx, 0) = 0;
        vr_cdproduto := trim(substr(vr_quebra, 1, vr_idx - 1));
        -- Atualiza a variável com a string integral eliminando o bloco quebrado
        vr_quebra := substr(vr_quebra, vr_idx + LENGTH(';'));
        -- insere novo cadastro de servicos aderidos
        BEGIN
          INSERT INTO tbcc_produtos_coop
          (
           cdcooper
          ,tpconta
          ,cdproduto
          ,nrordem_exibicao
          ,tpproduto
          )
          VALUES
          (
           pr_cdcooper
          ,pr_tpconta
          ,vr_cdproduto
          ,vr_contador
          ,pr_tpproduto
          );
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao realizar inclusao. '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- incrementa + 1 no contador
        vr_contador := vr_contador + 1;
      END LOOP;
      -- salva informacoes inseridas
      COMMIT;

    EXCEPTION
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Devolvemos código e critica encontradas das variaveis locais
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || upper(pr_dscritic) || '</Erro></Root>');
          ROLLBACK;
        WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          pr_cdcritic := 0;
          pr_dscritic := sqlerrm;
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||upper(pr_dscritic) ||'</Erro></Root>');
          ROLLBACK;
    END pc_inclui_servicos;

  -- Rotina para listar os creditos recebidos dos ultimos 7 meses
  PROCEDURE pc_lista_cred_recebidos(pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

    -- Registro sobre a tabela de datas
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Cursor sobre a tabela de lancamentos
    CURSOR cr_craplcm(pr_dtinicio IN crapdat.dtmvtolt%TYPE
                     ,pr_dtfim    IN crapdat.dtmvtolt%TYPE
                     ,pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_cdhistor IN crapprm.dsvlrprm%TYPE) IS
      SELECT sum(craplcm.vllanmto) valor
        FROM craplcm
       WHERE craplcm.dtmvtolt BETWEEN pr_dtinicio AND pr_dtfim
         AND craplcm.cdcooper = pr_cdcooper
         AND craplcm.nrdconta = pr_nrdconta
         AND INSTR(pr_cdhistor,';'||craplcm.cdhistor||';') > 0;
    rw_craplcm cr_craplcm%ROWTYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Variaveis de log
    vr_cdoperad VARCHAR2(100);
    vr_cdcooper NUMBER;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_cdhistor crapprm.dsvlrprm%TYPE;
    
    -- Variaveis gerais
    vr_dtinicio DATE;
    vr_vltrimestre craplcm.vllanmto%TYPE;
    vr_vlsemestre  craplcm.vllanmto%TYPE;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB;
    
    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;

  BEGIN
   
    gene0004.pc_extrai_dados(pr_xml => pr_retxml
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

    vr_cdhistor := gene0001.fn_param_sistema(pr_cdcooper => vr_cdcooper,
                                             pr_nmsistem => 'CRED',
                                             pr_cdacesso => 'HIS_CRED_RECEBIDOS');

    -- Busca a data do sistema
    OPEN btch0001.cr_crapdat(vr_cdcooper);

    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    CLOSE btch0001.cr_crapdat;

    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

    -- Atualiza a data de inicio da busca
    vr_dtinicio := TRUNC(ADD_MONTHS(rw_crapdat.dtmvtolt,-6),'MM');

    -- Efetua loop sobre os meses de busca
    FOR x IN 1..6 LOOP

      -- Busca o valor do do mes solicitado
      OPEN cr_craplcm(pr_dtinicio => vr_dtinicio
                     ,pr_dtfim    => LAST_DAY(vr_dtinicio)
                     ,pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_cdhistor => vr_cdhistor);

      FETCH cr_craplcm INTO rw_craplcm;

      CLOSE cr_craplcm;

      -- Efetua a somatoria do trimestre
      IF x BETWEEN 4 AND 6 THEN
        vr_vltrimestre := NVL(vr_vltrimestre,0) + NVL(rw_craplcm.valor,0);
      END IF;

      -- Efetua a somatoria do semestre
      IF x <= 6 THEN
        vr_vlsemestre := NVL(vr_vlsemestre,0) + NVL(rw_craplcm.valor,0);
      END IF;

      -- Carrega os dados
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<inf>'||
                                                      '<mes_' || x || '>' || TO_CHAR(vr_dtinicio,'Mon/yyyy','nls_date_language=portuguese') ||'</mes_' || x || '>'||
                                                      '<valor_' || x || '>' || TO_CHAR(rw_craplcm.valor) ||'</valor_' || x || '>'||
                                                   '</inf>');

      -- Incrementa o mês
      vr_dtinicio := ADD_MONTHS(vr_dtinicio, 1);

    END LOOP;

    -- Carrega os dados
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<inf>'||
                                                    '<trimestre>Trimestre</trimestre>'||
                                                    '<valor_t>' || TO_CHAR(ROUND(vr_vltrimestre/3,2)) ||'</valor_t>'||
                                                 '</inf>'||
                                                 '<inf>'||
                                                    '<semestre>Semestre</semestre>'||
                                                    '<valor_s>' || TO_CHAR(ROUND(vr_vlsemestre/6,2)) ||'</valor_s>'||
                                                 '</inf>'||
                                                 '</Dados>'
                           ,pr_fecha_xml      => TRUE);

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_lista_conta: ' || SQLERRM;
      pr_des_erro := 'NOK';

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_lista_cred_recebidos;

  -- Rotina para veririfcar se é o primeiro acesso a tela Produtos
  PROCEDURE pc_primeiro_acesso(pr_nrdconta      IN crapcbr.cdbircon%TYPE --> Numero da conta
                              ,pr_xmllog        IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic      OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic      OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml        IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo      OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro      OUT VARCHAR2) IS         --> Erros do processo

    -- Selecionar os dados do atendimento SAC
    CURSOR cr_crapass(pr_cdcooper      IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta      IN crapass.nrdconta%TYPE) IS
    SELECT cdcooper
          ,nrdconta
          ,hrinicad
          ,dtmvtolt
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    CURSOR cr_tbcc_produto_oferecido(pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
    SELECT tbcc_produto_oferecido.nrdconta
      FROM tbcc_produto_oferecido
     WHERE tbcc_produto_oferecido.cdcooper = pr_cdcooper
       AND tbcc_produto_oferecido.nrdconta = pr_nrdconta;
    rw_tbcc_produto_oferecido cr_tbcc_produto_oferecido%ROWTYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Variaveis de log
    vr_cdoperad VARCHAR2(100);
    vr_cdcooper NUMBER;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Varivaies locais
    vr_servico_ativo VARCHAR2(1);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

  BEGIN

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

    -- Abre o cursor de data
    OPEN btch0001.cr_crapdat(vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Abre o cursor de associados
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Associado nao encontrado!';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapass;

    --Abre o cursor
    OPEN cr_tbcc_produto_oferecido(pr_cdcooper => vr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta);

    FETCH cr_tbcc_produto_oferecido INTO rw_tbcc_produto_oferecido;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Acesso/>');

    --Não é o primeiro acesso
    IF cr_tbcc_produto_oferecido%FOUND THEN
      vr_servico_ativo := 'N';
    ELSE
      -- Se nao tiver hora informada, entao eh cadastro antigo. Nao eh primeiro acesso
      IF nvl(rw_crapass.hrinicad,0) = 0 OR
         rw_crapass.dtmvtolt <> rw_crapdat.dtmvtolt THEN -- Ou se o cooperado foi admitido em outra data
        vr_servico_ativo := 'N';
      ELSE
        --Primeiro acesso
        vr_servico_ativo := 'S';
      END IF;
    END IF;

    --Encerra o cursor
    CLOSE cr_tbcc_produto_oferecido;

    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Acesso'            --> Nome da TAG XML
                             ,pr_atrib => 'ativo'             --> Nome do atributo
                             ,pr_atval => vr_servico_ativo    --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    --Retorno OK
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic:= 'Erro na cada0003pc_primeiro_acesso --> '|| SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_primeiro_acesso;

  -- Incluir hora do termino do cadastramento do cooperado
  PROCEDURE pc_encerra_cadastramento (pr_cdcooper IN crapcop.cdcooper%TYPE --> cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE --> numero da conta
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2)IS          --> Erros do processo

  vr_exc_saida EXCEPTION;

  BEGIN
    -- atualiza conta com a hora de termino do cadastro do cooperado
    BEGIN
      UPDATE crapass
      SET    crapass.hrfimcad = decode(nvl(crapass.hrfimcad,0),0,
                                  decode(nvl(crapass.hrinicad,0),0,0,to_char(SYSDATE,'sssss')),
                                  0)
      WHERE  crapass.cdcooper = pr_cdcooper
      AND    crapass.nrdconta = pr_nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
      pr_dscritic := 'Erro ao atualizar hora fim na crapass. Erro: '||SQLERRM;
      RAISE vr_exc_saida;
    END;
    -- salva informacoes inseridas
    COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_dscritic:= 'Erro na cada0003.pc_encerra_cadastramento --> '|| SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_encerra_cadastramento;

  PROCEDURE pc_retorna_consultores(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Descrição do erro

    CURSOR cr_consultor IS
        SELECT t.cdconsultor
             , to_char(t.dtinclus,'DD/MM/YYYY') dtinclus
             , t.cdoperad
             , c.nmoperad
          FROM crapope        c
             , tbcc_consultor t
         WHERE t.cdcooper     = pr_cdcooper
           and t.nrsequen     = 0
           and c.cdcooper (+) = t.cdcooper
           and c.cdoperad (+) = t.cdoperad
         ORDER
            BY t.cdconsultor;

    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_contador      NUMBER(5) := 0;
  BEGIN
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    for rw_consultor in cr_consultor loop
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'consultor', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'consultor', pr_posicao => vr_contador, pr_tag_nova => 'cdconsultor', pr_tag_cont => rw_consultor.cdconsultor, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'consultor', pr_posicao => vr_contador, pr_tag_nova => 'dtinclus', pr_tag_cont => rw_consultor.dtinclus, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'consultor', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_consultor.cdoperad, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'consultor', pr_posicao => vr_contador, pr_tag_nova => 'nmoperad', pr_tag_cont => rw_consultor.nmoperad, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    end loop;

    if vr_contador = 0 then
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'consultor', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'consultor', pr_posicao => vr_contador, pr_tag_nova => 'cdconsultor', pr_tag_cont => 0, pr_des_erro => vr_dscritic);
    end if;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_retorna_consultores: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
  PROCEDURE pc_retorna_consultor_pa(pr_cdcooper    IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                                   ,pr_cdconsultor IN tbcc_consultor.cdconsultor%TYPE --> Codigo do Consultor
                                   ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                                   ,pr_cdcritic    OUT PLS_INTEGER                    --> Código da crítica
                                   ,pr_dscritic    OUT VARCHAR2                       --> Descrição da crítica
                                   ,pr_retxml      IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                                   ,pr_nmdcampo    OUT VARCHAR2                       --> Nome do campo com erro
                                   ,pr_des_erro    OUT VARCHAR2) IS                   --> Descrição do erro

    CURSOR cr_agencia(pr_nrsequen in number) IS
        SELECT tc.cdoperad
             , o.nmoperad
             , t.cdagenci
             , c.nmextage
          FROM crapope           o
             , crapage           c
             , tbcc_consultor_pa t
             , tbcc_consultor    tc
         WHERE o.cdcooper     (+) = tc.cdcooper
           AND o.cdoperad     (+) = tc.cdoperad
           AND tc.cdcooper        = t.cdcooper
           AND tc.cdconsultor     = t.cdconsultor
           AND tc.nrsequen        = t.nrsequen
           AND c.cdcooper         = t.cdcooper
           AND c.cdagenci         = t.cdagenci
           AND t.cdcooper         = pr_cdcooper
           AND t.cdconsultor      = pr_cdconsultor
           AND t.nrsequen         = pr_nrsequen
         ORDER
            BY t.cdagenci;

    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_contador      NUMBER(5) := 0;
    vr_nrsequen      tbcc_consultor.nrsequen%TYPE;
  BEGIN
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    for rw_agencia in cr_agencia(0) LOOP
      IF vr_contador = 0 THEN
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'operador', pr_tag_cont => null, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'operador', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_agencia.cdoperad, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'operador', pr_posicao => vr_contador, pr_tag_nova => 'nmoperad', pr_tag_cont => rw_agencia.nmoperad, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'operador', pr_posicao => vr_contador, pr_tag_nova => 'situacao', pr_tag_cont => 'ATIVO', pr_des_erro => vr_dscritic);
      END IF;

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'agencia', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia', pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_agencia.cdagenci, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia', pr_posicao => vr_contador, pr_tag_nova => 'nmextage', pr_tag_cont => rw_agencia.nmextage, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    end loop;

    if vr_contador = 0 then  
      select nvl(max(t.nrsequen),-1)
        into vr_nrsequen
        from tbcc_consultor t
       where t.cdcooper    = pr_cdcooper
         and t.cdconsultor = pr_cdconsultor;

      if vr_nrsequen = -1 then
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'agencia', pr_tag_cont => null, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia', pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => 0, pr_des_erro => vr_dscritic);
      else
        for rw_agencia in cr_agencia(vr_nrsequen) LOOP
          IF vr_contador = 0 THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'operador', pr_tag_cont => null, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'operador', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_agencia.cdoperad, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'operador', pr_posicao => vr_contador, pr_tag_nova => 'nmoperad', pr_tag_cont => rw_agencia.nmoperad, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'operador', pr_posicao => vr_contador, pr_tag_nova => 'situacao', pr_tag_cont => 'INATIVO', pr_des_erro => vr_dscritic);
          END IF;

          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'agencia', pr_tag_cont => null, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia', pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_agencia.cdagenci, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia', pr_posicao => vr_contador, pr_tag_nova => 'nmextage', pr_tag_cont => rw_agencia.nmextage, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;
        end loop;
      end if;
    end if;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_retorna_consultor_pa: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
  PROCEDURE pc_retorna_agencia(pr_cdcooper    IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                              ,pr_cdagenci    IN crapage.cdagenci%TYPE           --> Codigo da Agencia
                              ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                              ,pr_cdcritic    OUT PLS_INTEGER                    --> Código da crítica
                              ,pr_dscritic    OUT VARCHAR2                       --> Descrição da crítica
                              ,pr_retxml      IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                              ,pr_nmdcampo    OUT VARCHAR2                       --> Nome do campo com erro
                              ,pr_des_erro    OUT VARCHAR2) IS                   --> Descrição do erro

    CURSOR cr_agencia IS
      SELECT c.cdagenci
           , c.nmextage
        FROM crapage           c
       WHERE c.cdcooper = pr_cdcooper
         AND c.cdagenci = pr_cdagenci
       ORDER
          BY c.cdagenci;

    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_contador      NUMBER(5) := 0;
  BEGIN
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    for rw_agencia in cr_agencia loop
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'agencia', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia', pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_agencia.cdagenci, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia', pr_posicao => vr_contador, pr_tag_nova => 'nmextage', pr_tag_cont => rw_agencia.nmextage, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    end loop;

    if vr_contador = 0 then
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'agencia', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'agencia', pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => 0, pr_des_erro => vr_dscritic);
    end if;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_retorna_agencia: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
  PROCEDURE pc_retorna_operador(pr_cdcooper    IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                               ,pr_cdoperad    IN crapope.cdoperad%TYPE           --> Codigo da Agencia
                               ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                               ,pr_cdcritic    OUT PLS_INTEGER                    --> Código da crítica
                               ,pr_dscritic    OUT VARCHAR2                       --> Descrição da crítica
                               ,pr_retxml      IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                               ,pr_nmdcampo    OUT VARCHAR2                       --> Nome do campo com erro
                               ,pr_des_erro    OUT VARCHAR2) IS                   --> Descrição do erro

    CURSOR cr_operador IS
      SELECT c.cdoperad
           , c.nmoperad
           , c.nvoperad
        FROM crapope           c
       WHERE c.cdcooper = pr_cdcooper
         AND c.cdoperad = pr_cdoperad
       ORDER
          BY c.cdoperad;

    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_contador      NUMBER(5) := 0;
  BEGIN
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    for rw_operador in cr_operador loop
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'operador', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'operador', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_operador.cdoperad, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'operador', pr_posicao => vr_contador, pr_tag_nova => 'nmoperad', pr_tag_cont => rw_operador.nmoperad, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'operador', pr_posicao => vr_contador, pr_tag_nova => 'nvoperad', pr_tag_cont => rw_operador.nvoperad, pr_des_erro => vr_dscritic);

      vr_contador := vr_contador + 1;
    end loop;

    if vr_contador = 0 then
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'operador', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'operador', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => 0, pr_des_erro => vr_dscritic);
    end if;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_retorna_operador: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;

  PROCEDURE pc_incluir_consultor(pr_cdcooper IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                                ,pr_cdconsul IN tbcc_consultor.cdconsultor%TYPE --> Código do Consultor
                                ,pr_cdoperad IN tbcc_consultor.cdoperad%TYPE    --> Código do Operador
                                ,pr_xmllog   IN VARCHAR2                        --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                    --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2                       --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                       --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS                   --> Descrição do erro
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
  BEGIN
    INSERT INTO tbcc_consultor(cdcooper
                              ,cdconsultor
                              ,nrsequen
                              ,dtinclus
                              ,cdoperad)
                              values
                              (pr_cdcooper
                              ,pr_cdconsul
                              ,0 --Inclusão sempre será sequencia zero
                              ,trunc(sysdate)
                              ,pr_cdoperad);
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Posicao de Consultor ja cadastrada, favor utilizar outra numeracao!';

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_retorna_consultores: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
  PROCEDURE pc_incluir_agencia(pr_cdcooper IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                              ,pr_cdconsul IN tbcc_consultor.cdconsultor%TYPE --> Código do Consultor
                              ,pr_cdagenci IN crapage.cdagenci%TYPE           --> Código da Agencia
                              ,pr_xmllog   IN VARCHAR2                        --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER                    --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2                       --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                       --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS                   --> Descrição do erro
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
  BEGIN
    INSERT INTO tbcc_consultor_pa(cdcooper
                                 ,cdconsultor
                                 ,nrsequen
                                 ,cdagenci)
                                 values
                                 (pr_cdcooper
                                 ,pr_cdconsul
                                 ,0 --Inclusão sempre será sequencia zero
                                 ,pr_cdagenci);
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      --Se enviar uma agência já cadastrada, apenas ignora
      NULL;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_incluir_agencia: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
  PROCEDURE pc_inativa_consultor(pr_cdcooper IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                                ,pr_cdconsul IN tbcc_consultor.cdconsultor%TYPE --> Código do Consultor
                                ,pr_xmllog   IN VARCHAR2                        --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                    --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2                       --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                       --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS                   --> Descrição do erro
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_nrsequen      NUMBER(5);
  BEGIN
    SELECT nvl(max(t.nrsequen) +1,-1)
      INTO vr_nrsequen
      FROM tbcc_consultor t
     WHERE t.cdcooper    = pr_cdcooper
       AND t.cdconsultor = pr_cdconsul;
    
    if vr_nrsequen <> -1 then
      UPDATE tbcc_consultor t
         SET t.nrsequen    = vr_nrsequen
       WHERE t.cdcooper    = pr_cdcooper
         AND t.cdconsultor = pr_cdconsul
         AND t.nrsequen    = 0;
       
      UPDATE tbcc_consultor_pa t
         SET t.nrsequen    = vr_nrsequen
       WHERE t.cdcooper    = pr_cdcooper
         AND t.cdconsultor = pr_cdconsul
         AND t.nrsequen    = 0;
    end if;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_inativa_consultor: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
  PROCEDURE pc_retorna_contas(pr_cdcooper       IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                             ,pr_cdconsultororg IN tbcc_consultor.cdconsultor%TYPE --> Codigo do Consultor
                             ,pr_cdconsultordst IN tbcc_consultor.cdconsultor%TYPE --> Codigo do Consultor
                             ,pr_xmllog         IN VARCHAR2                        --> XML com informações de LOG
                             ,pr_cdcritic       OUT PLS_INTEGER                    --> Código da crítica
                             ,pr_dscritic       OUT VARCHAR2                       --> Descrição da crítica
                             ,pr_retxml         IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                             ,pr_nmdcampo       OUT VARCHAR2                       --> Nome do campo com erro
                             ,pr_des_erro       OUT VARCHAR2) IS                   --> Descrição do erro

    CURSOR cr_contas IS
      select c.nrdconta
           , c.nmprimtl
           , c.cdagenci
           , ca.nmextage
        from tbcc_consultor_pa ta
           , tbcc_consultor_pa tb
           , crapage ca
           , crapass c
       where tb.cdcooper = pr_cdcooper
         and tb.cdconsultor = pr_cdconsultordst
         and tb.nrsequen = 0
         and tb.cdagenci = ta.cdagenci
         and ta.cdcooper = pr_cdcooper
         and ta.cdconsultor = pr_cdconsultororg
         and ta.nrsequen = 0
         and ta.cdagenci = c.cdagenci
         and ca.cdcooper = c.cdcooper
         and ca.cdagenci = c.cdagenci
         and c.cdcooper = ta.cdcooper
         and c.dtdemiss is null
         and c.cdconsul = ta.cdconsultor;

    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_contador      NUMBER(5) := 0;
  BEGIN
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    for rw_contas in cr_contas LOOP
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'conta', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_contas.nrdconta, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'nmprimtl', pr_tag_cont => rw_contas.nmprimtl, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_contas.cdagenci, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'nmextage', pr_tag_cont => rw_contas.nmextage, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    end loop;

    if vr_contador = 0 then
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'conta', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => 0, pr_des_erro => vr_dscritic);
    end if;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_retorna_contas: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
  PROCEDURE pc_transfere_conta(pr_cdcooper       IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                              ,pr_cdconsultordst IN tbcc_consultor.cdconsultor%TYPE --> Codigo do Consultor
                              ,pr_nrdconta       IN crapass.nrdconta%TYPE           --> Número da conta
                              ,pr_cdoperad       IN crapope.cdoperad%TYPE           --> Código do Operador
                              ,pr_xmllog         IN VARCHAR2                        --> XML com informações de LOG
                              ,pr_cdcritic       OUT PLS_INTEGER                    --> Código da crítica
                              ,pr_dscritic       OUT VARCHAR2                       --> Descrição da crítica
                              ,pr_retxml         IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                              ,pr_nmdcampo       OUT VARCHAR2                       --> Nome do campo com erro
                              ,pr_des_erro       OUT VARCHAR2) IS                   --> Descrição do erro

    vr_cdcritic       crapcri.cdcritic%TYPE;
    vr_dscritic       VARCHAR2(10000);
    vr_cdconsul       NUMBER(7);
    vr_dttransa       DATE;
    vr_hrtransa       VARCHAR2(5);
    vr_cdagenci       crapage.cdagenci%TYPE;
    vr_err_cons       exception;
    vr_valida_agencia number(1);
    vr_err_agen       exception;
    vr_nvoperad       crapope.nvoperad%TYPE;
    vr_err_oper       exception;
    vr_err_perm       exception;
  BEGIN
    begin
      select c.cdconsul
           , c.cdagenci
        into vr_cdconsul
           , vr_cdagenci
        from crapass c
       where c.cdcooper = pr_cdcooper
         and c.nrdconta = pr_nrdconta;
    exception
      when no_data_found then
        raise vr_err_cons;
    end;
    
    if vr_cdconsul <> 0 then
      begin
        select c.nvoperad
          into vr_nvoperad
          from crapope c
         where c.cdcooper = pr_cdcooper
           and c.cdoperad = pr_cdoperad;
      exception
        when no_data_found then
          raise vr_err_oper;
      end;
      
      if nvl(vr_nvoperad,0) in (0,1) then
        raise vr_err_perm;
      end if;
    end if;

    if nvl(pr_cdconsultordst,0) <> 0 then
    begin
      select 1
        into vr_valida_agencia
        from tbcc_consultor_pa t
       where t.cdcooper    = pr_cdcooper
         and t.cdconsultor = pr_cdconsultordst
         and t.nrsequen    = 0
         and t.cdagenci    = vr_cdagenci;
    exception
      when no_data_found then
        raise vr_err_agen;
    end;
    end if;

    if nvl(vr_cdconsul,0) <> nvl(pr_cdconsultordst,0) then
      update crapass c
         set c.cdconsul = pr_cdconsultordst
       where c.cdcooper = pr_cdcooper
         and c.nrdconta = pr_nrdconta;

      vr_dttransa := trunc(sysdate);
      vr_hrtransa := to_char(sysdate,'SSSSS');

      insert into craplgm(cdcooper
                         ,nrdconta
                         ,idseqttl
                         ,nrsequen
                         ,dttransa
                         ,hrtransa
                         ,dstransa
                         ,dsorigem
                         ,nmdatela
                         ,flgtrans
                         ,dscritic
                         ,cdoperad
                         ,nmendter)
                         values
                         (pr_cdcooper
                         ,pr_nrdconta
                         ,1
                         ,1
                         ,vr_dttransa
                         ,vr_hrtransa
                         ,'Alteracao de consultor'
                         ,'AYLLOS'
                         ,'CADCON'
                         ,1
                         ,' '
                         ,pr_cdoperad
                         ,' ');

      insert into craplgi(cdcooper
                         ,nrdconta
                         ,idseqttl
                         ,nrsequen
                         ,dttransa
                         ,hrtransa
                         ,nrseqcmp
                         ,nmdcampo
                         ,dsdadant
                         ,dsdadatu)
                         values
                         (pr_cdcooper
                         ,pr_nrdconta
                         ,1
                         ,1
                         ,vr_dttransa
                         ,vr_hrtransa
                         ,1
                         ,'cdconsul'
                         ,vr_cdconsul
                         ,pr_cdconsultordst);
    end if;
  EXCEPTION
    WHEN vr_err_cons THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Consultor nao encontrado.';

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN vr_err_agen THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Consultor nao atende a agencia desse cooperado.';

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN vr_err_oper THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Operador nao encontrado.';

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN vr_err_perm THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Apos a associacao do consultor, somente supervisores podem efetuar alteracao.';

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_transfere_conta: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
  PROCEDURE pc_consulta_conta(pr_cdcooper    IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                             ,pr_nrdconta    IN crapass.nrdconta%TYPE           --> Codigo da Agencia
                             ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                             ,pr_cdcritic    OUT PLS_INTEGER                    --> Código da crítica
                             ,pr_dscritic    OUT VARCHAR2                       --> Descrição da crítica
                             ,pr_retxml      IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                             ,pr_nmdcampo    OUT VARCHAR2                       --> Nome do campo com erro
                             ,pr_des_erro    OUT VARCHAR2) IS                   --> Descrição do erro

    CURSOR cr_conta IS
      SELECT c.cdconsul
           , co.nmoperad
        FROM crapope        co
           , tbcc_consultor t
           , crapass        c
       WHERE co.cdcooper   (+) = t.cdcooper
         AND co.cdoperad   (+) = t.cdoperad
         AND t.cdcooper    (+) = c.cdcooper
         AND t.cdconsultor (+) = c.cdconsul
         AND t.nrsequen    (+) = 0
         AND c.cdcooper        = pr_cdcooper
         AND c.nrdconta        = pr_nrdconta;

    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_contador      NUMBER(5) := 0;
  BEGIN
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    for rw_conta in cr_conta loop
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'conta', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => pr_nrdconta, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'cdconsul', pr_tag_cont => rw_conta.cdconsul, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'nmoperad', pr_tag_cont => rw_conta.nmoperad, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
    end loop;

    if vr_contador = 0 then
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'conta', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => 0, pr_des_erro => vr_dscritic);
    end if;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_consulta_conta: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
  PROCEDURE pc_consulta_operadores(pr_cdoperador  IN crapope.cdoperad%TYPE --> Codigo do Operador
                                  ,pr_nmoperador  IN crapope.nmoperad%TYPE --> Nome do Operador
                                  ,pr_xmllog      IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic    OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic    OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml      IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo    OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro    OUT VARCHAR2) IS         --> Descrição do erro

    CURSOR cr_operadores(pr_cdcooper in number) IS
      SELECT c.cdoperad
           , c.nmoperad
           , COUNT(*) OVER (PARTITION BY c.cdcooper) qtdregis
        FROM crapope           c
       WHERE c.cdcooper = pr_cdcooper
         AND c.cdoperad = nvl(pr_cdoperador,c.cdoperad)
         AND upper(c.nmoperad) like upper(decode(pr_nmoperador,null,'%%','%'||pr_nmoperador||'%'))
         AND c.cdsitope = 1
       ORDER
          BY c.cdoperad;

    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_contador      NUMBER(5) := 0;
    
    --Variaveis de LOG
    vr_cdoperad      VARCHAR2(100);
    vr_cdcooper      NUMBER;
    vr_nmdatela      VARCHAR2(100);
    vr_nmeacao       VARCHAR2(100);
    vr_cdagenci      VARCHAR2(100);
    vr_nrdcaixa      VARCHAR2(100);
    vr_idorigem      VARCHAR2(100);
  BEGIN
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    for rw_operadores in cr_operadores(vr_cdcooper) loop
      if vr_contador = 0 then
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'OPERADOR', pr_tag_cont => null, pr_des_erro => vr_dscritic);
        gene0007.pc_gera_atributo(pr_xml => pr_retxml, pr_tag => 'OPERADOR', pr_atrib => 'qtregist', pr_atval => rw_operadores.qtdregis, pr_numva => 0, pr_des_erro => vr_dscritic);
      end if;

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'OPERADOR', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperador', pr_tag_cont => rw_operadores.cdoperad, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmoperador', pr_tag_cont => rw_operadores.nmoperad, pr_des_erro => vr_dscritic);

      vr_contador := vr_contador + 1;
    end loop;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_consulta_operadores: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
  PROCEDURE pc_consulta_agencias(pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo do Operador
                                ,pr_nmextage  IN crapage.nmextage%TYPE --> Nome do Operador
                                ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro  OUT VARCHAR2) IS         --> Descrição do erro

    CURSOR cr_agencias(pr_cdcooper in number) IS
      SELECT c.cdagenci
           , c.nmextage
           , COUNT(*) OVER (PARTITION BY c.cdcooper) qtdregis
        FROM crapage           c
       WHERE c.cdcooper = pr_cdcooper
         AND c.cdagenci = nvl(pr_cdagenci,c.cdagenci)
         AND c.insitage IN (1,3) -- 1-Ativo ou 3-Temporariamente Indisponivel
       ORDER
          BY c.cdagenci;

    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_contador      NUMBER(5) := 0;
    
    --Variaveis de LOG
    vr_cdoperad      VARCHAR2(100);
    vr_cdcooper      NUMBER;
    vr_nmdatela      VARCHAR2(100);
    vr_nmeacao       VARCHAR2(100);
    vr_cdagenci      VARCHAR2(100);
    vr_nrdcaixa      VARCHAR2(100);
    vr_idorigem      VARCHAR2(100);
  BEGIN
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    for rw_agencias in cr_agencias(vr_cdcooper) loop
      if vr_contador = 0 then
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'AGENCIA', pr_tag_cont => null, pr_des_erro => vr_dscritic);
        gene0007.pc_gera_atributo(pr_xml => pr_retxml, pr_tag => 'AGENCIA', pr_atrib => 'qtregist', pr_atval => rw_agencias.qtdregis, pr_numva => 0, pr_des_erro => vr_dscritic);
      end if;

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'AGENCIA', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_agencias.cdagenci, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmextage', pr_tag_cont => rw_agencias.nmextage, pr_des_erro => vr_dscritic);

      vr_contador := vr_contador + 1;
    end loop;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_consulta_agencias: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
  PROCEDURE pc_consulta_consultores_org(pr_cdconsultororg IN tbcc_consultor.cdconsultor%TYPE --> Codigo do Consultor
                                       ,pr_cdoperadororg  IN crapope.cdoperad%TYPE           --> Codigo do Operador
                                       ,pr_nmoperadororg  IN crapope.nmoperad%TYPE           --> Nome do Operador
                                       ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                                       ,pr_cdcritic    OUT PLS_INTEGER                    --> Código da crítica
                                       ,pr_dscritic    OUT VARCHAR2                       --> Descrição da crítica
                                       ,pr_retxml      IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                                       ,pr_nmdcampo    OUT VARCHAR2                       --> Nome do campo com erro
                                       ,pr_des_erro    OUT VARCHAR2) IS                   --> Descrição do erro

    CURSOR cr_consultores(pr_cdcooper in number) IS
      SELECT c.cdconsultor
           , c.cdoperad
           , o.nmoperad
           , COUNT(*) OVER (PARTITION BY c.cdcooper) qtdregis
        FROM crapope        o
           , tbcc_consultor c
       WHERE o.cdcooper (+) = c.cdcooper
         AND o.cdoperad (+) = c.cdoperad 
         AND c.cdcooper = pr_cdcooper
         AND c.cdconsultor = nvl(pr_cdconsultororg,c.cdconsultor)
         AND c.cdoperad = nvl(pr_cdoperadororg,c.cdoperad)
         AND upper(o.nmoperad) like upper(decode(pr_nmoperadororg,null,'%%','%'||pr_nmoperadororg||'%'))
         AND c.nrsequen = 0
       ORDER
          BY c.cdoperad;

    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_contador      NUMBER(5) := 0;
    
    --Variaveis de LOG
    vr_cdoperad      VARCHAR2(100);
    vr_cdcooper      NUMBER;
    vr_nmdatela      VARCHAR2(100);
    vr_nmeacao       VARCHAR2(100);
    vr_cdagenci      VARCHAR2(100);
    vr_nrdcaixa      VARCHAR2(100);
    vr_idorigem      VARCHAR2(100);
  BEGIN
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    for rw_consultores in cr_consultores(vr_cdcooper) loop
      if vr_contador = 0 then
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'CONSULTOR', pr_tag_cont => null, pr_des_erro => vr_dscritic);
        gene0007.pc_gera_atributo(pr_xml => pr_retxml, pr_tag => 'CONSULTOR', pr_atrib => 'qtregist', pr_atval => rw_consultores.qtdregis, pr_numva => 0, pr_des_erro => vr_dscritic);
      end if;

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'CONSULTOR', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdconsultororg', pr_tag_cont => rw_consultores.cdconsultor, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperadororg', pr_tag_cont => rw_consultores.cdoperad, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmoperadororg', pr_tag_cont => rw_consultores.nmoperad, pr_des_erro => vr_dscritic);

      vr_contador := vr_contador + 1;
    end loop;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_consulta_consultores_org: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
  PROCEDURE pc_consulta_consultores_dst(pr_cdconsultordst IN tbcc_consultor.cdconsultor%TYPE --> Codigo do Consultor
                                       ,pr_cdoperadordst  IN crapope.cdoperad%TYPE           --> Codigo do Operador
                                       ,pr_nmoperadordst  IN crapope.nmoperad%TYPE           --> Nome do Operador
                                       ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                                       ,pr_cdcritic    OUT PLS_INTEGER                    --> Código da crítica
                                       ,pr_dscritic    OUT VARCHAR2                       --> Descrição da crítica
                                       ,pr_retxml      IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                                       ,pr_nmdcampo    OUT VARCHAR2                       --> Nome do campo com erro
                                       ,pr_des_erro    OUT VARCHAR2) IS                   --> Descrição do erro

    CURSOR cr_consultores(pr_cdcooper in number) IS
      SELECT c.cdconsultor
           , c.cdoperad
           , o.nmoperad
           , COUNT(*) OVER (PARTITION BY c.cdcooper) qtdregis
        FROM crapope        o
           , tbcc_consultor c
       WHERE o.cdcooper (+) = c.cdcooper
         AND o.cdoperad (+) = c.cdoperad 
         AND c.cdcooper = pr_cdcooper
         AND c.cdconsultor = nvl(pr_cdconsultordst,c.cdconsultor)
         AND c.cdoperad = nvl(pr_cdoperadordst,c.cdoperad)
         AND upper(o.nmoperad) like upper(decode(pr_nmoperadordst,null,'%%','%'||pr_nmoperadordst||'%'))
         AND c.nrsequen = 0
       ORDER
          BY c.cdoperad;

    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_contador      NUMBER(5) := 0;
    
    --Variaveis de LOG
    vr_cdoperad      VARCHAR2(100);
    vr_cdcooper      NUMBER;
    vr_nmdatela      VARCHAR2(100);
    vr_nmeacao       VARCHAR2(100);
    vr_cdagenci      VARCHAR2(100);
    vr_nrdcaixa      VARCHAR2(100);
    vr_idorigem      VARCHAR2(100);
  BEGIN
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    for rw_consultores in cr_consultores(vr_cdcooper) loop
      if vr_contador = 0 then
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'CONSULTOR', pr_tag_cont => null, pr_des_erro => vr_dscritic);
        gene0007.pc_gera_atributo(pr_xml => pr_retxml, pr_tag => 'CONSULTOR', pr_atrib => 'qtregist', pr_atval => rw_consultores.qtdregis, pr_numva => 0, pr_des_erro => vr_dscritic);
      end if;

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'CONSULTOR', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdconsultordst', pr_tag_cont => rw_consultores.cdconsultor, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperadordst', pr_tag_cont => rw_consultores.cdoperad, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmoperadordst', pr_tag_cont => rw_consultores.nmoperad, pr_des_erro => vr_dscritic);

      vr_contador := vr_contador + 1;
    end loop;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_consulta_consultores_dst: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;

  PROCEDURE pc_ativa_inativa_consultor(pr_cdcooper IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                                      ,pr_cdconsul IN tbcc_consultor.cdconsultor%TYPE --> Código do Consultor
                                      ,pr_xmllog   IN VARCHAR2                        --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER                    --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2                       --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2                       --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS                   --> Descrição do erro
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_nrsequen      tbcc_consultor.nrsequen%TYPE;
    
    --Variaveis de LOG
    vr_cdoperad      VARCHAR2(100);
    vr_cdcooper      NUMBER;
    vr_nmdatela      VARCHAR2(100);
    vr_nmeacao       VARCHAR2(100);
    vr_cdagenci      VARCHAR2(100);
    vr_nrdcaixa      VARCHAR2(100);
    vr_idorigem      VARCHAR2(100);
  BEGIN
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    begin
      select t.nrsequen
        into vr_nrsequen
        from tbcc_consultor t
       where t.cdcooper    = pr_cdcooper
         and t.cdconsultor = pr_cdconsul
         and t.nrsequen    = 0;
    exception
      when no_data_found then
        vr_nrsequen := -1;
    end;
    
    if vr_nrsequen = 0 then --Inativar
      pc_inativa_consultor(pr_cdcooper => pr_cdcooper
                          ,pr_cdconsul => pr_cdconsul
                          ,pr_xmllog   => pr_xmllog
                          ,pr_cdcritic => pr_cdcritic
                          ,pr_dscritic => pr_dscritic
                          ,pr_retxml   => pr_retxml
                          ,pr_nmdcampo => pr_nmdcampo
                          ,pr_des_erro => pr_des_erro);
    else --Ativar
      select nvl(max(t.nrsequen),-1)
        into vr_nrsequen
        from tbcc_consultor t
       where t.cdcooper    = pr_cdcooper
         and t.cdconsultor = pr_cdconsul;
      
      insert into tbcc_consultor
      (select x.cdcooper
            , x.cdconsultor
            , 0 --nrsequen 
            , trunc(sysdate)
            , vr_cdoperad
         from tbcc_consultor x
        where x.cdcooper = pr_cdcooper
          and x.cdconsultor = pr_cdconsul
          and x.nrsequen = vr_nrsequen);
      
      insert into tbcc_consultor_pa
      (select x.cdcooper
            , x.cdconsultor
            , 0 --nrsequen 
            , x.cdagenci
         from tbcc_consultor_pa x
        where x.cdcooper = pr_cdcooper
          and x.cdconsultor = pr_cdconsul
          and x.nrsequen = vr_nrsequen);
    end if;
  EXCEPTION
    
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_ativa_inativa_consultor: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
  PROCEDURE pc_consulta_consultores(pr_cdconsultor IN tbcc_consultor.cdconsultor%TYPE --> Codigo do Consultor
                                   ,pr_cdoperador  IN crapope.cdoperad%TYPE           --> Codigo do Operador
                                   ,pr_nmoperador  IN crapope.nmoperad%TYPE           --> Nome do Operador
                                   ,pr_xmllog      IN VARCHAR2                        --> XML com informações de LOG
                                   ,pr_cdcritic    OUT PLS_INTEGER                    --> Código da crítica
                                   ,pr_dscritic    OUT VARCHAR2                       --> Descrição da crítica
                                   ,pr_retxml      IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                                   ,pr_nmdcampo    OUT VARCHAR2                       --> Nome do campo com erro
                                   ,pr_des_erro    OUT VARCHAR2) IS                   --> Descrição do erro

    CURSOR cr_consultores(pr_cdcooper in number) IS
      SELECT c.cdconsultor
           , c.cdoperad
           , o.nmoperad
           , COUNT(*) OVER (PARTITION BY c.cdcooper) qtdregis
        FROM crapope        o
           , tbcc_consultor c
       WHERE o.cdcooper (+) = c.cdcooper
         AND o.cdoperad (+) = c.cdoperad 
         AND c.cdcooper = pr_cdcooper
         AND c.cdconsultor = nvl(pr_cdconsultor,c.cdconsultor)
         AND c.cdoperad = nvl(pr_cdoperador,c.cdoperad)
         AND upper(o.nmoperad) like upper(decode(pr_nmoperador,null,'%%','%'||pr_nmoperador||'%'))
         AND c.nrsequen = 0
       ORDER
          BY c.cdoperad;

    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
    vr_contador      NUMBER(5) := 0;
    
    --Variaveis de LOG
    vr_cdoperad      VARCHAR2(100);
    vr_cdcooper      NUMBER;
    vr_nmdatela      VARCHAR2(100);
    vr_nmeacao       VARCHAR2(100);
    vr_cdagenci      VARCHAR2(100);
    vr_nrdcaixa      VARCHAR2(100);
    vr_idorigem      VARCHAR2(100);
  BEGIN
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    for rw_consultores in cr_consultores(vr_cdcooper) loop
      if vr_contador = 0 then
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'CONSULTOR', pr_tag_cont => null, pr_des_erro => vr_dscritic);
        gene0007.pc_gera_atributo(pr_xml => pr_retxml, pr_tag => 'CONSULTOR', pr_atrib => 'qtregist', pr_atval => rw_consultores.qtdregis, pr_numva => 0, pr_des_erro => vr_dscritic);
      end if;

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'CONSULTOR', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => null, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdconsultor', pr_tag_cont => rw_consultores.cdconsultor, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperador', pr_tag_cont => rw_consultores.cdoperad, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmconsultor', pr_tag_cont => rw_consultores.nmoperad, pr_des_erro => vr_dscritic);

      vr_contador := vr_contador + 1;
    end loop;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_consulta_consultores: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;
  
  -- Rotina para gerar impressao de declaracao de pessoa exposta politicamente
  PROCEDURE pc_imp_dec_pep(pr_tpexposto        IN pls_integer
                          ,pr_cdocpttl         IN pls_integer
                          ,pr_cdrelacionamento IN pls_integer
                          ,pr_dtinicio         IN VARCHAR2
                          ,pr_dttermino        IN VARCHAR2
                          ,pr_nmempresa        IN VARCHAR2
                          ,pr_nrcnpj_empresa   IN VARCHAR2
                          ,pr_nmpolitico       IN VARCHAR2
                          ,pr_nrcpf_politico   IN VARCHAR2
                          ,pr_nmextttl         IN VARCHAR2
                          ,pr_rsocupa          IN VARCHAR2
                          ,pr_nrcpfcgc         IN VARCHAR2
                          ,pr_dsrelacionamento IN VARCHAR2
                          ,pr_nrdconta         IN VARCHAR2
                          ,pr_cidade           IN VARCHAR2

                          ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                          ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                          ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                          ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                          ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_imp_dec_pep
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Carlos Henrique
    Data    : Dezembro/15.                    Ultima atualizacao: 21/02/2017
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para gerar impressao de declaração de pessoa exposta politicamente.
    Observacao: -----
    
    Alteracoes: 21/02/2017 - Ajuste para tratar os valores a serem enviados para
                             geração do relatório
                             (Adriano - SD 614408).
    ..............................................................................*/
    DECLARE
    
      vr_xml       CLOB; --> CLOB com conteudo do XML do relatório
      vr_xmlbuffer VARCHAR2(32767); --> Auxiliar para envio do texto ao XML
      vr_strbuffer VARCHAR2(32767); --> Auxiliar para envio do texto ao XML
    
      -- Variaveis extraidas do xml pr_retxml
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
    
      -- Variaveis para a geracao do relatorio
      vr_nom_direto VARCHAR2(500);
      vr_nmarqimp   VARCHAR2(100);
      vr_nrcnpj_empresa VARCHAR2(25);
      
      -- contador de controle
      vr_auxqtd NUMBER;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    
      -- Variável de críticas
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(10000);
      vr_des_reto  VARCHAR2(10);
      vr_typ_saida VARCHAR2(3);
      vr_tab_erro  gene0001.typ_tab_erro;
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
    BEGIN
    
      vr_auxqtd := 0;
      -- extrair informações do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
    
    
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
    
      -- Inicializar XML do relatório
      dbms_lob.createtemporary(vr_xml, TRUE);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);
    
      IF to_number(pr_nrcnpj_empresa) = 0 OR pr_nrcnpj_empresa IS NULL THEN
        
        vr_nrcnpj_empresa := NULL;
                                
      ELSE
        
        vr_nrcnpj_empresa := gene0002.fn_mask_cpf_cnpj(pr_nrcnpj_empresa,2);
                                 
      END IF;
    
      vr_strbuffer := '<?xml version="1.0" encoding="utf-8"?><declaracao>';
      vr_strbuffer := vr_strbuffer || 
      '<tpexposto>'        || to_char(pr_tpexposto)                           || '</tpexposto>' || 
      '<cdocpttl>'         || to_char(pr_cdocpttl)                            || '</cdocpttl>'  || 
      '<cdrelacionamento>' || to_char(pr_cdrelacionamento)                    || '</cdrelacionamento>' ||
      '<dtinicio>'         || pr_dtinicio                                     || '</dtinicio>'  ||
      '<dttermino>'        || pr_dttermino                                    || '</dttermino>' || 
      '<nmempresa>'        || NVL(TRIM(pr_nmempresa), ' ')                    || '</nmempresa>' || 
      '<nrcnpj_empresa>'   || vr_nrcnpj_empresa                               || '</nrcnpj_empresa>' ||
      '<nmpolitico>'       || NVL(TRIM(pr_nmpolitico), ' ')                   || '</nmpolitico>' ||
      '<nrcpf_politico>'   || gene0002.fn_mask_cpf_cnpj(pr_nrcpf_politico,1)  || '</nrcpf_politico>' || 
      '<nmextttl>'         || NVL(TRIM(pr_nmextttl), ' ')                     || '</nmextttl>' || 
      '<rsocupa>'          || pr_rsocupa                                      || '</rsocupa>' || 
      '<nrcpfcgc>'         || gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc,1)        || '</nrcpfcgc>' || 
      '<dsrelacionamento>' || pr_dsrelacionamento                             || '</dsrelacionamento>' ||
      '<nrdconta>'         || pr_nrdconta                                     || '</nrdconta>' ||
      '<cidade>'           || pr_cidade                                       || '</cidade>' ||
      '</declaracao>';

      -- Enviar ao CLOB
      gene0002.pc_escreve_xml(pr_xml            => vr_xml
                             ,pr_texto_completo => vr_xmlbuffer
                             ,pr_texto_novo     => vr_strbuffer
                             ,pr_fecha_xml      => TRUE); --> Ultima chamada
    
      -- Somente se o CLOB contiver informações
      IF dbms_lob.getlength(vr_xml) > 0 THEN
      
        -- Busca do diretório base da cooperativa para PDF
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                              ,pr_cdcooper => vr_cdcooper
                                              ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
      
        -- Definir nome do relatorio
        vr_nmarqimp := 'declaracao_pep_' || 
                       to_char(sys_extract_utc(systimestamp), 'SSSSSFF3') || 
                       '.pdf';
      
        -- Solicitar geração do relatorio
        gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper --> Cooperativa conectada
                                   ,pr_cdprogra  => 'CONTAS' --> Programa chamador
                                   ,pr_dtmvtolt  => SYSDATE --> Data do movimento atual
                                   ,pr_dsxml     => vr_xml --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/declaracao' --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'declaracao_pep.jasper' --> Arquivo de layout do iReport
                                   ,pr_dsparams  => null --> Sem parâmetros
                                   ,pr_dsarqsaid => vr_nom_direto || '/' ||
                                                    vr_nmarqimp --> Arquivo final com o path
                                   ,pr_cdrelato  => 711 --> chw qual será o cdrelato?
                                   ,pr_qtcoluna  => 80 --> 80 colunas
                                   ,pr_flg_gerar => 'S' --> Geraçao na hora
                                   ,pr_flg_impri => 'N' --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => '' --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1 --> Número de cópias
                                   ,pr_sqcabrel  => 1 --> Qual a seq do cabrel
                                   ,pr_des_erro  => vr_dscritic); --> Saída com erro
        -- Tratar erro
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          raise vr_exc_saida;
        END IF;
      
        -- Enviar relatorio para intranet
        gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper --> Cooperativa conectada
                                    ,pr_cdagenci => vr_cdagenci --> Codigo da agencia para erros
                                    ,pr_nrdcaixa => vr_nrdcaixa --> Codigo do caixa para erros
                                    ,pr_nmarqpdf => vr_nom_direto || '/' ||
                                                    vr_nmarqimp --> Arquivo PDF  a ser gerado
                                    ,pr_des_reto => vr_des_reto --> Saída com erro
                                    ,pr_tab_erro => vr_tab_erro); --> tabela de erros
      
        -- caso apresente erro na operação
        IF nvl(vr_des_reto, 'OK') <> 'OK' THEN
          IF vr_tab_erro.COUNT > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          
            RAISE vr_exc_saida;
          END IF;
        END IF;
      
        -- Remover relatorio da pasta rl apos gerar
        gene0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'rm ' || vr_nom_direto || '/' ||
                                                vr_nmarqimp
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic); 
        -- Se retornou erro
        IF vr_typ_saida = 'ERR'
           OR vr_dscritic IS NOT null THEN
          -- Concatena o erro que veio
          vr_dscritic := 'Erro ao remover arquivo: ' || vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
      
      END IF;
    
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml);
      dbms_lob.freetemporary(vr_xml);
    
      -- Criar XML de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||
                                     vr_nmarqimp || '</nmarqpdf>');
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                       pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral ao imprimir declaracao de PEP: ' || SQLERRM;
      
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                       pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  
  END pc_imp_dec_pep;
  
  PROCEDURE pc_email_troca_pa(pr_cdcooper IN crapcop.cdcooper%TYPE           --> Codigo da cooperativa
                             ,pr_nrdconta IN crapass.nrdconta%TYPE           --> Numero da conta
                             ,pr_cdageant IN crapass.cdagenci%TYPE           --> Codigo da agencia anterior
                             ,pr_cdagenci IN crapass.cdagenci%TYPE           --> Codigo da agencia nova
                             ,pr_xmllog   IN VARCHAR2                        --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER                    --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2                       --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType              --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                       --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS                   --> Descrição do erro
    CURSOR c_email IS
      select c.dsdemail
        from crapage c
       where c.cdcooper = pr_cdcooper
         and c.cdagenci in (pr_cdageant, pr_cdagenci);
    
    vr_dstexto     VARCHAR2(500);    --> Texto que sera enviado no email
    vr_emaildst    VARCHAR2(200);    --> Endereco do e-mail de destino
    vr_dscritic    VARCHAR2(10000);
    vr_exc_saida   EXCEPTION;
    vr_cdcritic    crapcri.cdcritic%TYPE;
  BEGIN
    for r_email in c_email loop
      if vr_emaildst is null then
        vr_emaildst := r_email.dsdemail;
      else
        vr_emaildst := vr_emaildst||';'||r_email.dsdemail;
      end if;
    end loop;
    
    vr_dstexto := 'Informamos que a conta <b>'||gene0002.fn_mask_conta(pr_nrdconta)||'</b> que pertencia ao PA <b>'
                ||pr_cdageant||'</b> foi transferida para o PA <b>'||pr_cdagenci||'</b>.';
                
    gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                              ,pr_cdprogra        => 'CADA0003'
                              ,pr_des_destino     => vr_emaildst
                              ,pr_des_assunto     => 'Transferencia de Cooperados entre PAs'
                              ,pr_des_corpo       => vr_dstexto
                              ,pr_des_anexo       => NULL
                              ,pr_des_erro        => vr_dscritic);
    -- Caso encontre alguma critica no envio do email
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_email_troca_pa: ' || SQLERRM;
      pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_email_troca_pa;
  
  -- Retorna se cheque tem devolucao automatica ou nao
  PROCEDURE pc_verifica_sit_dev(pr_cdcooper IN  crapcop.cdcooper%TYPE,   --> Cooperativa
                                 pr_nrdconta IN  crapass.nrdconta%TYPE,   --> Conta/Dv
                                 pr_flgdevolu_autom OUT PLS_INTEGER) IS   --> Devolucao automatica ou nao
    /* .............................................................................
    Programa: pc_verifica_sit_dev
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Ranghetti
    Data    : 11/07/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar se devolve automatico ou nao

    Alteracoes: 

    ............................................................................. */    
    
  BEGIN
  
    OPEN cr_tbchq_param_conta(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta);
    FETCH cr_tbchq_param_conta INTO rw_tbchq_param_conta;        
        
    IF cr_tbchq_param_conta%FOUND THEN
      CLOSE cr_tbchq_param_conta;  
      -- Se char registro, retorna se devolucao esta automatica ou nao
      pr_flgdevolu_autom := rw_tbchq_param_conta.flgdevolu_autom;
    ELSE 
      CLOSE cr_tbchq_param_conta;  
      -- Se nao tiver registro cadastrado, retorna 0 - Nao
      pr_flgdevolu_autom := 0;
    END IF;
  
  END pc_verifica_sit_dev;
      
  -- Retorna se cheque tem devolucao automatica ou nao, por XML  
  PROCEDURE pc_verifica_sit_dev_xml(pr_cdcooper IN  crapcop.cdcooper%TYPE,   --> Cooperativa
                                     pr_nrdconta IN  crapass.nrdconta%TYPE,   --> Conta/Dv
                                     pr_xmllog   IN VARCHAR2,                 --> XML com informações de LOG
                                     pr_cdcritic OUT PLS_INTEGER,             --> Código da crítica
                                     pr_dscritic OUT VARCHAR2,                --> Descrição da crítica
                                     pr_retxml   IN OUT NOCOPY XMLType,       --> Arquivo de retorno do XML
                                     pr_nmdcampo OUT VARCHAR2,                --> Nome do campo com erro
                                     pr_des_erro OUT VARCHAR2) IS             --> Erros do processo
    /* .............................................................................
    Programa: pc_verifica_sit_dev_xml
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Ranghetti
    Data    : 11/07/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar se devolve automatico ou nao, e retornar em xml

    Alteracoes: 

    ............................................................................. */
    
    vr_flgdevolu_autom INTEGER;
  BEGIN
     
    cada0003.pc_verifica_sit_dev(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_flgdevolu_autom => vr_flgdevolu_autom);
                        
    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
    -- Criar nodo filho
    pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                        ,'/Root'
                                        ,XMLTYPE('<devolucao>'
                                               ||'  <flgdevolu_autom>'||vr_flgdevolu_autom||'</flgdevolu_autom>'
                                               ||'</devolucao>'));    
  EXCEPTION                                    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral (CADA003.pc_verifica_situacao_xml): ' || SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;                                             
    
  END pc_verifica_sit_dev_xml;
  
  PROCEDURE pc_grava_tbchq_param_conta(pr_cddopcao IN VARCHAR2,               --> Opcao I/A
                                       pr_cdcooper IN  crapcop.cdcooper%TYPE, --> Cooperativa
                                       pr_nrdconta IN  crapass.nrdconta%TYPE, --> Conta/Dv                                       
                                       pr_flgdevolu_autom IN NUMBER,          --> Devolve automatico ou nao
                                       pr_cdoperad IN VARCHAR2,               --> Operador
                                       pr_cdopecor IN VARCHAR2,               --> Operador Coordenador
                                       pr_dscritic OUT VARCHAR2) IS           --> Critica
      /* .............................................................................
    Programa: pc_grava_tbchq_param_conta
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Ranghetti
    Data    : 11/07/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gravar dados na tabela tbchq_param_conta

    Alteracoes: 29/11/2016 - Retirado COMMIT pois estava ocasionando problemas na
                             abertura de contas na MATRIC criando registros com PA
                             zerado (Tiago/Thiago).
    ............................................................................. */
    vr_exc_saida  EXCEPTION;
    vr_dsflgdevolu_antes VARCHAR2(3);
    vr_dsflgdevolu_depois VARCHAR2(3);
    
    CURSOR cr_crapope IS
    SELECT  ope.nmoperad 
      FROM crapope ope
     WHERE ope.cdcooper = pr_cdcooper
       AND upper(ope.cdoperad) = upper(pr_cdoperad);
     rw_crapope cr_crapope%ROWTYPE;
        
    BEGIN      
      
      OPEN cr_crapope;
      FETCH cr_crapope INTO rw_crapope;
      
      IF cr_crapope%ISOPEN THEN
        CLOSE cr_crapope;
      END IF;

      -- verificar se existe registro
      OPEN cr_tbchq_param_conta(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta);
      FETCH cr_tbchq_param_conta INTO rw_tbchq_param_conta;        
          
      IF cr_tbchq_param_conta%NOTFOUND THEN      
        CLOSE cr_tbchq_param_conta;  
        -- Caso for opcao "I", iremos inserir registro com o flgdevolu_autom como true(default)
        IF pr_cddopcao = 'I' THEN
          BEGIN
            INSERT INTO tbchq_param_conta
                        (cdcooper
                        ,nrdconta
                        ,flgdevolu_autom)
                        VALUES
                        (pr_cdcooper
                        ,pr_nrdconta
                        ,pr_flgdevolu_autom); -- defatult e 1-sim
          EXCEPTION
            WHEN OTHERS THEN          
              pr_dscritic := 'Erro ao inserir registro na tbchq_param_conta: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;      
          
        END IF;
      ELSE
        CLOSE cr_tbchq_param_conta;
        -- Se for opcao "A", ira atualizar conforme parametro pr_flgdevolu_autom(1/0)
        IF pr_cddopcao = 'A' THEN
                                                    
          -- So atualiza se for diferente do anterior
          IF rw_tbchq_param_conta.flgdevolu_autom <> pr_flgdevolu_autom THEN          
            BEGIN
              UPDATE tbchq_param_conta tbchq
                 SET tbchq.flgdevolu_autom = pr_flgdevolu_autom
               WHERE tbchq.cdcooper = pr_cdcooper
                 AND tbchq.nrdconta = pr_nrdconta;
            EXCEPTION 
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao atualizar registro na tbchq_param_conta: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
            
            IF pr_flgdevolu_autom = 1 THEN
              vr_dsflgdevolu_depois := 'SIM';
              vr_dsflgdevolu_antes  := 'NAO';
            ELSE
              vr_dsflgdevolu_depois := 'NAO';
              vr_dsflgdevolu_antes  := 'SIM';
            END IF;
            
            --Escrever No LOG
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => 'contas.log'
                                      ,pr_des_log      => to_char(SYSDATE,'DD/MM/YYYY hh24:mi:ss') ||
                                                          ' -->  Operador ' || pr_cdoperad || ' - ' || rw_crapope.nmoperad  ||
                                                          ' atraves do Coordenador ' || pr_cdopecor || ' alterou na conta ' ||
                                                          pr_nrdconta || ' o campo Dev. Aut. Cheques de ' || 
                                                          vr_dsflgdevolu_antes || ' para ' || vr_dsflgdevolu_depois || '.');
          END IF;
        END IF;
      END IF;  

    EXCEPTION
      WHEN vr_exc_saida THEN        
        NULL;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em CADA0003.pc_grava_tbchq_param_conta: ' || SQLERRM;
        
    END pc_grava_tbchq_param_conta;
    
    -- Gravar registros na tabela tbchq_param_conta, por xml
    PROCEDURE pc_grava_tbchq_param_conta_xml(pr_cddopcao IN VARCHAR2,               --> Opcao I/A
                                             pr_cdcooper IN  crapcop.cdcooper%TYPE, --> Cooperativa
                                             pr_nrdconta IN  crapass.nrdconta%TYPE, --> Conta/Dv
                                             pr_flgdevolu_autom IN NUMBER,          --> Devolve automatico ou nao
                                             pr_cdoperad IN VARCHAR2,               --> Operador
                                             pr_cdopecor IN VARCHAR2,               --> Operador Coordenador
                                             pr_xmllog   IN VARCHAR2,               --> XML com informações de LOG
                                             pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                             pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                             pr_retxml   IN OUT NOCOPY XMLType,     --> Arquivo de retorno do XML
                                             pr_nmdcampo OUT VARCHAR2,              --> Nome do campo com erro
                                             pr_des_erro OUT VARCHAR2) IS           --> Erros do processo 
          
      /* .............................................................................
      Programa: pc_grava_tbchq_param_conta_xml
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Lucas Ranghetti
      Data    : 15/07/2016                        Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para chamar a rotina de gravação/alteração do parametro de
                  devolução automatica.

      Alteracoes: 

      ............................................................................. */
      vr_dscritic VARCHAR2(100);
      vr_exc_saida  EXCEPTION;
    BEGIN
    
      pc_grava_tbchq_param_conta(pr_cddopcao => pr_cddopcao, 
                                 pr_cdcooper => pr_cdcooper, 
                                 pr_nrdconta => pr_nrdconta, 
                                 pr_flgdevolu_autom => pr_flgdevolu_autom, 
                                 pr_cdoperad => pr_cdoperad, 
                                 pr_cdopecor => pr_cdopecor, 
                                 pr_dscritic => vr_dscritic);
                        
      IF vr_dscritic IS NOT NULL THEN
        pr_dscritic := vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
      
    EXCEPTION                                    
      WHEN vr_exc_saida THEN
        pr_cdcritic := 0;
        IF pr_dscritic IS NULL THEN
          pr_dscritic := 'Erro geral (CADA003.pc_grava_tbchq_param_conta_xml): ' || SQLERRM;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;           
   END pc_grava_tbchq_param_conta_xml;
   

  PROCEDURE pc_busca_cidades(pr_idcidade     IN crapmun.idcidade%TYPE --> Identificador unico do cadstro de cidade
                            ,pr_cdcidade     IN crapmun.cdcidbge%TYPE --> Codigo da cidade CETIP/IBGE/CORREIOS/SFN
                            ,pr_dscidade     IN crapmun.dscidade%TYPE --> Nome da cidade
                            ,pr_cdestado     IN crapmun.cdestado%TYPE --> Codigo da UF
                            ,pr_infiltro     IN PLS_INTEGER --> 1-CETIP / 2-IBGE / 3-CORREIOS
                            ,pr_intipnom     IN PLS_INTEGER --> 1-SEM ACENTUACAO / 2-COM ACENTUACAO
                            ,pr_tab_crapmun OUT typ_tab_crapmun --> PLTABLE com os dados
                            ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic    OUT VARCHAR2) IS --> Descricao da critica
  BEGIN

    /* .............................................................................

    Programa: pc_busca_cidades
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Agosto/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar as cidades.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_crapmun(pr_idcidade IN crapmun.idcidade%TYPE
                       ,pr_cdcidade IN crapmun.cdcidbge%TYPE
                       ,pr_dscidade IN crapmun.dscidade%TYPE
                       ,pr_cdestado IN crapmun.cdestado%TYPE
                       ,pr_infiltro IN PLS_INTEGER
                       ,pr_intipnom IN PLS_INTEGER) IS
        SELECT crapmun.idcidade
              ,crapmun.cdestado
              ,CASE pr_infiltro
                 WHEN 1 THEN crapmun.cdcidade -- CETIP
                 WHEN 2 THEN crapmun.cdcidbge -- IBGE
                 WHEN 3 THEN crapmun.cdcidcor -- CORREIOS
               END cdcidade
              ,CASE pr_intipnom
                 WHEN 1 THEN crapmun.dscidade -- SEM ACENTUACAO
                 WHEN 2 THEN crapmun.dscidesp -- COM ACENTUACAO
               END dscidade

          FROM crapmun

         WHERE crapmun.idcidade = DECODE(NVL(pr_idcidade,0), 0, crapmun.idcidade, pr_idcidade)
           
           AND (TRIM(pr_dscidade) IS NULL
                OR (UPPER(crapmun.dscidade) LIKE '%'||UPPER(pr_dscidade)||'%' AND 1 = pr_intipnom)  -- SEM ACENTUACAO
                OR (UPPER(crapmun.dscidesp) LIKE '%'||UPPER(pr_dscidade)||'%' AND 2 = pr_intipnom)) -- COM ACENTUACAO
           
           AND UPPER(crapmun.cdestado) = DECODE(TRIM(pr_cdestado), NULL, crapmun.cdestado, UPPER(pr_cdestado))
           
           AND ((crapmun.cdcidade IS NOT NULL AND 1 = pr_infiltro AND -- CETIP
                 crapmun.cdcidade = DECODE(NVL(pr_cdcidade,0), 0, crapmun.cdcidade, pr_cdcidade)) OR

                (crapmun.cdcidbge IS NOT NULL AND 2 = pr_infiltro AND -- IBGE
                 crapmun.cdcidbge = DECODE(NVL(pr_cdcidade,0), 0, crapmun.cdcidbge, pr_cdcidade)) OR

                (crapmun.cdcidcor IS NOT NULL AND 3 = pr_infiltro AND -- CORREIOS
                 crapmun.cdcidcor = DECODE(NVL(pr_cdcidade,0), 0, crapmun.cdcidcor, pr_cdcidade)))

      ORDER BY crapmun.dscidade;

      -- Variaveis Gerais
      vr_indice NUMBER := 0;

    BEGIN
      -- Limpa PLTABLE
      pr_tab_crapmun.DELETE;

      -- Percorrer todas as cidades
      FOR rw_crapmun IN cr_crapmun(pr_idcidade => pr_idcidade
                                  ,pr_cdcidade => pr_cdcidade
                                  ,pr_dscidade => pr_dscidade
                                  ,pr_cdestado => pr_cdestado
                                  ,pr_infiltro => pr_infiltro
                                  ,pr_intipnom => pr_intipnom) LOOP
        -- Incrementa o indice
        vr_indice := vr_indice + 1;

        -- Carrega os dados na PLTRABLE
        pr_tab_crapmun(vr_indice).idcidade := rw_crapmun.idcidade;
        pr_tab_crapmun(vr_indice).cdestado := rw_crapmun.cdestado;
        pr_tab_crapmun(vr_indice).cdcidade := rw_crapmun.cdcidade;
        pr_tab_crapmun(vr_indice).dscidade := rw_crapmun.dscidade;

      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina da tela CADA0003.pc_busca_cidades: ' || SQLERRM;
    END;

  END pc_busca_cidades;

  PROCEDURE pc_lista_cidades(pr_idcidade IN crapmun.idcidade%TYPE --> Identificador unico do cadstro de cidade
                            ,pr_cdcidade IN crapmun.cdcidbge%TYPE --> Codigo da cidade CETIP/IBGE/CORREIOS/SFN
                            ,pr_dscidade IN crapmun.dscidade%TYPE --> Nome da cidade
                            ,pr_cdestado IN crapmun.cdestado%TYPE --> Codigo da UF
                            ,pr_infiltro IN PLS_INTEGER           --> 1-CETIP / 2-IBGE / 3-CORREIOS / 4-SFN
                            ,pr_intipnom IN PLS_INTEGER           --> 1-SEM ACENTUACAO / 2-COM ACENTUACAO
                            ,pr_nriniseq IN PLS_INTEGER           --> Numero inicial do registro para enviar
                            ,pr_nrregist IN PLS_INTEGER           --> Numero de registros que deverao ser retornados
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

    -- Variável de críticas
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida     EXCEPTION;

    -- Variaveis gerais
    vr_contador PLS_INTEGER := 0;
    vr_posreg   PLS_INTEGER := 0;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB;

    -- Vetor para armazenar os dados da tabela
    vr_tab_crapmun typ_tab_crapmun;

  BEGIN

    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

    -- Busca as cidades
    CADA0003.pc_busca_cidades(pr_idcidade    => pr_idcidade    --> Identificador unico do cadstro de cidade
                             ,pr_cdcidade    => pr_cdcidade    --> Codigo da cidade CETIP/IBGE/CORREIOS/SFN
                             ,pr_dscidade    => pr_dscidade    --> Nome da cidade
                             ,pr_cdestado    => pr_cdestado    --> Codigo da UF
                             ,pr_infiltro    => pr_infiltro    --> 1-CETIP / 2-IBGE / 3-CORREIOS / 4-SFN
                             ,pr_intipnom    => pr_intipnom    --> 1-SEM ACENTUACAO / 2-COM ACENTUACAO
                             ,pr_tab_crapmun => vr_tab_crapmun --> PLTABLE com os dados
                             ,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
                             ,pr_dscritic    => vr_dscritic);  --> Descricao da critica
    -- Se retornou erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Se nao possuir nenhum registro, envia a quantidade de registros zerada
    IF vr_tab_crapmun.COUNT = 0 THEN
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Servico qtregist="0">');
    ELSE
      -- Loop das cidades
      FOR vr_ind IN 1..vr_tab_crapmun.COUNT LOOP

        -- Incrementa o contador de registros
        vr_posreg := vr_posreg + 1;

        -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
        IF vr_posreg = 1 THEN
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<Servico qtregist="' || vr_tab_crapmun.COUNT || '">');
        END IF;

        -- Enviar somente se a linha for superior a linha inicial
        IF nvl(pr_nriniseq,0) <= vr_posreg THEN

          -- Carrega os dados
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<inf>'||
                                                          '<idcidade>' || vr_tab_crapmun(vr_ind).idcidade ||'</idcidade>'||
                                                          '<dscidade>' || vr_tab_crapmun(vr_ind).dscidade ||'</dscidade>'||
                                                          '<cdestado>' || vr_tab_crapmun(vr_ind).cdestado ||'</cdestado>'||
                                                       '</inf>');

          vr_contador := vr_contador + 1;

        END IF;

        -- Deve-se sair se o total de registros superar o total solicitado
        EXIT WHEN vr_contador > nvl(pr_nrregist,99999);

      END LOOP;

    END IF;

    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</Servico></Dados>'
                           ,pr_fecha_xml      => TRUE);

    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);

  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina PC_LISTA_SERVICOS: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

  END pc_lista_cidades;

	-- Function para retornar código da cidade
	FUNCTION fn_busca_codigo_cidade(pr_cdestado IN crapmun.cdestado%TYPE
		                             ,pr_dscidade IN crapmun.dscidade%TYPE) RETURN INTEGER IS
	  CURSOR cr_crapmun IS
			SELECT mun.idcidade
				FROM crapmun mun
			 WHERE upper(mun.cdestado) = upper(pr_cdestado)
				 AND (upper(mun.dscidade) = upper(pr_dscidade)
					OR  upper(GENE0007.fn_caract_acento(mun.dscidesp)) = upper(pr_dscidade));
	  rw_crapmun cr_crapmun%ROWTYPE;
	BEGIN
		OPEN cr_crapmun;
		FETCH cr_crapmun INTO rw_crapmun;
		CLOSE cr_crapmun;
		RETURN nvl(rw_crapmun.idcidade, 0);
  END fn_busca_codigo_cidade;

  
  -- Procedimento para carga do arquivo Konviva para tabela com informações dos colaboradores
  PROCEDURE pc_integra_colaboradores IS
  BEGIN  
    /* .............................................................................
      Programa: pc_integra_colaboradores
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Marcos Martini
      Data    : Março/17.                    Ultima atualizacao: 
      
      Dados referentes ao programa:
      
      Frequencia: Sempre que for chamado
      
      Objetivo  : Rotina responsável por baixar o arquivo Konviva para diretório acessível
                  e atualizar a tabela TBCADAST_COLABORADOR com as informações dos colaboradores
                  do grupo Cecred e Cooperativas filiadas
      Observacao: -----
      
      Alteracoes: 
    ..............................................................................*/
  
    DECLARE 
      -- Script para download do arquivo
      vr_dscmdbai VARCHAR2(1000) := gene0001.fn_param_sistema('CRED',3,'CMD_DOWNLOAD_ARQ_KONVIVA');
      
      -- Caminho do arquivo Konviva
      vr_dsarquiv VARCHAR2(255) := gene0001.fn_param_sistema('CRED',3,'PATH_ARQUIVO_KONVIVA');
      vr_dspathar VARCHAR2(255);
      vr_dsnomear VARCHAR2(255);
      
      -- Tratamento de exceção
      vr_nmprogra VARCHAR2(1000) := 'cada0003.pc_integra_colaboradores';
      vr_excsaida EXCEPTION;
      vr_dscritic VARCHAR2(4000);
      vr_typdsaid VARCHAR2(20); 
      
      -- Processamento do arquivo
      vr_hutlfile utl_file.file_type;
      vr_dstxtlid VARCHAR2(1000);
      vr_qtdrlido NUMBER := 0;
      vr_txtauxil VARCHAR2(200); -- Texto auxiliar
      vr_cdcooper NUMBER(5);     -- Código da Cooperativa do Colaborador     
      vr_nrcpfcgc NUMBER(11);    -- Código do CPF co Colaborador             
      vr_cddcargo NUMBER(7);     -- Código do Cargo do Colaborador           
      vr_dsdcargo VARCHAR2(100); -- Descrição do Cargo do Colaborador        
      vr_dtadmiss DATE;          -- Data de admissão do Colaborador          
      vr_cdusured VARCHAR2(8);   -- Código do usuário do Colaborador na rede 
      vr_dsdemail VARCHAR2(200); -- Email do colaborador na rede             
      vr_flgativo VARCHAR2(1);   -- Flag de Colaborador ativo (S/N)     
      
    BEGIN 
      
      -- Incluir o cd ao diretório que será efetuado o download para que o script funcione corretamente
      vr_dscmdbai := 'cd '||SUBSTR(vr_dsarquiv,1,instr(vr_dsarquiv,'/',-1))||'; '||vr_dscmdbai;
      -- Executar o Script para download do arquivo usuarios.txt para o diretório acessáivel ao Ayllos
      gene0001.pc_OScommand(pr_typ_comando => 'SR'
                           ,pr_des_comando => vr_dscmdbai
                           ,pr_typ_saida   => vr_typdsaid
                           ,pr_des_saida   => vr_dscritic);
      IF NVL(vr_typdsaid,' ') = 'ERR' THEN
        -- Desfaz alterações e inclui erro no log pois não conseguimos eliminar o arquivo antigo
        vr_dscritic := 'Nao foi possivel buscar o arquivo original --> '||vr_dscritic;
        RAISE vr_excsaida;
      END IF;
      
      -- Verificar se o arquivo foi baixado corretamente
      IF NOT gene0001.fn_exis_arquivo(vr_dsarquiv) THEN 
        vr_dscritic := gene0001.fn_busca_critica(182);
        RAISE vr_excsaida;
      END IF;
      
      -- Efetuar a limpeza da tabela atual
      BEGIN 
        DELETE FROM tbcadast_colaborador;
      EXCEPTION 
        WHEN OTHERS THEN 
          vr_dscritic := 'Erro na limpeza da tabela tbcadast_colaborador --> '||SQLERRM;
          RAISE vr_excsaida;  
      END;
      
      -- Separação do path completo do arquivo
      gene0001.pc_separa_arquivo_path(pr_caminho => vr_dsarquiv
                                     ,pr_direto  => vr_dspathar
                                     ,pr_arquivo => vr_dsnomear);
      
      -- Efetuar abertura do arquivo para processamento
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_dspathar   --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_dsnomear   --> Nome do arquivo
                              ,pr_tipabert => 'R'           --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_hutlfile   --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic); --> Erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        vr_dscritic := 'Erro na leitura do arquivo ['||vr_dsnomear||'] --> '||vr_dscritic;
        RAISE vr_excsaida;
      ELSE
        -- Enviar informação de arquivo em integração
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',3,'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_nmprogra || ' --> '
                                                   || gene0001.fn_busca_critica(219) || ' --> ' || vr_dsnomear);          
      END IF;
          
      --Verifica se o arquivo esta aberto
      IF utl_file.IS_OPEN(vr_hutlfile) THEN
        BEGIN   
          -- Laço para efetuar leitura de todas as linhas do arquivo 
          LOOP  
            -- Leitura da linha x
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_hutlfile --> Handle do arquivo aberto
                                        ,pr_des_text => vr_dstxtlid); --> Texto lido
            
            -- Ignorar linhas vazias
            IF length(vr_dstxtlid) <= 3 THEN 
              continue;
            END IF;
            
            -- Incrementar a contagem
            vr_qtdrlido := vr_qtdrlido + 1;
            
            -- Efetuar leitura do CPF
            BEGIN
              vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 6
                                                      ,pr_dstext      => vr_dstxtlid
                                                      ,pr_delimitador => ';');
              -- Converter para o campo
              vr_nrcpfcgc := to_number(vr_txtauxil);                                        
            EXCEPTION
              WHEN OTHERS THEN 
                vr_dscritic := 'Erro na leitura do CPF --> '||vr_txtauxil;  
            END;
            
            -- Efetuar leitura do Cargo
            BEGIN
              vr_txtauxil := substr(gene0002.fn_busca_entrada(pr_postext     => 19
                                                             ,pr_dstext      => vr_dstxtlid
                                                             ,pr_delimitador => ';'),1,100);
              -- Separação do código e descrição
              vr_cddcargo := substr(vr_txtauxil,1,7);
              vr_dsdcargo := substr(vr_txtauxil,11);                                                         
            EXCEPTION
              WHEN OTHERS THEN 
                vr_dscritic := 'Erro na leitura do Cargo --> '||vr_txtauxil;  
            END;
            
            -- Leitura da Data de Admissão
            BEGIN
              vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 8
                                                      ,pr_dstext      => vr_dstxtlid
                                                      ,pr_delimitador => ';');
              -- Converter para data
              vr_dtadmiss := to_date(vr_txtauxil,'dd/mm/rrrr');                                        
            EXCEPTION
              WHEN OTHERS THEN 
                vr_dscritic := 'Erro na leitura da Data de Admissão --> '||vr_txtauxil;  
            END;        
            
            -- Leitura do usuário da rede
            BEGIN
              vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 3
                                                      ,pr_dstext      => vr_dstxtlid
                                                      ,pr_delimitador => ';');
              -- Copiar para o campo correto
              vr_cdusured := vr_txtauxil;                                      
            EXCEPTION
              WHEN OTHERS THEN 
                vr_dscritic := 'Erro na leitura do Usuario da Rede --> '||vr_txtauxil;  
            END;
            
            -- Leitura do Email
            BEGIN
              vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 5
                                                      ,pr_dstext      => vr_dstxtlid
                                                      ,pr_delimitador => ';');
              -- Copiar para o campo correto
              vr_dsdemail := vr_txtauxil;                                      
            EXCEPTION
              WHEN OTHERS THEN 
                vr_dscritic := 'Erro na leitura do Email --> '||vr_txtauxil;  
            END;        
            
            -- Leitura da Flag Ativa/Inativa
            BEGIN
              vr_txtauxil := gene0002.fn_busca_entrada(pr_postext     => 7
                                                      ,pr_dstext      => vr_dstxtlid
                                                      ,pr_delimitador => ';');
              -- Copiar para o campo correto
              vr_flgativo := vr_txtauxil;  
            EXCEPTION
              WHEN OTHERS THEN 
                vr_dscritic := 'Erro na leitura da Flag Ativa --> '||vr_txtauxil;  
            END;        
            
            -- Procurar a Cooperativa com base no usuário da rede
            BEGIN
              -- Copiar para o campo correto
              vr_cdcooper := substr(vr_cdusured,2,3);                                      
            EXCEPTION
              WHEN OTHERS THEN 
                vr_dscritic := 'Erro na leitura da Cooperativa com base no Usuario da Rede --> '||vr_cdusured;  
            END;        
                    
            -- Com as informações processada, iremos gravá-las na tabela
            BEGIN
              INSERT INTO tbcadast_colaborador(cdcooper
                                              ,nrcpfcgc
                                              ,cddcargo_vetor
                                              ,dsdcargo_vetor
                                              ,dtadmiss
                                              ,cdusured
                                              ,dsdemail
                                              ,flgativo)
                                        VALUES(vr_cdcooper
                                              ,vr_nrcpfcgc
                                              ,vr_cddcargo
                                              ,vr_dsdcargo
                                              ,vr_dtadmiss
                                              ,vr_cdusured
                                              ,vr_dsdemail
                                              ,vr_flgativo);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro na gravacao na tabela TBCADAST_COLABORADOR --> '||SQLERRM;
                RAISE vr_excsaida;
            END;
            
          
          END LOOP;
        EXCEPTION 
          WHEN no_data_found THEN 
            -- fechar arquivo
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);
        END;
      END IF;
      
      -- Eliminar o arquivo do diretório de processamento
      gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsarquiv
                                 ,pr_typ_saida   => vr_typdsaid
                                 ,pr_des_saida   => vr_dscritic);
      IF NVL(vr_typdsaid,' ') = 'ERR' THEN
        -- Desfaz alterações e inclui erro no log pois não conseguimos eliminar o arquivo
        vr_dscritic := 'Nao foi possivel remover o arquivo original --> '||vr_dscritic;
        RAISE vr_excsaida;
      END IF;
          
      -- Enviar informação de arquivo integrado com sucesso
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',3,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_nmprogra || ' --> '
                                                 || gene0001.fn_busca_critica(190) || ' --> ' || vr_dsnomear || ' --> ' ||vr_qtdrlido ||' colaboradores integrados');          
      -- Efetuar gravação das informações
      COMMIT;
      
    EXCEPTION
      WHEN vr_excsaida THEN
        -- Verifica se o arquivo esta aberto
        IF utl_file.IS_OPEN(vr_hutlfile) THEN
          -- fechar arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);
        END IF;
        -- Desfaz alterações
        ROLLBACK;
        -- Gerar log
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',3,'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')  ||
                                                      ' - ' || vr_nmprogra || ' --> Erro tratado na integracao : ' || vr_dscritic);
      WHEN OTHERS THEN 
        -- Verifica se o arquivo esta aberto
        IF utl_file.IS_OPEN(vr_hutlfile) THEN
          -- fechar arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);
        END IF;
        -- Desfaz alterações
        ROLLBACK;
        -- Gerar LOG    
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',3,'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')  ||
                                                      ' - ' || vr_nmprogra || ' --> Erro nao tratado na integracao : ' ||SQLERRM);    
    END;
  END pc_integra_colaboradores;
  
END CADA0003;
/
