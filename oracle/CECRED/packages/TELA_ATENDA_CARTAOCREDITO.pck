CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_CARTAOCREDITO IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_CARTAO_CREDITO
  --  Sistema  : Ayllos Web
  --  Autor    : 
  --  Data     :                  Ultima atualizacao: 06/04/2018
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas à tela de Cartão de Crédito
  --
  -- Alteracoes: 06/04/2018  Paulo Silva - Supero
  --             Inclusão das rotinas pc_busca_sugestao_motor, pc_valida_operador_alt_limite, pc_valida_operador_entrega e pc_busca_desc_administadora.
  --
  ---------------------------------------------------------------------------
  
  PROCEDURE pc_busca_hist_limite_crd(pr_cdcooper  IN tbcrd_limite_atualiza.cdcooper%TYPE       --> Cooperativa
                                    ,pr_nrdconta  IN tbcrd_limite_atualiza.nrdconta%TYPE       --> Conta
                                    ,pr_nrcctitg  IN tbcrd_limite_atualiza.nrconta_cartao%TYPE --> Cartão
                                    ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                    ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);         --> Erros do processo
                                    
  --> Retornar uma lista com as sugestões do motor para cartão de crédito
  PROCEDURE pc_busca_sugestao_motor(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                   
  --> Retornar uma lista com as sugestões do motor para alteracao de limite
  PROCEDURE pc_busca_sugestao_motor_alt(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                   ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE     --> Nr. proposta do cartao
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  --> Retornar uma lista com as sugestões do motor para cartão de crédito
  PROCEDURE pc_valida_operador_alt_limite(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);
                                         
  --> Validar se o operador que solicitou o cartão é o mesmo que está entregando
  PROCEDURE pc_valida_operador_entrega(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                      ,pr_nrcrcard IN crapcrd.nrcrcard%TYPE --> Nr. do Cartão
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);
                                      
  --> Retornar nome da administradora
  PROCEDURE pc_busca_desc_administadora(pr_cdadmcrd IN crapadc.cdadmcrd%TYPE --> Nr. da Conta
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);
                                       
  --> Retornar Situação Decisão Esteira
  PROCEDURE pc_busca_situacao_decisao(pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do contrato
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);
                                     
  --> Busca Assinatura Representantes/Procuradores
  PROCEDURE pc_busca_ass_repres_proc(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do contrato
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  --> Insere Aprovadores de Cartões
  PROCEDURE pc_insere_aprovador_crd( pr_cdcooper      IN tbcrd_aprovacao_cartao.cdcooper%TYPE
                                    ,pr_nrdconta      IN tbcrd_aprovacao_cartao.nrdconta%TYPE
                                    ,pr_nrctrcrd      IN tbcrd_aprovacao_cartao.nrctrcrd%TYPE
                                    ,pr_indtipo_senha IN tbcrd_aprovacao_cartao.indtipo_senha%TYPE
                                    ,pr_dtaprovacao   IN VARCHAR2
                                    ,pr_hraprovacao   IN tbcrd_aprovacao_cartao.hraprovacao%TYPE
                                    ,pr_nrcpf         IN tbcrd_aprovacao_cartao.nrcpf%TYPE
                                    ,pr_nmaprovador   IN tbcrd_aprovacao_cartao.nmaprovador%TYPE
                                    ,pr_cdoperad      IN crapope.cdoperad%TYPE --> Codigo do operador informado
                                    ,pr_xmllog        IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic      OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic      OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml        IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo      OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro      OUT VARCHAR2);           --> Erros do processo
                                    
  --> Busca Aprovadores Cartão
  PROCEDURE pc_busca_aprovadores_crd(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do contrato
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                    
  --> Atualiza número de contratao para sugestão do motor
  PROCEDURE pc_atualiza_contrato_suges_mot(pr_cdcooper      IN tbgen_webservice_aciona.cdcooper%TYPE
                                          ,pr_nrdconta      IN tbgen_webservice_aciona.nrdconta%TYPE
                                          ,pr_nrctrcrd      IN tbgen_webservice_aciona.nrctrprp%TYPE
                                          ,pr_dsprotoc      IN tbgen_webservice_aciona.dsprotocolo%TYPE
                                          ,pr_dsjustif      IN crawcrd.dsjustif%TYPE
                                          ,pr_idproces      IN VARCHAR2
                                          ,pr_xmllog        IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic      OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic      OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml        IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo      OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro      OUT VARCHAR2);           --> Erros do processo
                                          
  --> Busca Aprovadores Cartão
  PROCEDURE pc_possui_senha_aprov_crd(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                     
  PROCEDURE pc_atualiza_just_updown_cartao(pr_cdcooper      IN CRAWCRD.cdcooper%TYPE
                                          ,pr_nrdconta      IN CRAWCRD.nrdconta%TYPE
                                          ,pr_nrctrcrd      IN CRAWCRD.nrctrcrd%TYPE
                                          ,pr_ds_justif     IN CRAWCRD.dsjustif%TYPE
                                          ,pr_inupgrad      IN CRAWCRD.inupgrad%TYPE
                                          ,pr_cdadmnov      IN crawcrd.cdadmcrd%TYPE
                                          ,pr_xmllog        IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic      OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic      OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml        IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo      OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro      OUT VARCHAR2);         --> Erros do processo                                   
  PROCEDURE pc_verifica_adicionais(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                  , pr_xmllog IN VARCHAR2               --> XML com informações de LOG
                                  , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  , pr_retxml IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  , pr_des_erro OUT VARCHAR2); --> Erros do processo                                          
                                  
  PROCEDURE pc_busca_parametro_pa_cartao(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo do PA
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                        
  --> Rotina responsavel por gerar a inclusao da proposta para a estra
  PROCEDURE pc_incluir_proposta_est_wb(pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                      ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE
                                      ,pr_dsiduser  IN VARCHAR2              --> ID sessao do usuario
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2);

  --> Chama rotina para criar proposta de Alteração de Limite
  PROCEDURE pc_altera_limite_crd_wb(pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                   ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE
                                   ,pr_vllimite  IN crawcrd.vllimcrd%TYPE
                                   ,pr_dsprotoc  IN crawcrd.dsprotoc%TYPE
                                   ,pr_dsjustif  IN crawcrd.dsjustif%TYPE
                                   ,pr_flgtplim  IN VARCHAR2
                                   ,pr_tpsituac  IN NUMBER
                                   ,pr_insitdec  IN NUMBER
                                   ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);

  --> Chama rotina para criar proposta de Alteração de Limite
  PROCEDURE pc_altera_limite_crd(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                ,pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE
                                ,pr_vllimite  IN crawcrd.vllimcrd%TYPE
                                ,pr_dsprotoc  IN crawcrd.dsprotoc%TYPE
                                ,pr_dsjustif  IN crawcrd.dsjustif%TYPE
                                ,pr_flgtplim  IN VARCHAR2
                                ,pr_idorigem  IN NUMBER
                                ,pr_tpsituac  IN NUMBER
                                ,pr_insitdec  IN NUMBER
                                ,pr_nmdatela  IN craptel.nmdatela%TYPE  --> Nome da Tela
                                ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                ,pr_des_erro  OUT VARCHAR2);
  
  --Valida se possui cartões com valores diferenciados                              
  PROCEDURE pc_valida_limite_diferenciado(pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr. da Conta
                                         ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do Cartão
                                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                         
  --Rotina para validar se é titular da conta
  PROCEDURE pc_valida_eh_titular(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do Cartão
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                
  --Rotina para verificar os cartões que o cooperado já possui
  PROCEDURE pc_verifica_cartoes(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  --> Rotina responsavel por verificar se existe Aleração de Limite Pendente de Aprovação na Esteira
  PROCEDURE pc_valida_alt_pend_esteira(pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                      ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2);
                                      
  --> Rotina responsavel por Cancelar a Proposta do Cartão
  PROCEDURE pc_cancela_proposta_crd(pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                   ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE
                                   ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);

	PROCEDURE pc_verifica_tipo_proposta(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
																		 ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do Cartão
																		 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
																		 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
																		 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																		 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
																		 ,pr_des_erro OUT VARCHAR2);
                                       
  PROCEDURE pc_atualiza_limite_crd(pr_cdcooper     IN tbcrd_limite_atualiza.cdcooper%TYPE
                                  ,pr_nrdconta     IN tbcrd_limite_atualiza.nrdconta%TYPE
                                  ,pr_nrctrcrd     IN tbcrd_limite_atualiza.nrctrcrd%TYPE
                                  ,pr_insitdec     IN tbcrd_limite_atualiza.insitdec%TYPE
                                  ,pr_tpsituacao   IN tbcrd_limite_atualiza.tpsituacao%TYPE
                                  ,pr_vllimite_anterior IN tbcrd_limite_atualiza.vllimite_anterior%TYPE
                                  ,pr_vllimite_alterado IN tbcrd_limite_atualiza.vllimite_alterado%TYPE
                                  ,pr_cdoperad          IN tbcrd_limite_atualiza.cdoperad%TYPE
                                  ,pr_dsjustificativa   IN tbcrd_limite_atualiza.dsjustificativa%TYPE
                                  ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2) ;
                                  
                                  
  PROCEDURE pc_atualiza_limite_crd_web(pr_cdcooper     IN tbcrd_limite_atualiza.cdcooper%TYPE
                                      ,pr_nrdconta     IN tbcrd_limite_atualiza.nrdconta%TYPE
                                      ,pr_nrctrcrd     IN tbcrd_limite_atualiza.nrctrcrd%TYPE
                                      ,pr_insitdec     IN tbcrd_limite_atualiza.insitdec%TYPE
                                      ,pr_tpsituacao   IN tbcrd_limite_atualiza.tpsituacao%TYPE
                                      ,pr_vllimite_anterior IN tbcrd_limite_atualiza.vllimite_anterior%TYPE
                                      ,pr_vllimite_alterado IN tbcrd_limite_atualiza.vllimite_alterado%TYPE
                                      ,pr_dsjustificativa   IN tbcrd_limite_atualiza.dsjustificativa%TYPE
                                      ,pr_dsiduser  IN VARCHAR2              --> ID sessao do usuario
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2) ;

   PROCEDURE pc_busca_config_limite_crd_web(pr_cdcooper    IN TBCRD_CONFIG_CATEGORIA.CDCOOPER%TYPE
                                          ,pr_cdadmcrd    IN TBCRD_CONFIG_CATEGORIA.CDADMCRD%TYPE
                                          ,pr_tplimcrd    IN tbcrd_config_categoria.tplimcrd%TYPE DEFAULT 0
                                          ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro  OUT VARCHAR2) ;

   PROCEDURE pc_valida_alt_nome_empr (pr_cdcooper IN crawcrd.cdcooper%TYPE --> Codigo da cooperativa
                                     ,pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) ;         --> Erros do processo                                       
																		 
   PROCEDURE pc_valida_dtcorte_prot_entrega(pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE
																					 ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
																					 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
																					 ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
																					 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																					 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
																					 ,pr_des_erro OUT VARCHAR2);
																					 
   PROCEDURE pc_imprimir_protocolo_entrega(pr_nrctrcrd IN crapcrd.nrctrcrd%TYPE
																					,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
																					,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
																					,pr_dscritic OUT VARCHAR2 --> Descricao da critica
																					,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																					,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
																					,pr_des_erro OUT VARCHAR2);																					 																			 

  PROCEDURE pc_valida_reenvio_alt_limite(pr_cdcooper  IN tbcrd_limite_atualiza.cdcooper%TYPE       --> Cooperativa
                                        ,pr_nrdconta  IN tbcrd_limite_atualiza.nrdconta%TYPE       --> Conta
																				,pr_nrcctitg  IN tbcrd_limite_atualiza.nrconta_cartao%TYPE --> Cartão
																				,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
																				,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
																				,pr_dscritic OUT VARCHAR2           --> Descricao da critica
																				,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																				,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
																				,pr_des_erro OUT VARCHAR2);         --> Erros do processo	
	
	PROCEDURE pc_atualiza_endereco_crd(pr_cdcooper      IN  tbcrd_endereco_entrega.cdcooper%TYPE     --> Código da cooperativa
		                                ,pr_nrdconta      IN  tbcrd_endereco_entrega.nrdconta%TYPE     --> Número da conta
																		,pr_nrctrcrd      IN  tbcrd_endereco_entrega.nrctrcrd%TYPE     --> Número da proposta de cartão de crédito
																		,pr_idtipoenvio   IN  tbcrd_endereco_entrega.idtipoenvio%TYPE	 --> Tipo de envio do cartão
																		,pr_cdagenci      IN  tbcrd_endereco_entrega.cdagenci%TYPE     --> Código da agencia de envio
																		,pr_xmllog        IN  VARCHAR2                                 --> XML com informacoes de LOG
																	  ,pr_cdcritic      OUT PLS_INTEGER                              --> Codigo da critica
																		,pr_dscritic      OUT VARCHAR2                                 --> Descricao da critica
																	  ,pr_retxml        IN  OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
																		,pr_nmdcampo      OUT VARCHAR2                                 --> Nome do campo com erro
																	 	,pr_des_erro      OUT VARCHAR2);                               --> Erros do processo
																		
  PROCEDURE pc_busca_parametro_aprovador (pr_cdcooper  IN crapprm.cdcooper%TYPE   --> Código da cooperativa
		                                     ,pr_xmllog    IN VARCHAR2                --> XML com informacoes de LOG
																	       ,pr_cdcritic OUT PLS_INTEGER             --> Codigo da critica
																		     ,pr_dscritic OUT VARCHAR2                --> Descricao da critica
																	       ,pr_retxml    IN OUT NOCOPY xmltype      --> Arquivo de retorno do XML
																		     ,pr_nmdcampo OUT VARCHAR2                --> Nome do campo com erro
																	 	     ,pr_des_erro OUT VARCHAR2);              --> Erros do processo

  PROCEDURE pc_busca_enderecos_crd(pr_cdcooper IN crawcrd.cdcooper%TYPE --> Codigo da cooperativa
                                  ,pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr. da Conta
																	,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2); --> Erros do processo
																	
	PROCEDURE pc_verifica_cooperativa_pa(pr_cdcooper          IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
																			,pr_nrdconta          IN crapass.nrdconta%TYPE --> Numero da Conta
																			,pr_coop_envio_cartao OUT INTEGER --> Indica se cooperativa esta habilitada para envio de cartao
																			,pr_pa_envio_cartao   OUT INTEGER --> Indica se o PA esta habilitado para envio de cartao
																			,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
																			,pr_dscritic          OUT VARCHAR2); --> Erros do processo

	PROCEDURE pc_verifica_cooperativa_pa_web(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta
																					,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
																					,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
																					,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
																					,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																					,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
																					,pr_des_erro OUT VARCHAR2); --> Erros do processo																	
																	
	PROCEDURE pc_busca_dados_crd(pr_cdcooper IN crawcrd.cdcooper%TYPE --> Nr. da Cooperativa
															,pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr. da Conta
															,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. proposta do cartao
															,pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE --> Nr. da administradora do cartao
															,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
															,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
															,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
															,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
															,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
															,pr_des_erro OUT VARCHAR2);           --> Erros do processo																		 
	-- Busca parametros de majoracao do cooperado
	PROCEDURE pc_busca_param_majora(pr_nrdconta              IN crapass.nrdconta%TYPE
									-- Mensageria
									,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
									,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
									,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
									,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
									,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
									,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK 

	-- Mantem párametros de majoracao do cooperado
	PROCEDURE pc_mantem_param_majora(pr_nrdconta              IN crapass.nrdconta%TYPE
									-- Mensageria
									,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
									,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
									,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
									,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
									,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
									,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK

END tela_atenda_cartaocredito;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_CARTAOCREDITO IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_CARTAOCREDITO
  --  Sistema  : Ayllos Web
  --  Autor    : Renato Darosci
  --  Data     : Agosto/2017                 Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela de Cartão de Crédito
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_busca_hist_limite_crd(pr_cdcooper  IN tbcrd_limite_atualiza.cdcooper%TYPE       --> Cooperativa
                                    ,pr_nrdconta  IN tbcrd_limite_atualiza.nrdconta%TYPE       --> Conta
                                    ,pr_nrcctitg  IN tbcrd_limite_atualiza.nrconta_cartao%TYPE --> Cartão
                                    ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                    ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
  /* .............................................................................

    Programa: pc_busca_hist_limite_crd
    Sistema : Ayllos Web
    Autor   : Renato Darosci
    Data    : Agosto/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para listar o histórico de alteração de limite de
                cartão de crédito

    Alteracoes:
  ..............................................................................*/

    -- Buscar todos os lançamentos
    CURSOR cr_limite IS
      SELECT to_char(atu.dtalteracao,'DD/MM/YYYY')  dtretorno
           , DECODE(atu.cdcanal, 14, 'AUTOMATICA'   /* SAS */
                                   , 'MANUAL' )   dstipatu
           , atu.vllimite_anterior
           , atu.vllimite_alterado
           , atu.nrproposta_est
           , atu.tpsituacao
           , DECODE(atu.tpsituacao,1,'1 - Pendente'
                                  ,2,'2 - Enviado ao Bancoob'
                                  ,3,'3 - Concluido'
                                  ,4,'4 - Erro'
                                  ,6,'6 - Em Analise'
                                  ,8,'8 - Efetivada') Situacao
           , atu.idatualizacao
					 , atu.nrctrcrd
        FROM tbcrd_limite_atualiza atu
       WHERE atu.cdcooper       = pr_cdcooper
         AND atu.nrdconta       = pr_nrdconta
         AND atu.nrconta_cartao = pr_nrcctitg
         AND atu.tpsituacao     = 3 /* Concluido com sucesso */
         and atu.nrproposta_est IS NULL
      UNION      
      SELECT to_char(atu.dtalteracao,'DD/MM/YYYY')  dtretorno
           , DECODE(atu.cdcanal, 14, 'AUTOMATICA'   /* SAS */
                                   , 'MANUAL' )   dstipatu
           , atu.vllimite_anterior
           , atu.vllimite_alterado
           , atu.nrproposta_est
           , atu.tpsituacao
           , DECODE(atu.tpsituacao,1,'1 - Pendente'
                                  ,2,'2 - Enviado ao Bancoob'
                                  ,3,'3 - Concluido'
                                  ,4,'4 - Erro'
                                  ,6,'6 - Em Analise'
                                  ,8,'8 - Efetivada') Situacao
           , atu.idatualizacao
					 , atu.nrctrcrd
        FROM tbcrd_limite_atualiza atu
       WHERE atu.cdcooper       = pr_cdcooper
         AND atu.nrdconta       = pr_nrdconta
         AND atu.nrconta_cartao = pr_nrcctitg
         AND atu.nrproposta_est IS NOT NULL
         AND atu.dtalteracao = (SELECT max(dtalteracao)
                                    FROM tbcrd_limite_atualiza lim
                                   WHERE lim.cdcooper       = atu.cdcooper
                                     AND lim.nrdconta       = atu.nrdconta
                                     AND lim.nrconta_cartao = atu.nrconta_cartao
                                     AND lim.nrproposta_est = atu.nrproposta_est)
       ORDER BY idatualizacao DESC;

    -- Variavel de criticas
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis gerais
    vr_cont_tag PLS_INTEGER := 0;
		vr_reenvio NUMBER := 0;

  BEGIN

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    -- Insere o nodo de históricos
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Dados'
													,pr_posicao  => 0
													,pr_tag_nova => 'historicos'
													,pr_tag_cont => NULL
													,pr_des_erro => vr_dscritic);

    -- Para cada um dos históricos de alteração de limite
    FOR rw_limite IN cr_limite LOOP
			
		  -- Se ao menos um dos historicos estiver com Erro ou Analise ja permitimos o reenvio
		  IF rw_limite.tpsituacao IN (4, 6) THEN
				vr_reenvio := 1;
			END IF;
		
      -- Insere o nodo de histórico
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historicos'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'historico'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      -- Insere a data de alteração do limite
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'dtaltera'
                            ,pr_tag_cont => rw_limite.dtretorno
                            ,pr_des_erro => vr_dscritic);

      -- Insere a forma de atualização do limite
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'dstipalt'
                            ,pr_tag_cont => rw_limite.dstipatu
                            ,pr_des_erro => vr_dscritic);

      -- Valor de limite antigo
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'vllimold'
                            ,pr_tag_cont => TO_CHAR(rw_limite.vllimite_anterior,'FM9G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')
                            ,pr_des_erro => vr_dscritic);
      -- Novo valor de limite
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'vllimnew'
                            ,pr_tag_cont => TO_CHAR(rw_limite.vllimite_alterado,'FM9G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')
                            ,pr_des_erro => vr_dscritic);
      -- Número Prposta Esteira
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'nrproposta_est'
                            ,pr_tag_cont => NVL(rw_limite.nrproposta_est, 0)
                            ,pr_des_erro => vr_dscritic);
      -- Situação
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'situacao'
                            ,pr_tag_cont => rw_limite.situacao
                            ,pr_des_erro => vr_dscritic);

      -- Id da Atualizacao do Limite
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'idatualizacao'
                            ,pr_tag_cont => rw_limite.idatualizacao
                            ,pr_des_erro => vr_dscritic);
														
      -- Situacao da Atualizacao do Limite
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'tpsituacao'
                            ,pr_tag_cont => rw_limite.tpsituacao
                            ,pr_des_erro => vr_dscritic);
														
      -- Numero da proposta do cartao que solicitou a atualizacao do limite
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'nrctrcrd'
                            ,pr_tag_cont => rw_limite.nrctrcrd
                            ,pr_des_erro => vr_dscritic);

      -- Incrementa o contador de tags
      vr_cont_tag := vr_cont_tag + 1;
    END LOOP;

		GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Dados'
													,pr_posicao  => 0
													,pr_tag_nova => 'reenvio'
													,pr_tag_cont => vr_reenvio
													,pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PC_BUSCA_HIST_LIMITE_CRD: ' || SQLERRM;

      -- Carregar XML padrão para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_busca_hist_limite_crd;
  
  --> Retornar uma lista com as sugestões do motor para cartão de crédito
  PROCEDURE pc_busca_sugestao_motor(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_busca_sugestao_motor
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 06/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Retornar uma lista com as sugestões do motor para cartão de crédito

        Observacao: -----

        Alteracoes: Alterado para sempre solicitar a sugestao do motor conforme
                    solicitacao do negocio (Anderson)
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Buscar sugestões na tela de acionamento
    CURSOR cr_acionamento(pr_cdcooper crapass.cdcooper%TYPE
                         ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT idacionamento
            ,dsconteudo_requisicao
        FROM tbgen_webservice_aciona
       WHERE cdcooper = pr_cdcooper
         AND cdoperad = 'MOTOR'
         AND nrdconta = pr_nrdconta
         AND tpacionamento = 2 --> Apenas Retorno
         AND cdorigem IN (5,9) --> Apenas Ayllos Web / Motor
         AND tpproduto = 4     --> Apenas Cartão de Crédito
         AND dhacionamento = (SELECT MAX(dhacionamento)
                                FROM tbgen_webservice_aciona
                               WHERE cdcooper = pr_cdcooper
                                 AND cdoperad = 'MOTOR'
                                 AND nrdconta = pr_nrdconta
                                 AND tpacionamento = 2 --> Apenas Retorno
                                 AND cdorigem IN (5,9) --> Apenas Ayllos Web / Motor
                                 AND tpproduto = 4     --> Apenas Cartão de Crédito
                                 AND trunc(dhacionamento) BETWEEN (trunc(SYSDATE) - 10) and trunc(SYSDATE))
      ORDER BY dhacionamento;
    rw_acionamento cr_acionamento%ROWTYPE;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    vr_dsmensag VARCHAR2(32767);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    
  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'sugestoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Solicita sugestão ao motor
    este0005.pc_solicita_sugestao_mot(pr_cdcooper  => vr_cdcooper
                                     ,pr_cdagenci  => vr_cdagenci
                                     ,pr_cdoperad  => vr_cdoperad
                                     ,pr_cdorigem  => vr_idorigem
                                     ,pr_nrdconta  => pr_nrdconta
                                     ,pr_dtmvtolt  => TRUNC(SYSDATE)
                                     ---- OUT ----
                                     ,pr_dsmensag => vr_dsmensag
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic );

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    OPEN cr_acionamento(pr_cdcooper => vr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
    FETCH cr_acionamento INTO rw_acionamento;
    
    IF cr_acionamento%FOUND THEN
      CLOSE cr_acionamento;
      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestoes',pr_posicao => 0          , pr_tag_nova => 'sugestao'         ,pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'json'             ,pr_tag_cont => rw_acionamento.dsconteudo_requisicao, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'idacionamento'    ,pr_tag_cont => rw_acionamento.idacionamento, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'mensagem'         ,pr_tag_cont => vr_dsmensag, pr_des_erro => vr_dscritic);
    END IF;
    
    IF (UPPER(vr_dsmensag) LIKE '%CONTINGENCIA%') THEN
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'contingencia_ibra',pr_tag_cont => vr_dsmensag, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'contingencia_mot' ,pr_tag_cont => ''  , pr_des_erro => vr_dscritic);
    ELSIF (UPPER(vr_dsmensag) LIKE '%NAO HABILITADA%') THEN
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'contingencia_ibra',pr_tag_cont => ''  , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'contingencia_mot' ,pr_tag_cont => vr_dsmensag, pr_des_erro => vr_dscritic);
    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_busca_sugestao_motor. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_busca_sugestao_motor;
  
  --> Retornar uma lista com as sugestões do motor para cartão de crédito
  PROCEDURE pc_busca_sugestao_motor_alt(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                   ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE     --> Nr. proposta do cartao
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_busca_sugestao_motor
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 06/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Retornar uma lista com as sugestões do motor para cartão de crédito

        Observacao: -----

        Alteracoes: Alterado para sempre solicitar a sugestao do motor conforme
                    solicitacao do negocio (Anderson)
    ..............................................................................*/

    ---------> CURSORES <--------
    --> Buscar sugestões na tela de acionamento
    CURSOR cr_acionamento(pr_cdcooper crapass.cdcooper%TYPE
                         ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT idacionamento
            ,dsconteudo_requisicao
        FROM tbgen_webservice_aciona
       WHERE cdcooper = pr_cdcooper
         AND cdoperad = 'MOTOR'
         AND nrdconta = pr_nrdconta
         AND tpacionamento = 2 --> Apenas Retorno
         AND cdorigem IN (5,9) --> Apenas Ayllos Web / Motor
         AND tpproduto = 4     --> Apenas Cartão de Crédito
         AND dhacionamento = (SELECT MAX(dhacionamento)
                                FROM tbgen_webservice_aciona
                               WHERE cdcooper = pr_cdcooper
                                 AND cdoperad = 'MOTOR'
                                 AND nrdconta = pr_nrdconta
                                 AND tpacionamento = 2 --> Apenas Retorno
                                 AND cdorigem IN (5,9) --> Apenas Ayllos Web / Motor
                                 AND tpproduto = 4     --> Apenas Cartão de Crédito
                                 AND trunc(dhacionamento) BETWEEN (trunc(SYSDATE) - 10) and trunc(SYSDATE))
      ORDER BY dhacionamento;
    rw_acionamento cr_acionamento%ROWTYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    vr_dsmensag VARCHAR2(32767);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    
  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'sugestoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Solicita sugestão ao motor
      este0005.pc_solicita_sugestao_mot(pr_cdcooper  => vr_cdcooper
                                       ,pr_cdagenci  => vr_cdagenci
                                       ,pr_cdoperad  => vr_cdoperad
                                       ,pr_cdorigem  => vr_idorigem
                                       ,pr_nrdconta  => pr_nrdconta
                                       ,pr_dtmvtolt  => TRUNC(SYSDATE)
                                     ,pr_tpproces  => 'A' -- Alteracao
                                     ,pr_nrctrcrd  => pr_nrctrcrd
                                       ---- OUT ----
                                       ,pr_dsmensag => vr_dsmensag
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic );
                                       
      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
    
      OPEN cr_acionamento(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => pr_nrdconta);
      FETCH cr_acionamento INTO rw_acionamento;
      
      IF cr_acionamento%FOUND THEN
        CLOSE cr_acionamento;
        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestoes', pr_posicao => 0, pr_tag_nova => 'sugestao', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'json', pr_tag_cont => rw_acionamento.dsconteudo_requisicao, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'idacionamento', pr_tag_cont => rw_acionamento.idacionamento, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'mensagem', pr_tag_cont => vr_dsmensag, pr_des_erro => vr_dscritic);
      END IF;
    
    IF (UPPER(vr_dsmensag) LIKE '%CONTINGENCIA%') THEN
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'contingencia_ibra',pr_tag_cont => vr_dsmensag, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'contingencia_mot' ,pr_tag_cont => '', pr_des_erro => vr_dscritic);
    ELSIF (UPPER(vr_dsmensag) LIKE '%NAO HABILITADA%') THEN
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'contingencia_ibra',pr_tag_cont => '', pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'contingencia_mot' ,pr_tag_cont => vr_dsmensag, pr_des_erro => vr_dscritic);
    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_busca_sugestao_motor. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_busca_sugestao_motor_alt;
  
  --> Validar se o operador está alterando o limite da sua própria conta
  PROCEDURE pc_valida_operador_alt_limite(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_valida_operador_alt_limite
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 06/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Validar se o operador está alterando o limite da sua própria conta

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Valida se o operador é o titular da conta
    CURSOR cr_conta_oper (pr_cdcooper crapass.cdcooper%TYPE
                         ,pr_nrdconta crapass.nrdconta%TYPE
                         ,pr_cdoperad crapope.cdoperad%TYPE) IS
      SELECT 'S' existeconta
            ,idseqttl
        FROM crapttl              ttl
            ,tbcadast_colaborador col
            ,crapope              ope
       /* Comentado a cooperativa devido aos usuários da Cooper 3 - Cecred
          terem contas nas mais diversas cooperativas */
       WHERE --ope.cdcooper = pr_cdcooper and
             ope.cdoperad = pr_cdoperad
         AND col.cdcooper = ope.cdcooper
         AND col.cdusured = ope.cdoperad
         AND ttl.cdcooper = pr_cdcooper
         AND ttl.nrcpfcgc = col.nrcpfcgc
         AND ttl.nrdconta = pr_nrdconta;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    
    vr_existe_conta VARCHAR2(1) := 'N';
    vr_titular      VARCHAR2(1) := 'N';
    
  BEGIN

    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'contas', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_conta_oper IN cr_conta_oper(pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_cdoperad => vr_cdoperad) LOOP

      vr_existe_conta := rw_conta_oper.existeconta;
      
      IF rw_conta_oper.idseqttl = 1 THEN
        vr_titular      := 'S';
      END IF;     
      
    END LOOP;
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => 0, pr_tag_nova => 'conta', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'existeconta', pr_tag_cont => vr_existe_conta, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'titular', pr_tag_cont => vr_titular, pr_des_erro => vr_dscritic);

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
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_valida_operador_alt_limite. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_valida_operador_alt_limite;
  
  --> Validar se o operador que solicitou o cartão é o mesmo que está entregando
  PROCEDURE pc_valida_operador_entrega(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                      ,pr_nrcrcard IN crapcrd.nrcrcard%TYPE --> Nr. do Cartão
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_valida_operador_entrega
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 06/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Validar se o operador que solicitou o cartão é o mesmo que está entregando

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Valida se o operador é o titular da conta
    CURSOR cr_oper_entrega (pr_cdcooper crapass.cdcooper%TYPE
                           ,pr_nrdconta crapass.nrdconta%TYPE
                           ,pr_nrcrcard crapcrd.nrcrcard%TYPE) IS
      SELECT crd.cdopeori
            ,crd.cdadmcrd
        FROM crapcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrcrcard = pr_nrcrcard;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    
    vr_mesmo_operador varchar2(1) := 'N';
    
  BEGIN

    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'cartoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_oper_entrega IN cr_oper_entrega(pr_cdcooper => vr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrcrcard => pr_nrcrcard) LOOP

      --Valida se não é Cartão BB
      IF rw_oper_entrega.cdadmcrd NOT IN (83,85,87) THEN
        --Valida se operador da solicitação é o mesmo da entrega
        IF rw_oper_entrega.cdopeori = vr_cdoperad THEN
          vr_mesmo_operador := 'S';
        END IF;
      END IF;
      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cartoes', pr_posicao => 0, pr_tag_nova => 'cartao', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cartao', pr_posicao => vr_contador, pr_tag_nova => 'operador', pr_tag_cont => vr_mesmo_operador, pr_des_erro => vr_dscritic);
      
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

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_valida_operador_entrega. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_valida_operador_entrega;
  
  --> Retornar nome da administradora
  PROCEDURE pc_busca_desc_administadora(pr_cdadmcrd IN crapadc.cdadmcrd%TYPE --> Nr. da Conta
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_busca_desc_administadora
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 06/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Retornar nome da administradora

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Buscar informações da administradora do cartão
    CURSOR cr_admin(pr_cdcooper crapass.cdcooper%TYPE) IS
      SELECT adc.nmresadm
        FROM crapadc adc
       WHERE adc.cdcooper = pr_cdcooper
         AND adc.cdadmcrd = pr_cdadmcrd;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    
  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'administradoras', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_admin IN cr_admin(pr_cdcooper => vr_cdcooper) LOOP      

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'administradoras', pr_posicao => 0, pr_tag_nova => 'administradora', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'administradoras', pr_posicao => vr_contador, pr_tag_nova => 'nome', pr_tag_cont => rw_admin.nmresadm, pr_des_erro => vr_dscritic);
   
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

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_busca_desc_administadora. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_busca_desc_administadora;
  
  --> Retornar Situação Decisão Esteira
  PROCEDURE pc_busca_situacao_decisao(pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do contrato
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_busca_situacao_decisao
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 06/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Retornar descrição da decição da Esteira de crédito

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Buscar informações da administradora do cartão
    CURSOR cr_crawcrd(pr_cdcooper crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                     ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE) IS
      SELECT crd.nrcrcard
            ,crd.dtpropos
            ,crd.insitcrd
            ,crd.insitdec
            ,decode(crd.insitdec,
                   1,'Sem Aprovacao',
                   2,'Aprovada Auto',
                   3,'Aprovada Manual',
                   4,'Erro',
                   5,'Rejeitada Manual',
                   6,'Refazer',
                   7,'Expirada',
                   8,'Efetivado',
                   '') dssitdec
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrctrcrd = pr_nrctrcrd;
    rw_crawcrd cr_crawcrd%ROWTYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Gerais
    vr_contador NUMBER := 0;
    vr_dtcorte  DATE;
    vr_dssitdec VARCHAR2(100);
    vr_dssitest VARCHAR2(100);
    
  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    vr_dtcorte := to_date(gene0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdacesso => 'DATA_PROJETO_CARTAO'),'DD/MM/YYYY');

    OPEN cr_crawcrd(pr_cdcooper => vr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                   ,pr_nrctrcrd => pr_nrctrcrd);
    FETCH cr_crawcrd INTO rw_crawcrd;
    CLOSE cr_crawcrd;

    IF rw_crawcrd.dtpropos < vr_dtcorte AND rw_crawcrd.nrcrcard > 0 THEN
      vr_dssitdec := NULL;
      vr_dssitest := NULL;
    ELSE
      vr_dssitdec := rw_crawcrd.dssitdec;
   
      IF rw_crawcrd.insitdec IN (2,3,4,5,6,8) THEN
        vr_dssitest := 'Analise Finalizada';
      ELSIF rw_crawcrd.insitdec = 1 AND rw_crawcrd.insitcrd IN (1,8) THEN
        vr_dssitest := 'Enviada Analise Manual';
      ELSIF rw_crawcrd.insitdec = 7 THEN
        vr_dssitest := 'Expirada';
      END IF;
    END IF;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'cartoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cartoes', pr_posicao => vr_contador, pr_tag_nova => 'sitdec', pr_tag_cont => vr_dssitdec, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cartoes', pr_posicao => vr_contador, pr_tag_nova => 'sitest', pr_tag_cont => vr_dssitest, pr_des_erro => vr_dscritic);

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
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_busca_situacao_decisao. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_busca_situacao_decisao;
  
  --> Busca Assinatura Representantes/Procuradores
  PROCEDURE pc_busca_ass_repres_proc(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do contrato
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_busca_ass_repres_proc
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 09/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Busca lista de representantes/procuradores de pessoas jurídicas para validar assinatura

        Observacao: -----

        Alteracoes: 30/07/2018 - Paulo Silva (Supero) - Removida a consulta do código do supervisor.
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Buscar dados associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT crapass.cdagenci, 
             crapass.inpessoa,
             crapass.vllimcre,
             crapass.cdcooper,
             crapass.nrdconta,
             crapass.nmprimtl,
             crapass.cdsitdtl,
             crapass.nrcpfcgc,
             crapass.inlbacen,
             crapass.cdsitcpf,
             crapass.cdtipcta,
             crapass.dtdemiss,
             crapass.nrdctitg,
             crapass.flgctitg,
             crapass.idimprtr,
             crapass.idastcjt,
             crapass.cdsitdct
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --> Buscar dados assinatura
    CURSOR cr_tbaprc (pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE,
                      pr_nrctrcrd crawcrd.nrctrcrd%TYPE,
                      pr_nrcpf    tbcrd_aprovacao_cartao.nrcpf%TYPE)IS
      SELECT idaprovacao,
             cdcooper,
             nrdconta,
             nrctrcrd,
             indtipo_senha,
             dtaprovacao,
             hraprovacao,
             nrcpf,
             nmaprovador
        FROM tbcrd_aprovacao_cartao
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrcrd = pr_nrctrcrd
         AND nrcpf    = pr_nrcpf;
    rw_tbaprc cr_tbaprc%ROWTYPE;
    
    CURSOR cr_crawcrd (pr_cdcooper crawcrd.cdcooper%TYPE) IS
      SELECT insitcrd
            ,inupgrad
            ,dsprotoc
            ,dsjustif
        FROM crawcrd
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrcrd = pr_nrctrcrd;
    rw_crawcrd cr_crawcrd%ROWTYPE;
    
    vr_assinou  VARCHAR2(1);
    vr_idxctr   PLS_INTEGER;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    
    vr_tab_crapavt cada0001.typ_tab_crapavt_58; --Tabela Avalistas
    vr_tab_bens    cada0001.typ_tab_bens;          --Tabela bens
    vr_tab_erro    gene0001.typ_tab_erro;
    
  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'representantes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    OPEN cr_crawcrd(pr_cdcooper => vr_cdcooper);
    FETCH cr_crawcrd INTO rw_crawcrd;
    CLOSE cr_crawcrd;
    
    --Busca dados do associado
    FOR rw_crapass IN cr_crapass(pr_cdcooper => vr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP      

      IF rw_crapass.inpessoa = 2 THEN --PJ
        cada0001.pc_busca_dados_58(pr_cdcooper => vr_cdcooper
                                  ,pr_cdagenci => vr_cdagenci
                                  ,pr_nrdcaixa => vr_nrdcaixa
                                  ,pr_cdoperad => vr_cdoperad
                                  ,pr_nmdatela => vr_nmdatela
                                  ,pr_idorigem => vr_idorigem
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => 0
                                  ,pr_flgerlog => FALSE
                                  ,pr_cddopcao => 'C'
                                  ,pr_nrdctato => 0
                                  ,pr_nrcpfcto => ''
                                  ,pr_nrdrowid => NULL
                                  ,pr_tab_crapavt => vr_tab_crapavt
                                  ,pr_tab_bens => vr_tab_bens
                                  ,pr_tab_erro => vr_tab_erro
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR 
          vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        vr_idxctr := vr_tab_crapavt.first;
        --> Verificar se retornou informacao
        IF vr_idxctr IS NULL THEN
          vr_dscritic := 'Não foram encontrados dados de representantes.';
          RAISE vr_exc_saida;
        END IF;
            
        FOR vr_cont_reg IN vr_tab_crapavt.FIRST..vr_tab_crapavt.LAST LOOP
          
          -- Buscar dados assinatura
          OPEN cr_tbaprc(pr_cdcooper => vr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrctrcrd => pr_nrctrcrd,
                         pr_nrcpf    => vr_tab_crapavt(vr_cont_reg).nrcpfcgc);
          FETCH cr_tbaprc INTO rw_tbaprc;
                  
          IF cr_tbaprc%NOTFOUND THEN
            vr_assinou := 'N';          
            CLOSE cr_tbaprc;
          ELSE
            vr_assinou := 'S';
            CLOSE cr_tbaprc;
          END IF;
                
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representantes', pr_posicao => 0, pr_tag_nova => 'representante'    , pr_tag_cont => NULL                                , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'nrcpfcgf', pr_tag_cont => vr_tab_crapavt(vr_cont_reg).nrcpfcgc, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'nome'    , pr_tag_cont => vr_tab_crapavt(vr_cont_reg).nmdavali, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'assinou' , pr_tag_cont => vr_assinou                          , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'idastcjt', pr_tag_cont => rw_crapass.idastcjt                 , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'nrdctato', pr_tag_cont => pr_nrdconta, pr_des_erro => vr_dscritic);
              
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'insitcrd', pr_tag_cont => rw_crawcrd.insitcrd                  , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'inupgrad', pr_tag_cont => rw_crawcrd.inupgrad                  , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'dsprotoc', pr_tag_cont => rw_crawcrd.dsprotoc                  , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'dsjustif', pr_tag_cont => rw_crawcrd.dsjustif                  , pr_des_erro => vr_dscritic);

          vr_contador := vr_contador + 1;
            
        END LOOP;
      ELSE
        -- Buscar dados assinatura
        OPEN cr_tbaprc(pr_cdcooper => vr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_nrctrcrd => pr_nrctrcrd,
                       pr_nrcpf    => rw_crapass.nrcpfcgc);
        FETCH cr_tbaprc INTO rw_tbaprc;
                  
        IF cr_tbaprc%NOTFOUND THEN
          vr_assinou := 'N';          
          CLOSE cr_tbaprc;
        ELSE
          vr_assinou := 'S';
          CLOSE cr_tbaprc;
        END IF;
                
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representantes', pr_posicao => 0, pr_tag_nova => 'representante'    , pr_tag_cont => NULL               , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante' , pr_posicao => vr_contador, pr_tag_nova => 'nrcpfcgf', pr_tag_cont => rw_crapass.nrcpfcgc, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante' , pr_posicao => vr_contador, pr_tag_nova => 'nome'    , pr_tag_cont => rw_crapass.nmprimtl, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante' , pr_posicao => vr_contador, pr_tag_nova => 'assinou' , pr_tag_cont => vr_assinou         , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante' , pr_posicao => vr_contador, pr_tag_nova => 'idastcjt', pr_tag_cont => rw_crapass.idastcjt, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante' , pr_posicao => vr_contador, pr_tag_nova => 'nrdctato', pr_tag_cont => rw_crapass.nrdconta, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante' , pr_posicao => vr_contador, pr_tag_nova => 'insitcrd', pr_tag_cont => rw_crawcrd.insitcrd, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante' , pr_posicao => vr_contador, pr_tag_nova => 'inupgrad', pr_tag_cont => rw_crawcrd.inupgrad, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante' , pr_posicao => vr_contador, pr_tag_nova => 'dsprotoc', pr_tag_cont => rw_crawcrd.dsprotoc, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante' , pr_posicao => vr_contador, pr_tag_nova => 'dsjustif', pr_tag_cont => rw_crawcrd.dsjustif, pr_des_erro => vr_dscritic);
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

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAOCREDITO.pc_busca_ass_repres_proc. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_busca_ass_repres_proc;

  --> Insere Aprovadores de Cartões
  PROCEDURE pc_insere_aprovador_crd( pr_cdcooper      IN tbcrd_aprovacao_cartao.cdcooper%TYPE
                                    ,pr_nrdconta      IN tbcrd_aprovacao_cartao.nrdconta%TYPE
                                    ,pr_nrctrcrd      IN tbcrd_aprovacao_cartao.nrctrcrd%TYPE
                                    ,pr_indtipo_senha IN tbcrd_aprovacao_cartao.indtipo_senha%TYPE
                                    ,pr_dtaprovacao   IN VARCHAR2
                                    ,pr_hraprovacao   IN tbcrd_aprovacao_cartao.hraprovacao%TYPE
                                    ,pr_nrcpf         IN tbcrd_aprovacao_cartao.nrcpf%TYPE
                                    ,pr_nmaprovador   IN tbcrd_aprovacao_cartao.nmaprovador%TYPE
                                    ,pr_cdoperad      IN crapope.cdoperad%TYPE --> Codigo do operador informado
                                    ,pr_xmllog        IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic      OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic      OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml        IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo      OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro      OUT VARCHAR2) IS         --> Erros do processo
                                    
    ------------------------------- CURSORES ---------------------------------
    -- Busca os dados do operador
    CURSOR cr_crapope (pr_cdcooper IN crapope.cdcooper%TYPE,
                       pr_cdoperad IN crapope.cdoperad%TYPE) IS
    SELECT ope.nmoperad
          ,ope.cdoperad
      FROM crapope ope
     WHERE ope.cdcooper = pr_cdcooper
       AND UPPER(ope.cdoperad) = UPPER(pr_cdoperad);
     
    rw_crapope cr_crapope%ROWTYPE;   
  
    CURSOR cr_tbcrd_endereco_entrega(pr_cdcooper crapage.cdcooper%TYPE,
                                     pr_nrdconta crapass.nrdconta%TYPE,
                                     pr_nrctrcrd crapcrd.nrctrcrd%TYPE) IS
    SELECT tbdom.dscodigo || ': ' || tbend.nmlogradouro || ', ' || tbend.nrlogradouro || ' - ' ||
		       nvl2(trim(tbend.dscomplemento), ', ' || tbend.dscomplemento || ' ', '' ) ||
		       tbend.nmbairro || ' - ' || crapmun.dscidade ||' - ' || crapmun.cdestado ||
           ' CEP: ' ||gene0002.fn_mask_cep(tbend.nrcep) as dsendereco
      FROM tbcrd_endereco_entrega tbend
           ,tbcrd_dominio_campo tbdom
           ,crapmun
     WHERE tbend.idtipoenvio = tbdom.cddominio  
	     AND tbdom.nmdominio = 'TPENDERECOENTREGA'
	     AND tbend.cdcooper = pr_cdcooper
	     AND tbend.nrdconta = pr_nrdconta
	     AND tbend.nrctrcrd = pr_nrctrcrd
	     AND crapmun.dscidade = tbend.nmcidade;
	  rw_tbcrd_endereco_entrega cr_tbcrd_endereco_entrega%rowtype;

    ------------------------------- VARIÁVEIS --------------------------------
    
    -- Variaveis de log
    vr_cdcooper NUMBER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
                                    
    vr_nrcpf tbcrd_aprovacao_cartao.nrcpf%TYPE;
    vr_nmaprovador tbcrd_aprovacao_cartao.nmaprovador%TYPE;
    vr_cdaprovador tbcrd_aprovacao_cartao.cdaprovador%TYPE;
    vr_nrdrowid ROWID;
    
    -- Cursor sobre a tabela de datas
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
    
	vr_dsendenv VARCHAR2(400);

  BEGIN 
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PARECC'
                              ,pr_action => null);
    
    /* Extrai os dados */
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Verifica se houve erro                      
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    

    OPEN cr_tbcrd_endereco_entrega(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
					                         pr_nrctrcrd => pr_nrctrcrd);
    FETCH cr_tbcrd_endereco_entrega INTO rw_tbcrd_endereco_entrega;
    CLOSE cr_tbcrd_endereco_entrega;


    IF (pr_indtipo_senha = 4 OR pr_indtipo_senha = 5) THEN
      
      -- Verificar os dados do operador
      OPEN cr_crapope (pr_cdcooper => pr_cdcooper,
                       pr_cdoperad => pr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      -- Se não encontrar registro
      IF cr_crapope%NOTFOUND THEN                     
        -- Fecha o cursor
        CLOSE cr_crapope;
        
        -- Monta critica
        vr_cdcritic := 67;
             
        RAISE vr_exc_saida; 
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapope;
      END IF;
    
      vr_nrcpf := 0;
      vr_nmaprovador := rw_crapope.nmoperad;
      vr_cdaprovador := rw_crapope.cdoperad;
    ELSE
      vr_nrcpf := pr_nrcpf;
      vr_nmaprovador := pr_nmaprovador;
      vr_cdaprovador := '';
    END IF;
    
    
    -- Inserir 
    BEGIN
      INSERT 
        INTO tbcrd_aprovacao_cartao(idaprovacao,
                                    cdcooper,
                                    nrdconta,
                                    nrctrcrd,
                                    indtipo_senha,
                                    dtaprovacao,
                                    hraprovacao,
                                    nrcpf,
                                    nmaprovador,
                                    cdaprovador)
                             VALUES(tbcrd_aprovacao_cartao_seq.nextval,
                                    pr_cdcooper,
                                    pr_nrdconta,
                                    pr_nrctrcrd,
                                    pr_indtipo_senha,
                                    to_date(pr_dtaprovacao,'DD/MM/RRRR'),
                                    pr_hraprovacao,
                                    vr_nrcpf,
                                    vr_nmaprovador,
                                    vr_cdaprovador);
                                    
       COMMIT;
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Aprovador já cadastrado.';
        RAISE vr_exc_saida;
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_insere_aprovador_crd: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
    

	IF TRIM(rw_tbcrd_endereco_entrega.dsendereco) IS NOT NULL THEN
        vr_dsendenv := rw_tbcrd_endereco_entrega.dsendereco;
        
        -- Update
        BEGIN
            UPDATE crawcrd crd
               SET crd.dsendenv = vr_dsendenv
             WHERE crd.cdcooper = pr_cdcooper
               AND crd.nrdconta = pr_nrdconta
               AND crd.nrctrcrd = pr_nrctrcrd;
             
             COMMIT;
             
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar a tabela crawcrd em TELA_ATENDA_CARTAOCREDITO.pc_insere_aprovador_crd: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
    
    END IF;


    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
														,pr_cdoperad => vr_cdoperad
														,pr_dscritic => NULL
														,pr_dsorigem => 'AYLLOS'
														,pr_dstransa => 'Tela Atenda Cartao Credito - TBCRD_APROVACAO_CARTAO: Criado registro de permissao para solicitacao de cartao.'
														,pr_dttransa => TRUNC(SYSDATE)
														,pr_flgtrans => 1
														,pr_hrtransa => gene0002.fn_busca_time
														,pr_idseqttl => 1
														,pr_nmdatela => vr_nmdatela
														,pr_nrdconta => pr_nrdconta
														,pr_nrdrowid => vr_nrdrowid);
                            
		--
		GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
														 ,pr_nmdcampo => 'Operador'
														 ,pr_dsdadant => 0
														 ,pr_dsdadatu => nvl(pr_cdoperad,0));
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
    
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_insere_aprovador_crd: ' || SQLERRM;
      ROLLBACK;
  END pc_insere_aprovador_crd;
  
  --> Busca Aprovadores Cartão
  PROCEDURE pc_busca_aprovadores_crd(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do contrato
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_busca_aprovadores_crd
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 09/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Busca lista de aprovadores do cartão

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Buscar dados assinatura
    CURSOR cr_tbaprc (pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE,
                      pr_nrctrcrd crawcrd.nrctrcrd%TYPE)IS
      SELECT idaprovacao,
             cdcooper,
             nrdconta,
             nrctrcrd,
             indtipo_senha,
             dtaprovacao,
             hraprovacao,
             nrcpf,
             nmaprovador
        FROM tbcrd_aprovacao_cartao
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrcrd = pr_nrctrcrd;
    rw_tbaprc cr_tbaprc%ROWTYPE;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    
  BEGIN
    pr_des_erro := 'OK';
    
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'aprovadores', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Buscar dados assinatura
    FOR rw_tbaprc IN cr_tbaprc(pr_cdcooper => vr_cdcooper,
                               pr_nrdconta => pr_nrdconta,
                               pr_nrctrcrd => pr_nrctrcrd) LOOP      

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovadores', pr_posicao => 0, pr_tag_nova => 'aprovador', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'idaprovacao'  , pr_tag_cont => rw_tbaprc.idaprovacao  , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper'     , pr_tag_cont => rw_tbaprc.cdcooper     , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta'     , pr_tag_cont => rw_tbaprc.nrdconta     , pr_des_erro => vr_dscritic);  
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'nrctrcrd'     , pr_tag_cont => rw_tbaprc.nrctrcrd     , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'indtipo_senha', pr_tag_cont => rw_tbaprc.indtipo_senha, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'dtaprovacao'  , pr_tag_cont => rw_tbaprc.dtaprovacao  , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'hraprovacao'  , pr_tag_cont => rw_tbaprc.hraprovacao  , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'nrcpf'        , pr_tag_cont => rw_tbaprc.nrcpf        , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'nmaprovador'  , pr_tag_cont => rw_tbaprc.nmaprovador  , pr_des_erro => vr_dscritic);
                  
      vr_contador := vr_contador + 1;
          
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

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_busca_aprovadores_crd. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_busca_aprovadores_crd;
  
  --> Atualiza número de contratao para sugestão do motor
  PROCEDURE pc_atualiza_contrato_suges_mot(pr_cdcooper      IN tbgen_webservice_aciona.cdcooper%TYPE
                                          ,pr_nrdconta      IN tbgen_webservice_aciona.nrdconta%TYPE
                                          ,pr_nrctrcrd      IN tbgen_webservice_aciona.nrctrprp%TYPE
                                          ,pr_dsprotoc      IN tbgen_webservice_aciona.dsprotocolo%TYPE
                                          ,pr_dsjustif      IN crawcrd.dsjustif%TYPE
                                          ,pr_idproces      IN VARCHAR2
                                          ,pr_xmllog        IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic      OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic      OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml        IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo      OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro      OUT VARCHAR2) IS         --> Erros do processo

    /* .............................................................................

        Programa: pc_atualiza_contrato_suges_mot
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 09/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Atualiza número de contratao para sugestão do motor

        Observacao: -----

        Alteracoes: 30/07/2018 - Paulo Silva (Supero) - removido supervisor dos parâmetros, dos updates da crawcrd e da geração de log.
    ..............................................................................*/
                                    
    --Verifica se Proposta já possui Justificativa
    CURSOR cr_crawcrd IS
      SELECT dsjustif
            ,vllimcrd
        FROM crawcrd
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrcrd = pr_nrctrcrd;
    rw_crawcrd cr_crawcrd%rowtype;
    
    CURSOR cr_limite(pr_cdcooper tbcrd_limite_atualiza.cdcooper%TYPE
                        ,pr_nrdconta tbcrd_limite_atualiza.nrdconta%TYPE
                        ,pr_nrctrcrd tbcrd_limite_atualiza.nrctrcrd%TYPE) IS
            SELECT nrctrcrd
                  ,tpsituacao
                  ,insitdec
                  ,rno
              FROM (SELECT lim.nrctrcrd
                          ,lim.tpsituacao
                          ,lim.insitdec
                          ,row_number() over(ORDER BY lim.dtalteracao DESC) rno
                      FROM tbcrd_limite_atualiza lim
                     WHERE lim.cdcooper = pr_cdcooper
                       AND lim.nrdconta = pr_nrdconta
                       AND lim.nrctrcrd = pr_nrctrcrd
                     ORDER BY lim.dtalteracao DESC)
             WHERE rownum <= 1;
        rw_limite cr_limite%ROWTYPE;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    vr_insitdec NUMBER(1) := 1; -- sem aprovacao
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    --Gerais
    vr_contador NUMBER := 0;
    vr_tipo     NUMBER := 0;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
                                    
  BEGIN 
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    
    OPEN cr_crawcrd;
    FETCH cr_crawcrd INTO rw_crawcrd;
    CLOSE cr_crawcrd;
	
    OPEN cr_limite(vr_cdcooper, pr_nrdconta, pr_nrctrcrd);
    FETCH cr_limite INTO rw_limite;
    
    vr_tipo := 1; -- novo
    IF cr_limite%FOUND THEN
        -- (1 - Sem aprovação / 6 - Refazer) // -- (6 - Em análise)
        IF rw_limite.insitdec = 6 AND rw_limite.tpsituacao = 6 THEN
            vr_tipo := 2; -- Limite 
        END IF;
    END IF;
    CLOSE cr_limite;
	
	IF pr_idproces = 'S' THEN --Solicitação/Alteração
      -- Atualiza Contrato 
      BEGIN
        UPDATE tbgen_webservice_aciona
           SET nrctrprp = pr_nrctrcrd
         WHERE dsprotocolo = pr_dsprotoc;
         
        UPDATE crawcrd
           SET dsprotoc = pr_dsprotoc
              ,dsjustif = nvl(pr_dsjustif,rw_crawcrd.dsjustif)
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrcrd = pr_nrctrcrd;
                                      
         COMMIT;
         
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_atualiza_contrato_suges_mot: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
    ELSE
      
      este0005.pc_verifica_regras_esteira(pr_cdcooper  => pr_cdcooper,  --> Codigo da cooperativa
                                          ---- OUT ----
                                          pr_cdcritic => vr_cdcritic,   --> Codigo da critica
                                          pr_dscritic => vr_dscritic);  --> Descricao da critica

      vr_insitdec := 1;
      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        vr_insitdec := 2; --- se estiver em contigencia aprova direto
      ELSIF vr_tipo=1 AND rw_crawcrd.vllimcrd=0 THEN 
        vr_insitdec := 2; --- se estiver em contigencia aprova direto
      END IF;

      --Se vai para a esteira então deixa como insitcrd = 1 e insitdec = 1
      IF NVL(pr_dsjustif,rw_crawcrd.dsjustif) IS NOT NULL THEN
        --Se informado 
        -- Atualiza Status
        BEGIN
          UPDATE crawcrd
             SET insitcrd = 1 --Aprovado
                ,insitdec = vr_insitdec
                ,dtmvtolt = SYSDATE
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctrcrd = pr_nrctrcrd;

           COMMIT;

        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_atualiza_contrato_suges_mot: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      ELSE
        --Se informado 
        -- Atualiza Status
        BEGIN
          UPDATE crawcrd
             SET insitcrd = 1 --Aprovado
                ,insitdec = 2 --Aprovado Automaticamente
                ,dtmvtolt = SYSDATE
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctrcrd = pr_nrctrcrd;

           COMMIT;

        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_atualiza_contrato_suges_mot: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;
    END IF;
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'atualizacoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'atualizacoes', pr_posicao => 0, pr_tag_nova => 'atualizacao', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'atualizacao', pr_posicao => vr_contador, pr_tag_nova => 'status'  , pr_tag_cont => 'Atualização realizada com sucesso', pr_des_erro => vr_dscritic);
      
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_atualiza_contrato_suges_mot: ' || SQLERRM;
      ROLLBACK;

  END pc_atualiza_contrato_suges_mot;
  
  --> Busca Aprovadores Cartão
  PROCEDURE pc_possui_senha_aprov_crd(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_possui_senha_aprov_crd
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 09/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Valida se cooperado possui alguma senha de cartão magnético, internet ou cartão de crédito para poder validar na hora da solicitação

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Buscar Senha Cartão Magnético
    CURSOR cr_crapcrm IS
      SELECT 'S'
        FROM crapcrm
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND cdsitcar = 2; --Ativo
    rw_crapcrm cr_crapcrm%ROWTYPE;
  
    -- Busca Senha Internet
    CURSOR cr_crapsnh IS
      SELECT 'S'
        FROM crapsnh
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND tpdsenha = 1 --Internet
         AND cdsitsnh = 1; --Ativo
    rw_crapsnh cr_crapsnh%ROWTYPE;
   
    -- Buscar Senha Cartão de Crédito
    CURSOR cr_crapcrd IS
      SELECT 'S'
        FROM crapcrd
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND dtcancel is null
         AND cdadmcrd between 10 and 80; --Apenas Bancoob
    rw_crapcrd cr_crapcrd%ROWTYPE;
    
	CURSOR cr_crapass IS
      SELECT cdsitdct
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    vr_cdsitdct crapass.cdsitdct%TYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    vr_senha    VARCHAR2(1000);
    
  BEGIN
    pr_des_erro := 'OK';
    
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'senhas', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Verifica se existe senha cartão magnético
    OPEN cr_crapcrm;
    FETCH cr_crapcrm INTO rw_crapcrm;
    -- Se nao encontrar
    IF cr_crapcrm%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcrm;
      
      vr_senha := 'NOK';
      
      -- Montar mensagem de critica
      vr_dscritic := 'Não possui senha para Cartão Magnético.';
    ELSE
      vr_senha := 'OK';
      
      -- Apenas fechar o cursor
      CLOSE cr_crapcrm;
    END IF;
    
    IF vr_senha <> 'OK' THEN
      -- Verifica se existe senha de internet
      OPEN cr_crapsnh;
      FETCH cr_crapsnh INTO rw_crapsnh;
      -- Se nao encontrar
      IF cr_crapsnh%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapsnh;
        
        vr_senha := 'NOK';
        
        -- Montar mensagem de critica
        vr_dscritic := 'Não possui senha de internet.';
      ELSE
        vr_senha := 'OK';
        
        -- Apenas fechar o cursor
        CLOSE cr_crapsnh;
      END IF;
      
      IF vr_senha <> 'OK' THEN
        -- Verifica se existe senha cartão crédito
        OPEN cr_crapcrd;
        FETCH cr_crapcrd INTO rw_crapcrd;
        -- Se nao encontrar
        IF cr_crapcrd%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE cr_crapcrd;
          
          vr_senha := 'NOK';
          
          -- Montar mensagem de critica
          vr_dscritic := 'Não possui senha para Cartão de Crédito.';
        ELSE
          vr_senha := 'OK';
          
          -- Apenas fechar o cursor
          CLOSE cr_crapcrd;
        END IF;
      END IF;
    END IF;
    
	OPEN cr_crapass;
    FETCH cr_crapass INTO vr_cdsitdct;
	CLOSE cr_crapass;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'senhas', pr_posicao => 0, pr_tag_nova => 'senha', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'senha', pr_posicao => vr_contador, pr_tag_nova => 'status'  , pr_tag_cont => vr_senha  , pr_des_erro => vr_dscritic);
	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'senha', pr_posicao => vr_contador, pr_tag_nova => 'cdsitdct'  , pr_tag_cont => vr_cdsitdct  , pr_des_erro => vr_dscritic);
      
  EXCEPTION
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_possui_senha_aprov_crd. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_possui_senha_aprov_crd;
  
  --> Atualiza a justificativa
  PROCEDURE pc_atualiza_just_updown_cartao(pr_cdcooper      IN crawcrd.cdcooper%TYPE
                                          ,pr_nrdconta      IN crawcrd.nrdconta%TYPE
                                          ,pr_nrctrcrd      IN crawcrd.nrctrcrd%TYPE
                                          ,pr_ds_justif     IN crawcrd.dsjustif%TYPE
                                          ,pr_inupgrad      IN crawcrd.inupgrad%TYPE
                                          ,pr_cdadmnov      IN crawcrd.cdadmcrd%TYPE
                                          ,pr_xmllog        IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic      OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic      OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml        IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo      OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro      OUT VARCHAR2) IS         --> Erros do processo
                                    
    /* .............................................................................

        Programa: pc_atualiza_just_updown_cartao
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 09/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Atualiza a justificativa

        Alteracoes: 30/07/2018 - Paulo Silva (Supero) - atualizar insitdec para 2 e 
                    remover a chamada da esteira no Upgrade
    ..............................................................................*/
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    --Geral
    vr_contador NUMBER := 0;
    vr_nrdrowid ROWID;
    vr_dsmensag VARCHAR2(1000);
                                    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Verifica se é titular
    CURSOR cr_crawcrd IS
      select cdadmcrd
            ,flgprcrd
            ,nrcctitg
        FROM crawcrd
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrcrd = pr_nrctrcrd;
    rw_crawcrd cr_crawcrd%ROWTYPE;
    
    CURSOR cr_crawcrd_up(pr_nrcctitg crawcrd.nrcctitg%TYPE,
                         pr_cdadmcrd crawcrd.cdadmcrd%TYPE) IS
      select nrctrcrd
            ,rowid
        FROM crawcrd
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrcctitg = pr_nrcctitg
         AND cdadmcrd = pr_cdadmcrd
         AND insitdec = 1 -- Sem aprovacao
         AND inupgrad = 1 -- Flag upgrade
         AND flgprcrd = 1 -- Cartao titular
    ORDER BY nrctrcrd desc;
    rw_crawcrd_up cr_crawcrd_up%ROWTYPE;

  BEGIN 
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    /* O cartao que esta vindo no parametro na verdade é o original,
      que estah sendo realizado o upgrade / dowgrade */
    OPEN cr_crawcrd;
    FETCH cr_crawcrd INTO rw_crawcrd;
    CLOSE cr_crawcrd;
    
    /* Busca proposta de upgrade/downgrade criada */
    OPEN cr_crawcrd_up(pr_nrcctitg => rw_crawcrd.nrcctitg
                      ,pr_cdadmcrd => pr_cdadmnov);
    FETCH cr_crawcrd_up INTO rw_crawcrd_up;

    IF cr_crawcrd_up%NOTFOUND THEN
      CLOSE cr_crawcrd_up;
      vr_dscritic := 'Nao foi encontrado proposta de upgrade/downgrade';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crawcrd_up;    
    
    IF rw_crawcrd.flgprcrd = 1 AND rw_crawcrd.cdadmcrd < pr_cdadmnov THEN
      -- Atualizar
      BEGIN
        UPDATE CRAWCRD t
        SET    t.dsjustif = pr_ds_justif
              ,t.dtmvtolt = SYSDATE
              ,t.insitdec = 2
        WHERE  t.rowid = rw_crawcrd_up.rowid;

      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_atualiza_just_updown_cartao: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
                                          
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
	ELSE
      -- Atualizar
      BEGIN
        UPDATE CRAWCRD t
        SET    t.dsjustif = pr_ds_justif
              ,t.dtmvtolt = SYSDATE
              ,t.insitdec = 2
        WHERE  t.rowid = rw_crawcrd_up.rowid;

      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_atualiza_just_updown_cartao: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    END IF;

    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                         pr_cdoperad => vr_cdoperad, 
                         pr_dscritic => NULL, 
                         pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem), 
                         pr_dstransa => 'Upgrade/Downgrade de Cartao', 
                         pr_dttransa => trunc(SYSDATE),
                         pr_flgtrans =>  1, -- True
                         pr_hrtransa => gene0002.fn_busca_time, 
                         pr_idseqttl => rw_crawcrd.flgprcrd, 
                         pr_nmdatela => vr_nmdatela, 
                         pr_nrdconta => pr_nrdconta, 
                         pr_nrdrowid => vr_nrdrowid);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'ds_justif', 
                              pr_dsdadant => NULL, 
                              pr_dsdadatu => pr_ds_justif);
                              
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'inupgrad', 
                              pr_dsdadant => NULL, 
                              pr_dsdadatu => pr_inupgrad);
                              
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'cdoperad', 
                              pr_dsdadant => NULL, 
                              pr_dsdadatu => vr_cdoperad);
 
    COMMIT;
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'atualizacoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'atualizacoes', pr_posicao => 0, pr_tag_nova => 'atualizacao', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'atualizacao', pr_posicao => vr_contador, pr_tag_nova => 'status'  , pr_tag_cont => vr_dsmensag, pr_des_erro => vr_dscritic);
      
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
      pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_possui_senha_aprov_crd. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
      ROLLBACK;

  END pc_atualiza_just_updown_cartao;
 
  PROCEDURE pc_verifica_adicionais( pr_nrdconta IN crapass.nrdconta%TYPE
                                    , pr_xmllog IN VARCHAR2              --> XML com informações de LOG
                                    , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    , pr_retxml IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    , pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................

        Programa: pc_verifica_adicionais
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Amasonas Borges Vieira Junior
        Data    : maio/2018                 Ultima atualizacao: 03/05/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Informar se a conta possui cartões adicionais ativos

        Observacao: -----

        Alteracoes:
    ..............................................................................*/

    ---------> CURSORES <--------
    --> Buscar informações da conta 
    CURSOR cr_admin(pr_cdcooper crapass.cdcooper% TYPE ) IS
    SELECT crd.nrcrcard
    FROM
    crawcrd crd
    WHERE
      crd.nrdconta = pr_nrdconta
      AND crd.cdgraupr > 0 
      AND crd.cdcooper = pr_cdcooper
      AND crd.insitcrd = 4 ;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic % TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;

    BEGIN
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
      pr_cdcooper => vr_cdcooper,
      pr_nmdatela => vr_nmdatela,
      pr_nmeacao  => vr_nmeacao,
      pr_cdagenci => vr_cdagenci,
      pr_nrdcaixa => vr_nrdcaixa,
      pr_idorigem => vr_idorigem,
      pr_cdoperad => vr_cdoperad,
      pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
            RAISE vr_exc_saida;
    END IF;

      gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                                 pr_action => vr_nmeacao);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'cartoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_admin IN cr_admin(pr_cdcooper => vr_cdcooper) LOOP

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cartoes', pr_posicao => vr_contador, pr_tag_nova => 'cartao', pr_tag_cont => rw_admin.nrcrcard, pr_des_erro => vr_dscritic);

    END LOOP;

    EXCEPTION
        WHEN vr_exc_saida THEN

    IF vr_cdcritic <> 0
      THEN
          pr_cdcritic := vr_cdcritic;
    pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    ELSE
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
    END IF;

    pr_des_erro := 'NOK';
    -- Carregar XML padrão para variável de retorno não utilizada.
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<? XML version="1.0" encoding="ISO-8859-1" ?> ' ||
    '< ROOT ><Erro>' || pr_dscritic || '</Erro></ ROOT >');
    ROLLBACK;
    WHEN OTHERS THEN

    pr_cdcritic := vr_cdcritic;
    pr_dscritic := 'Erro geral na rotina na PROCEDURE TELA_ATENDA_CARTAO_CREDITO.pc_verifica_adicionais. Erro: ' || SQLERRM;
    pr_des_erro := 'NOK';
    -- Carregar XML padrão para variável de retorno não utilizada.
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<? XML version="1.0" encoding="ISO-8859-1" ?> ' ||
    '< ROOT ><Erro>'' || pr_dscritic || ''</Erro></ ROOT >');
    ROLLBACK;

  END pc_verifica_adicionais;
  
  
  PROCEDURE pc_busca_parametro_pa_cartao(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo do PA
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
/* .............................................................................

        Programa: pc_busca_parametro_pa_cartao
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Anderson Fossa
        Data    : maio/2018                 Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Retornar se a Cooper / PA pode solicitar cartao atraves do novo
                    formato - utilizando os WS Bancoob.

        Observacao: Procedimento temporario. Realizar validacao por PA ou OPERAD.

        Alteracoes:
    ..............................................................................*/
    
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(10000);
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    vr_retorno  PLS_INTEGER;
    vr_param    VARCHAR2(10);
    vr_usa_pilo PLS_INTEGER;
    vr_papiloto PLS_INTEGER;

    BEGIN
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
      
      gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                                 pr_action => vr_nmeacao);
      
      -- Por padrao, nao eh piloto;
      vr_retorno := 0;
      
      -- Verificar se está ativo o parametro de PA piloto.
      vr_param := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_cdacesso => 'BANCOOB_USA_PA_PILOTO');      
      
      vr_usa_pilo := nvl(trim(vr_param),0);
      BEGIN
        vr_usa_pilo := nvl(trim(vr_param),0);
      EXCEPTION
        WHEN OTHERS THEN
          vr_usa_pilo := 0;
      END;
      
      IF vr_usa_pilo = 1 THEN
        
        -- Verificar qual o PA piloto, passando a cooperativa.
        vr_param := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_cdacesso => 'BANCOOB_PILOTO_WS_PA');
        BEGIN
          vr_papiloto := nvl(trim(vr_param),0);
        EXCEPTION
          WHEN OTHERS THEN
            vr_papiloto := 0;
        END;
          
        -- Se for o PA piloto, ativa parametro
        IF (pr_cdagenci = vr_papiloto) and (vr_papiloto > 0) THEN
          vr_retorno := 1;
        END IF;
      ELSE
        --Se não estiver ativo, ok, liberado para todo mundo
        vr_retorno := 1;
      END IF;      

      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'ativo'
                            ,pr_tag_cont => vr_retorno
                            ,pr_des_erro => vr_dscritic);
                                    
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_busca_parametro_pa_cartao: ' || SQLERRM;
        
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    
  END pc_busca_parametro_pa_cartao;
  
  --> Rotina responsavel por gerar a inclusao da proposta para a esteira
  PROCEDURE pc_incluir_proposta_est_wb(pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                      ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE
                                      ,pr_dsiduser  IN VARCHAR2              --> ID sessao do usuario
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2) IS

    /* ..........................................................................
    
      Programa : pc_incluir_proposta_est_wb   
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva (Supero)
      Data     : Maio/2018.                   Ultima atualizacao: 28/11/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a inclusao da proposta para a esteira    
                  
      Alteração : 28/11/2018 - PJ345 Ajustado o nome do arquivo (Rafael Faria - Supero)
                  
    ..........................................................................*/
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_dsmensag VARCHAR2(1000);

  BEGIN    
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);
    
    IF vr_cdagenci = 0 THEN
      vr_cdagenci := 1;
    END IF;

    este0005.pc_incluir_proposta_est(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_cdorigem => vr_idorigem
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrctrcrd => pr_nrctrcrd
                                    ,pr_nmarquiv => pr_dsiduser
                                     ---- OUT ----
                                    ,pr_dsmensag => vr_dsmensag
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
      
    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
    
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => 0,
                           pr_tag_nova => 'mensagem',
                           pr_tag_cont => vr_dsmensag,
                           pr_des_erro => vr_dscritic);
    
    COMMIT;   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');  
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar inclusao da proposta de Análise de Crédito: '||SQLERRM;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');  
  END pc_incluir_proposta_est_wb;                                   
  
  --> Chama rotina para criar proposta de Alteração de Limite
  PROCEDURE pc_altera_limite_crd_wb(pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                   ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE
                                   ,pr_vllimite  IN crawcrd.vllimcrd%TYPE
                                   ,pr_dsprotoc  IN crawcrd.dsprotoc%TYPE
                                   ,pr_dsjustif  IN crawcrd.dsjustif%TYPE
                                   ,pr_flgtplim  IN VARCHAR2
                                   ,pr_tpsituac  IN NUMBER
                                   ,pr_insitdec  IN NUMBER
                                   ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS

    /* ..........................................................................
    
      Programa : pc_altera_limite_crd_wb   
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva (Supero)
      Data     : Maio/2018.                   Ultima atualizacao: 17/05/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Chama rotina para criar proposta de Alteração de Limite
      Alteração : 
                  
    ..........................................................................*/
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
  BEGIN    
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    tela_atenda_cartaocredito.pc_altera_limite_crd(pr_cdcooper => vr_cdcooper
                                                  ,pr_cdoperad => vr_cdoperad
                                                  ,pr_nrdconta => pr_nrdconta
                                                  ,pr_nrctrcrd => pr_nrctrcrd
                                                  ,pr_vllimite => pr_vllimite
                                                  ,pr_dsprotoc => pr_dsprotoc
                                                  ,pr_dsjustif => pr_dsjustif
                                                  ,pr_flgtplim => pr_flgtplim
                                                  ,pr_idorigem => vr_idorigem
                                                  ,pr_tpsituac => pr_tpsituac
                                                  ,pr_insitdec => pr_insitdec
                                                  ,pr_nmdatela => vr_nmdatela
                                                  ---- OUT ----
                                                  ,pr_cdcritic => vr_cdcritic
                                                  ,pr_dscritic => vr_dscritic
                                                  ,pr_des_erro => pr_des_erro);

    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
    
    --Gera retorno para tela
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => 0,
                           pr_tag_nova => 'mensagem',
                           pr_tag_cont => pr_des_erro,
                           pr_des_erro => vr_dscritic);

    COMMIT;   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar inclusao da proposta de Alteração de Limite de Crédito: '||SQLERRM;
  END pc_altera_limite_crd_wb;
  
  --> Chama rotina para criar proposta de Alteração de Limite
  PROCEDURE pc_altera_limite_crd(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                ,pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE
                                ,pr_vllimite  IN crawcrd.vllimcrd%TYPE
                                ,pr_dsprotoc  IN crawcrd.dsprotoc%TYPE
                                ,pr_dsjustif  IN crawcrd.dsjustif%TYPE
                                ,pr_flgtplim  IN VARCHAR2
                                ,pr_idorigem  IN NUMBER
                                ,pr_tpsituac  IN NUMBER
                                ,pr_insitdec  IN NUMBER
                                ,pr_nmdatela  IN craptel.nmdatela%TYPE  --> Nome da Tela
                                ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                ,pr_des_erro  OUT VARCHAR2) IS

    /* ..........................................................................
    
      Programa : pc_altera_limite_crd 
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva (Supero)
      Data     : Maio/2018.                   Ultima atualizacao: 17/05/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Chama rotina para criar proposta de Alteração de Limite
      Alteração : 
                  
    ..........................................................................*/
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    
    --Geral
    vr_nrdrowid  ROWID;
    vr_idseqttl  crapttl.idseqttl%TYPE;
    vr_dtretorno DATE;
    vr_dsorigem  VARCHAR2(100);
    vr_vllimite crawcrd.vllimcrd%TYPE;
    vr_vllimite_ant NUMBER;
    vr_propoest  tbcrd_limite_atualiza.nrproposta_est%TYPE;
    
    -----------> CURSORES <-----------
    --Busca dados da proposta do cartão
    CURSOR cr_crawcrd IS
      SELECT crd.nrcctitg
            ,crd.vllimcrd
            ,crd.cdadmcrd
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrctrcrd = pr_nrctrcrd;
    rw_crawcrd cr_crawcrd%ROWTYPE;
    
    CURSOR cr_limatu IS
      SELECT a.rowid
            ,a.nrproposta_est
            ,a.insitdec
            ,a.dsprotocolo
            ,a.dsjustificativa
            ,a.vllimite_anterior
            ,a.tpsituacao
            ,a.cdoperad
            ,a.dtenvest
            ,a.dtenefes
        FROM tbcrd_limite_atualiza a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.dtalteracao = (SELECT MAX(b.dtalteracao)
                                  FROM tbcrd_limite_atualiza b
                                 WHERE b.cdcooper = pr_cdcooper
                                   AND b.nrdconta = pr_nrdconta);
    rw_limatu cr_limatu%ROWTYPE;
    
    CURSOR cr_vallim IS
      SELECT wrd1.vllimcrd
        FROM crawcrd wrd1
       WHERE wrd1.cdcooper = pr_cdcooper
         AND wrd1.nrdconta = pr_nrdconta
         AND wrd1.insitcrd IN (2,3,4)
         AND wrd1.flgprcrd = 1
         AND wrd1.nrcctitg = (SELECT wrd2.nrcctitg
                                FROM crawcrd wrd2
                               WHERE wrd2.cdcooper = wrd1.cdcooper
                                 AND wrd2.nrdconta = wrd1.nrdconta
                                 AND wrd2.insitcrd IN (2,3,4)
                                 AND wrd2.nrctrcrd = pr_nrctrcrd);
    vr_vllimtit crawcrd.vllimcrd%TYPE;
    
  BEGIN    
    
    pr_des_erro := 'OK';
    
    --Valida se o valor do limite do adicional é menor ou igual o valor do Titular
    IF pr_flgtplim = 'A' THEN
      OPEN cr_vallim;
      FETCH cr_vallim INTO vr_vllimtit;
      CLOSE cr_vallim;
      
      IF pr_vllimite > vr_vllimtit THEN
        vr_dscritic := 'Valor do limite do cartão adicional deve ser menor ou igual ao valor do limite do cartão titular.';
        RAISE vr_exc_erro;
      END IF;
    END IF;
    
    --Busca dados da proposta do cartão
    OPEN cr_crawcrd;
    FETCH cr_crawcrd INTO rw_crawcrd;
    CLOSE cr_crawcrd;
    
    --Busca última atualização
    OPEN cr_limatu;
    FETCH cr_limatu INTO rw_limatu;
    CLOSE cr_limatu;
    
    vr_vllimite_ant := rw_crawcrd.vllimcrd;
    vr_propoest     := rw_limatu.nrproposta_est;
    
    IF pr_tpsituac = 6 THEN
      pc_sequence_progress(pr_nmtabela => 'CRAPMAT'
                          ,pr_nmdcampo => 'NRCTRCRD'
                          ,pr_dsdchave => pr_cdcooper
                          ,pr_sequence => vr_propoest);
    ELSIF pr_tpsituac = 3 THEN
      vr_dtretorno := SYSDATE;
      vr_vllimite_ant := rw_limatu.vllimite_anterior;
    ELSIF pr_tpsituac = 4 THEN
      vr_vllimite := rw_crawcrd.vllimcrd;
    END IF;
    
    IF pr_flgtplim = 'G' THEN
      vr_idseqttl := 1;
    ELSE
      vr_idseqttl := 0;
    END IF;

    --Insere registro de Alteração de Limite
    BEGIN
      INSERT INTO tbcrd_limite_atualiza(cdcooper
                                       ,nrdconta
                                       ,nrconta_cartao
                                       ,dtalteracao
                                       ,dtretorno
                                       ,tpsituacao
                                       ,vllimite_anterior
                                       ,vllimite_alterado
                                       ,cdcanal
                                       ,cdadmcrd
                                       ,cdoperad
                                       ,insitdec
                                       ,dsprotocolo
                                       ,dsjustificativa
                                       ,nrctrcrd
                                       ,nrproposta_est
                                       ,dtenvest
                                       ,dtenefes)
                                 VALUES(pr_cdcooper
                                       ,pr_nrdconta
                                       ,rw_crawcrd.nrcctitg
                                       ,SYSDATE
                                       ,vr_dtretorno
                                       ,pr_tpsituac
                                       ,vr_vllimite_ant
                                       ,nvl(pr_vllimite,vr_vllimite)
                                       ,pr_idorigem --Ayllos
                                       ,rw_crawcrd.cdadmcrd
                                       ,pr_cdoperad
                                       ,nvl(pr_insitdec,rw_limatu.insitdec)
                                       ,nvl(pr_dsprotoc,rw_limatu.dsprotocolo)
                                       ,nvl(pr_dsjustif,rw_limatu.dsjustificativa)
                                       ,pr_nrctrcrd
                                       ,vr_propoest
                                       ,rw_limatu.dtenvest
                                       ,rw_limatu.dtenefes);
    EXCEPTION
      WHEN dup_val_on_index THEN
        vr_dscritic := 'Proposta de Alteração de Limite já existente para essas condições.';
        RAISE vr_exc_erro;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir Proposta de Alteração de Limite. Erro: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    IF pr_idorigem = 15 THEN
      vr_dsorigem := 'BANCOOB';
    ELSE
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    END IF;
    
    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                         pr_cdoperad => pr_cdoperad, 
                         pr_dscritic => NULL, 
                         pr_dsorigem => vr_dsorigem, 
                         pr_dstransa => 'Alteracao Limite Cartao', 
                         pr_dttransa => trunc(SYSDATE),
                         pr_flgtrans =>  1, -- True
                         pr_hrtransa => gene0002.fn_busca_time, 
                         pr_idseqttl => vr_idseqttl, 
                         pr_nmdatela => pr_nmdatela, 
                         pr_nrdconta => pr_nrdconta, 
                         pr_nrdrowid => vr_nrdrowid);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'tpsituacao', 
                              pr_dsdadant => rw_limatu.tpsituacao,
                              pr_dsdadatu => pr_tpsituac);
                              
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'cdoperad', 
                              pr_dsdadant => rw_limatu.cdoperad, 
                              pr_dsdadatu => pr_cdoperad);
                              
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                              pr_nmdcampo => 'insitdec', 
                              pr_dsdadant => rw_limatu.insitdec,
                              pr_dsdadatu => pr_insitdec);
    
    COMMIT;   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar inclusao da proposta de Alteração de Limite de Crédito: '||SQLERRM;
      pr_des_erro := 'NOK';
  END pc_altera_limite_crd;
  
  --Valida se possui cartões com valores diferenciados
  PROCEDURE pc_valida_limite_diferenciado(pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr. da Conta
                                         ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do Cartão
                                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_valida_limite_diferenciado
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 06/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Validar se o operador que solicitou o cartão é o mesmo que está entregando

        Observacao: -----

        Alteracoes:
    ..............................................................................*/

    ---------> CURSORES <--------
    --> Valida se o operador é o titular da conta
    CURSOR cr_crawcrd (pr_cdcooper IN crawcrd.cdcooper%TYPE) IS
      SELECT 'S'
        FROM crawcrd wrd1
       WHERE wrd1.cdcooper = pr_cdcooper
         AND wrd1.nrdconta = pr_nrdconta
         AND wrd1.insitcrd IN (2,3,4)
         AND wrd1.vllimcrd <> (SELECT DISTINCT wrd2.vllimcrd
                                FROM crawcrd wrd2
                               WHERE wrd2.cdcooper = 1--wrd1.cdcooper
                                 AND wrd2.nrdconta = wrd1.nrdconta
                                 AND wrd2.insitcrd IN (2,3,4)
                                 AND wrd2.nrcctitg = wrd1.nrcctitg
                                 AND wrd2.nrctrcrd = pr_nrctrcrd
                                 AND wrd2.flgprcrd = 1);
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Geral
    vr_contador    NUMBER := 0;
    vr_limitedifer VARCHAR2(1);

  BEGIN

    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);
    
    OPEN cr_crawcrd(pr_cdcooper => vr_cdcooper);
    FETCH cr_crawcrd INTO vr_limitedifer;
    IF cr_crawcrd%NOTFOUND THEN
      vr_limitedifer := 'N';
    END IF;
    CLOSE cr_crawcrd;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'limiteDifer', pr_tag_cont => vr_limitedifer, pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_valida_limite_diferenciado. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_valida_limite_diferenciado;
  
  --Rotina para validar se é titular da conta
  PROCEDURE pc_valida_eh_titular(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do Cartão
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_valida_eh_titular
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Maio/2018                 Ultima atualizacao: 22/05/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Validar se eh o titular da conta

        Observacao: -----

        Alteracoes:
    ..............................................................................*/

    ---------> CURSORES <--------
    --Verifica se é titular
    CURSOR cr_crawcrd(pr_cdcooper crawcrd.cdcooper%TYPE) IS
      select flgprcrd
            ,vllimcrd
            ,nrcctitg
        FROM crawcrd
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrcrd = pr_nrctrcrd;
    rw_crawcrd cr_crawcrd%ROWTYPE;
    
    CURSOR cr_crawcrd_tit(pr_cdcooper crawcrd.cdcooper%TYPE
                         ,pr_nrdconta crawcrd.nrdconta%TYPE
                         ,pr_nrcctitg crawcrd.nrcctitg%TYPE) IS
      SELECT crd.vllimcrd
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrcctitg = pr_nrcctitg
         AND crd.insitcrd = 4
         AND crd.flgprcrd = 1;
    rw_crawcrd_tit cr_crawcrd_tit%ROWTYPE;
    
    vr_ehtitular VARCHAR2(1) := 'N';

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;

  BEGIN

    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    /* Busca dados do cartao */
    OPEN cr_crawcrd(pr_cdcooper => vr_cdcooper);
    FETCH cr_crawcrd INTO rw_crawcrd;
    CLOSE cr_crawcrd;
    
    /* eh titular */
    IF rw_crawcrd.flgprcrd = 1 THEN
      vr_ehtitular := 'S';
    ELSE 
      vr_ehtitular := 'N';
    END IF;
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'contas', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => 0, pr_tag_nova => 'conta', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'titular', pr_tag_cont => NVL(vr_ehtitular,'N'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'limiteatual', pr_tag_cont => rw_crawcrd.vllimcrd, pr_des_erro => vr_dscritic);

    IF (vr_ehtitular = 'N') THEN
      /* Busca cartao titular */
      OPEN cr_crawcrd_tit(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrcctitg => rw_crawcrd.nrcctitg);
      FETCH cr_crawcrd_tit INTO rw_crawcrd_tit;
      IF cr_crawcrd_tit%FOUND THEN
         CLOSE cr_crawcrd_tit;
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'limitetitular', pr_tag_cont => rw_crawcrd_tit.vllimcrd, pr_des_erro => vr_dscritic);
      ELSE 
         CLOSE cr_crawcrd_tit;
      END IF;
      
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
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_valida_eh_titular. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_valida_eh_titular;
  
  --Rotina para verificar os cartões que o cooperado já possui
  PROCEDURE pc_verifica_cartoes(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
                               
    /* .............................................................................

        Programa: pc_verifica_cartoes
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Maio/2018                 Ultima atualizacao: 23/05/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Verificar os cartões que o cooperado já possui

        Observacao: -----

        Alteracoes:
    ..............................................................................*/

    ---------> CURSORES <--------
    --Verifica se é titular
    CURSOR cr_crawcrd(pr_cdcooper crawcrd.cdcooper%TYPE) IS
      select cdadmcrd
            ,flgprcrd
            ,nrctrcrd
            ,vllimcrd
            ,dddebito
            ,tpdpagto
            ,dsprotoc
            ,flgdebit
            ,nmempcrd
        FROM crawcrd
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND insitcrd <> 6 --Náo está cancelado
         AND cdadmcrd BETWEEN 10 and 80; --CECRED
    rw_crawcrd cr_crawcrd%ROWTYPE;
    
    CURSOR cr_crapass(pr_cdcooper crawcrd.cdcooper%TYPE) IS
      SELECT idastcjt
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    vr_idastcjt crapass.idastcjt%TYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Gerais
    vr_contador NUMBER := 0;
    vr_debitoti crawcrd.cdadmcrd%TYPE;
    vr_debitoad crawcrd.cdadmcrd%TYPE;
    vr_multesti crawcrd.cdadmcrd%TYPE;
    vr_multesad crawcrd.cdadmcrd%TYPE;
    vr_multmati crawcrd.cdadmcrd%TYPE;
    vr_multmaad crawcrd.cdadmcrd%TYPE;
    vr_nrctrdeb crawcrd.nrctrcrd%TYPE;
    vr_nrctress crawcrd.nrctrcrd%TYPE;
    vr_nrctrmul crawcrd.nrctrcrd%TYPE;
    vr_vllimdeb crawcrd.vllimcrd%TYPE;
    vr_vllimess crawcrd.vllimcrd%TYPE;
    vr_vllimmul crawcrd.vllimcrd%TYPE;
    vr_ddebideb crawcrd.vllimcrd%TYPE;
    vr_ddebiess crawcrd.vllimcrd%TYPE;
    vr_ddebimul crawcrd.vllimcrd%TYPE;
    vr_tppagdeb crawcrd.tpdpagto%TYPE;
    vr_tppagess crawcrd.tpdpagto%TYPE;
    vr_tppagmul crawcrd.tpdpagto%TYPE;
    vr_flgdebit crawcrd.flgdebit%TYPE;
    vr_nmempdeb crawcrd.nmempcrd%TYPE;
    vr_nmempess crawcrd.nmempcrd%TYPE;
    vr_nmempmul crawcrd.nmempcrd%TYPE;

  BEGIN

    pr_des_erro := 'OK';
    
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);
    
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper);
    FETCH cr_crapass INTO vr_idastcjt;
    CLOSE cr_crapass;

    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'Dados'
                          ,pr_posicao => 0
                          ,pr_tag_nova => 'cartoes'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
    
    FOR rw_crawcrd IN cr_crawcrd(pr_cdcooper => vr_cdcooper) LOOP
    
      --Se Cartão Débito
      IF rw_crawcrd.cdadmcrd IN (16,17) THEN
        IF rw_crawcrd.flgprcrd = 1 THEN
          vr_debitoti := rw_crawcrd.cdadmcrd;
          vr_nrctrdeb := rw_crawcrd.nrctrcrd;
          vr_vllimdeb := rw_crawcrd.vllimcrd;
          vr_ddebideb := rw_crawcrd.dddebito;
          vr_tppagdeb := rw_crawcrd.tpdpagto;
          vr_nmempdeb := rw_crawcrd.nmempcrd;
        ELSE
          vr_debitoad := rw_crawcrd.cdadmcrd;
        END IF;
      --Se Essencial
      ELSIF rw_crawcrd.cdadmcrd = 11 THEN
        IF rw_crawcrd.flgprcrd = 1 THEN
          vr_multesti := rw_crawcrd.cdadmcrd;
          vr_nrctress := rw_crawcrd.nrctrcrd;
          vr_vllimess := rw_crawcrd.vllimcrd;
          vr_ddebiess := rw_crawcrd.dddebito;
          vr_tppagess := rw_crawcrd.tpdpagto;
          vr_nmempess := rw_crawcrd.nmempcrd;
        ELSE
          vr_multesad := rw_crawcrd.cdadmcrd;
        END IF;
      --Se demais
      ELSE
        IF rw_crawcrd.flgprcrd = 1 THEN
          vr_multmati := rw_crawcrd.cdadmcrd;
          vr_nrctrmul := rw_crawcrd.nrctrcrd;
          vr_vllimmul := rw_crawcrd.vllimcrd;
          vr_ddebimul := rw_crawcrd.dddebito;
          vr_tppagmul := rw_crawcrd.tpdpagto;
          vr_flgdebit := rw_crawcrd.flgdebit;
          vr_nmempmul := rw_crawcrd.nmempcrd;
        ELSE
          vr_multmaad := rw_crawcrd.cdadmcrd;
        END IF;
      END IF;
                            
    END LOOP;
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartoes'
                          ,pr_posicao => 0
                          ,pr_tag_nova => 'cartao'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);
                              
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'debito_tit'
                          ,pr_tag_cont => vr_debitoti
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'debito_adi'
                          ,pr_tag_cont => vr_debitoad
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'nrctrdeb'
                          ,pr_tag_cont => vr_nrctrdeb
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'vllimdeb'
                          ,pr_tag_cont => vr_vllimdeb
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'ddebideb'
                          ,pr_tag_cont => vr_ddebideb
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'tppagtodeb'
                          ,pr_tag_cont => vr_tppagdeb
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'nmempdeb'
                          ,pr_tag_cont => vr_nmempdeb
                          ,pr_des_erro => vr_dscritic);
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'multesseti'
                          ,pr_tag_cont => vr_multesti
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'multessead'
                          ,pr_tag_cont => vr_multesad
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'nrctress'
                          ,pr_tag_cont => vr_nrctress
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'vllimess'
                          ,pr_tag_cont => vr_vllimess
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'ddebiess'
                          ,pr_tag_cont => vr_ddebiess
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'nmempess'
                          ,pr_tag_cont => vr_nmempess
                          ,pr_des_erro => vr_dscritic);
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'tppagtoess'
                          ,pr_tag_cont => vr_tppagess
                          ,pr_des_erro => vr_dscritic);
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'multmastti'
                          ,pr_tag_cont => vr_multmati
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'multmastad'
                          ,pr_tag_cont => vr_multmaad
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'nrctrmul'
                          ,pr_tag_cont => vr_nrctrmul
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'vllimmul'
                          ,pr_tag_cont => vr_vllimmul
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'ddebimul'
                          ,pr_tag_cont => vr_ddebimul
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'tppagtomul'
                          ,pr_tag_cont => vr_tppagmul
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'nmempmul'
                          ,pr_tag_cont => vr_nmempmul
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'protocolo'
                          ,pr_tag_cont => rw_crawcrd.dsprotoc
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'idastcjt'
                          ,pr_tag_cont => vr_idastcjt
                          ,pr_des_erro => vr_dscritic);
                          
    gene0007.pc_insere_tag(pr_xml => pr_retxml
                          ,pr_tag_pai => 'cartao'
                          ,pr_posicao => vr_contador
                          ,pr_tag_nova => 'flgdebit'
                          ,pr_tag_cont => vr_flgdebit
                          ,pr_des_erro => vr_dscritic);
                          
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
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_verifica_cartoes. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_verifica_cartoes;
  
  --> Rotina responsavel por verificar se existe Aleração de Limite Pendente de Aprovação na Esteira
  PROCEDURE pc_valida_alt_pend_esteira(pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                      ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2) IS

    /* ..........................................................................

      Programa : pc_valida_alt_pend_esteira
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva (Supero)
      Data     : Maio/2018.                   Ultima atualizacao: 05/05/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por verificar se existe Aleração de Limite Pendente de Aprovação na Esteira
      Alteração :

    ..........................................................................*/

    -----------> CURSORES  <-----------
    CURSOR cr_crawcrd (pr_cdcooper crawcrd.cdcooper%TYPE) IS
      SELECT *
        FROM tbcrd_limite_atualiza lim
       WHERE lim.cdcooper = pr_cdcooper
         AND lim.nrdconta = pr_nrdconta
         AND lim.nrctrcrd = pr_nrctrcrd
         AND lim.tpsituacao = 6 --Em Análise
         AND lim.insitdec in (1,6)   --Sem Aprovação, Refazer
         AND lim.dtalteracao = (SELECT MAX(atu.dtalteracao)
                                    FROM tbcrd_limite_atualiza atu
                                   WHERE atu.cdcooper = lim.cdcooper
                                     AND atu.nrdconta = lim.nrdconta
                                     AND atu.nrconta_cartao = lim.nrconta_cartao);
    rw_crawcrd cr_crawcrd%ROWTYPE;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

  BEGIN

    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);
    
    OPEN cr_crawcrd (vr_cdcooper);
    FETCH cr_crawcrd INTO rw_crawcrd;
    CLOSE cr_crawcrd;

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => 0,
                           pr_tag_nova => 'proposta',
                           pr_tag_cont => rw_crawcrd.nrproposta_est,
                           pr_des_erro => vr_dscritic);

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN

      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');  

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel validar a existência de proposta pendente de aprovacao na esteira: '||SQLERRM;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');  
  END pc_valida_alt_pend_esteira;
  
  --> Rotina responsavel por Cancelar a Proposta do Cartão
  PROCEDURE pc_cancela_proposta_crd(pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                   ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE
                                   ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS

    /* ..........................................................................

      Programa : pc_cancela_proposta_crd
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva (Supero)
      Data     : Maio/2018.                   Ultima atualizacao: 25/07/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por Cancelar a Proposta do Cartão
      Alteração : Adicao de controle para apagar o campo de flgprcrd caso cancele
                  a proposta, pois como nao foi para o Bancoob, o proximo cartao
                  que devera ser setado como primeiro cartao (Anderson 25/07/18)
                  
            14/09/2018 - Gravar data de cancelamento da solicitação do cartão (Renato - Supero)

			24/05/2019 - Gerar log de cancelamento de proposta.
			             Alcemir Jr. (PRB0041672).

    ..........................................................................*/

		
		CURSOR cr_primeiro_cartao_ativo(pr_cdcooper crawcrd.cdcooper%TYPE
		                               ,pr_nrdconta crawcrd.nrdconta%TYPE
										               ,pr_cdadmcrd crawcrd.cdadmcrd%TYPE) IS
			SELECT d.nrctrcrd
			      ,d.flgprcrd
			  FROM crawcrd d
			 WHERE d.cdcooper = pr_cdcooper
			   AND d.nrdconta = pr_nrdconta
				 AND d.cdadmcrd = pr_cdadmcrd
				 AND d.insitcrd NOT IN (5,6) -- bloqueado,cancelado
  	ORDER BY d.dtpropos ASC;
		rw_primeiro_cartao_ativo cr_primeiro_cartao_ativo%ROWTYPE;
		
		CURSOR cr_eh_titular(pr_cdcooper crawcrd.cdcooper%TYPE
		                    ,pr_nrdconta crawcrd.nrdconta%TYPE
										    ,pr_nrctrcrd crawcrd.nrctrcrd%TYPE) IS
			SELECT d.flgprcrd
			  FROM crawcrd d
			 WHERE d.cdcooper = pr_cdcooper
			   AND d.nrdconta = pr_nrdconta
				 AND d.nrctrcrd = pr_nrctrcrd;
		rw_eh_titular cr_eh_titular%ROWTYPE;
		
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
	vr_rowid  rowid;
		-- Variaveis internas
		vr_cdadmcrd crawcrd.cdadmcrd%TYPE;

  BEGIN

    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);
    --
		OPEN cr_eh_titular(pr_cdcooper => vr_cdcooper,
											 pr_nrdconta => pr_nrdconta,
											 pr_nrctrcrd => pr_nrctrcrd);
	  FETCH cr_eh_titular INTO rw_eh_titular;
		--
		IF cr_eh_titular%NOTFOUND THEN
			CLOSE cr_eh_titular;
			vr_dscritic := 'Proposta invalida.';
			RAISE vr_exc_erro;			
		END IF;
		--
		CLOSE cr_eh_titular;
    
    BEGIN
      UPDATE crawcrd
         SET insitcrd = 6 --Cancelado
            ,flgprcrd = 0 --Nao eh mais o primeiro cartao
            ,dtcancel = TRUNC(SYSDATE) -- Setar a data de cancelamento
       WHERE cdcooper = vr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrcrd = pr_nrctrcrd
 	 RETURNING cdadmcrd INTO vr_cdadmcrd;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao cancelar proposta. Erro: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => 'AIMARO WEB'
                        ,pr_dstransa => 'Cancelamento proposta de Cartão de crédito. Contrato :' || pr_nrctrcrd
                        ,pr_dttransa => trunc(SYSDATE)
                        ,pr_flgtrans => 0
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA_CRD'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_rowid);  


		-- Se o cartao recem cancelado era titular, devemos repassar a titularidade
		IF rw_eh_titular.flgprcrd = 1 THEN		
			OPEN cr_primeiro_cartao_ativo(pr_cdcooper => vr_cdcooper,
																		pr_nrdconta => pr_nrdconta,
																		pr_cdadmcrd => vr_cdadmcrd);
			FETCH cr_primeiro_cartao_ativo INTO rw_primeiro_cartao_ativo;
			--
			IF cr_primeiro_cartao_ativo%FOUND THEN
				 --
				 BEGIN
					 UPDATE crawcrd d
							SET d.flgprcrd = 1
						WHERE d.cdcooper = vr_cdcooper
							AND d.nrdconta = pr_nrdconta
							AND d.nrctrcrd = rw_primeiro_cartao_ativo.nrctrcrd;
				 EXCEPTION
				 WHEN OTHERS THEN
					  CLOSE cr_primeiro_cartao_ativo;
						vr_dscritic := 'Erro ao vincular novo titular. Erro: '||SQLERRM;
						RAISE vr_exc_erro;
				 END;

				 gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                                          ,pr_nmdcampo => 'nrctrcrd'
                                          ,pr_dsdadant => pr_nrctrcrd
                                          ,pr_dsdadatu => rw_primeiro_cartao_ativo.nrctrcrd); 
                                                                    
                 gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid
                                          ,pr_nmdcampo => 'flgprcrd'
                                          ,pr_dsdadant => rw_primeiro_cartao_ativo.flgprcrd
                                          ,pr_dsdadatu => 1); 


			END IF;
		   
			--
			CLOSE cr_primeiro_cartao_ativo;
		END IF;

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => 0,
                           pr_tag_nova => 'mensagem',
                           pr_tag_cont => 'Cancelamento realizado com sucesso',
                           pr_des_erro => vr_dscritic);

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN

      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');  

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Nao foi possivel a cancelar proposta: '||SQLERRM;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');  
  END pc_cancela_proposta_crd;

    --Rotina para verificar o tipo de proposta (1 - Cartão / 2 - Limite)
    PROCEDURE pc_verifica_tipo_proposta(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                       ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do Cartão
                                       ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS
        --> Erros do processo
        /* .............................................................................
        
            Programa: pc_verifica_tipo_proposta
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Augusto (Supero)
            Data    : Setembro/2018                 Ultima atualizacao: 12/09/2018
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo  : Verificar o tipo de proposta
        
            Observacao: -----
        
            Alteracoes:
        ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;
        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
			vr_exc_erro EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis internas
        vr_tipo INTEGER;

        -- Iremos retornar a última proposta de alteração de limite
				-- A necessidade de ordenar por data é devido ao não ordenamento por identificador
        CURSOR cr_limite(pr_cdcooper tbcrd_limite_atualiza.cdcooper%TYPE
                        ,pr_nrdconta tbcrd_limite_atualiza.nrdconta%TYPE
                        ,pr_nrctrcrd tbcrd_limite_atualiza.nrctrcrd%TYPE) IS
            SELECT nrctrcrd
                  ,tpsituacao
                  ,insitdec
                  ,rno
              FROM (SELECT lim.nrctrcrd
                          ,lim.tpsituacao
                          ,lim.insitdec
                          ,row_number() over(ORDER BY lim.dtalteracao DESC) rno
                      FROM tbcrd_limite_atualiza lim
                     WHERE lim.cdcooper = pr_cdcooper
                       AND lim.nrdconta = pr_nrdconta
                       AND lim.nrctrcrd = pr_nrctrcrd
                     ORDER BY lim.dtalteracao DESC)
             WHERE rownum <= 1;
        rw_limite cr_limite%ROWTYPE;
    
        CURSOR cr_proposta(pr_cdcooper crawcrd.cdcooper%TYPE
                          ,pr_nrdconta crawcrd.nrdconta%TYPE
                          ,pr_nrctrcrd crawcrd.nrctrcrd%TYPE) IS
            SELECT w.nrctrcrd
								,w.flgprcrd
								,w.insitdec
              FROM crawcrd w
             WHERE w.nrdconta = pr_nrdconta
               AND w.cdcooper = pr_cdcooper
               AND w.nrctrcrd = pr_nrctrcrd
						 AND w.insitcrd = 0; -- Em Estudo
        rw_proposta cr_proposta%ROWTYPE;
    
    BEGIN
    
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela, pr_action => vr_nmeacao);
    
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
					RAISE vr_exc_erro;
        END IF;
    
        OPEN cr_limite(vr_cdcooper, pr_nrdconta, pr_nrctrcrd);
        FETCH cr_limite
            INTO rw_limite;
    
        vr_tipo := 0; -- Indisponível
        IF cr_limite%FOUND THEN
            -- (1 - Sem aprovação / 6 - Refazer) // -- (6 - Em análise)
            IF rw_limite.insitdec = 6 AND rw_limite.tpsituacao = 6 THEN
					CLOSE cr_limite;
                vr_tipo := 2; -- Limite 
					RAISE vr_exc_saida;
            END IF;
			END IF;
			CLOSE cr_limite;
				
            OPEN cr_proposta(vr_cdcooper, pr_nrdconta, pr_nrctrcrd);
            FETCH cr_proposta
                INTO rw_proposta;
        
            IF cr_proposta%FOUND THEN
				IF rw_proposta.flgprcrd <> 1 THEN -- Titular
					vr_cdcritic := 0;
					vr_dscritic := 'Edicao de proposta nao permitida, somente para cartao titular.';
					CLOSE cr_proposta;
					RAISE vr_exc_erro;
				END IF;
				--
				IF rw_proposta.insitdec NOT IN (4,5,6) THEN -- 4 - Erro / 5 - Rejeitada / 6 - Refazer
					vr_cdcritic := 0;
					vr_dscritic := 'Edicao de proposta nao permitida, somente para propostas com retorno da esteira.';
					CLOSE cr_proposta;
					RAISE vr_exc_erro;
				END IF;

                vr_tipo := 1; -- Cartão
				RAISE vr_exc_saida;
        
			ELSE
				vr_cdcritic := 0;
				vr_dscritic := 'Edicao de proposta nao permitida, somente para situacao em estudo.';
            CLOSE cr_proposta;
				RAISE vr_exc_erro;
        END IF;
			--
	EXCEPTION
			WHEN vr_exc_saida THEN
				pr_cdcritic := 0;
				pr_dscritic := '';
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados><TipoProposta>' || vr_tipo ||
                                       '</TipoProposta></Dados></Root>');
			WHEN vr_exc_erro THEN
        
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_verifica_tipo_proposta. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        
    END pc_verifica_tipo_proposta;

  --> Chama rotina para criar proposta de Alteração de Limite
  PROCEDURE pc_atualiza_limite_crd(pr_cdcooper     IN tbcrd_limite_atualiza.cdcooper%TYPE
                                  ,pr_nrdconta     IN tbcrd_limite_atualiza.nrdconta%TYPE
                                  ,pr_nrctrcrd     IN tbcrd_limite_atualiza.nrctrcrd%TYPE
                                  ,pr_insitdec     IN tbcrd_limite_atualiza.insitdec%TYPE
                                  ,pr_tpsituacao   IN tbcrd_limite_atualiza.tpsituacao%TYPE
                                  ,pr_vllimite_anterior IN tbcrd_limite_atualiza.vllimite_anterior%TYPE
                                  ,pr_vllimite_alterado IN tbcrd_limite_atualiza.vllimite_alterado%TYPE
                                  ,pr_cdoperad          IN tbcrd_limite_atualiza.cdoperad%TYPE
                                  ,pr_dsjustificativa   IN tbcrd_limite_atualiza.dsjustificativa%TYPE
                                  ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2 ) IS             --> Descrição da crítica

    /* ..........................................................................
    
      Programa : pc_atualiza_limite_crd 
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Rafael Faria (Supero)
      Data     : Setembro/2018.                   Ultima atualizacao:
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Chama rotina para criar proposta de Alteração de Limite
      Alteração : 
                  
    ..........................................................................*/
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    
    --Geral
    vr_nrdrowid  ROWID;
    vr_idseqttl  crapttl.idseqttl%TYPE;
    vr_dtretorno DATE;
    vr_dsorigem  VARCHAR2(100);
    vr_vllimite crawcrd.vllimcrd%TYPE;
    vr_vllimite_ant NUMBER;
    vr_propoest  tbcrd_limite_atualiza.nrproposta_est%TYPE;
    
    -----------> CURSORES <-----------
    --Busca dados da proposta do cartão
    CURSOR cr_crawcrd IS
      SELECT crd.nrcctitg
            ,crd.vllimcrd
            ,crd.cdadmcrd
            ,crd.flgprcrd
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrctrcrd = pr_nrctrcrd;
    rw_crawcrd cr_crawcrd%ROWTYPE;
    
    CURSOR cr_limatu IS
      SELECT a.rowid
            ,a.nrproposta_est
            ,a.insitdec
            ,a.dsprotocolo
            ,a.dsjustificativa
            ,a.vllimite_anterior
            ,a.tpsituacao
            ,a.cdoperad
        FROM tbcrd_limite_atualiza a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.nrctrcrd = pr_nrctrcrd
         AND a.dtalteracao = (SELECT MAX(b.dtalteracao)
                                  FROM tbcrd_limite_atualiza b
                               WHERE b.cdcooper = a.cdcooper
                                 AND b.nrdconta = a.nrdconta
                                 AND b.nrctrcrd = a.nrctrcrd);
    rw_limatu cr_limatu%ROWTYPE;
    
  BEGIN    
    
    --Busca dados da proposta do cartão
    OPEN cr_crawcrd;
    FETCH cr_crawcrd INTO rw_crawcrd;
    
    IF cr_crawcrd%NOTFOUND THEN
      vr_dscritic := 'Proposta nao encontrada';
      RAISE vr_exc_erro;
    END IF;    
    CLOSE cr_crawcrd;
    
    --Busca última atualização
    OPEN cr_limatu;
    FETCH cr_limatu INTO rw_limatu;

    IF cr_limatu%NOTFOUND THEN
      vr_dscritic := 'Proposta de limite nao encontrada';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_limatu;

    --Insere registro de Alteração de Limite
    BEGIN
      update tbcrd_limite_atualiza a
         set dtalteracao        = sysdate
            ,tpsituacao         = pr_tpsituacao
            ,vllimite_anterior  = pr_vllimite_anterior
            ,vllimite_alterado  = pr_vllimite_alterado
            ,cdoperad           = pr_cdoperad
            ,insitdec           = pr_insitdec
            ,dsjustificativa    = pr_dsjustificativa
       where a.rowid = rw_limatu.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar Proposta de Alteração de Limite. Erro: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    COMMIT;   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar atualizacao da proposta de Alteração de Limite de Crédito: '||SQLERRM;
  END pc_atualiza_limite_crd;

  PROCEDURE pc_atualiza_limite_crd_web(pr_cdcooper     IN tbcrd_limite_atualiza.cdcooper%TYPE
                                      ,pr_nrdconta     IN tbcrd_limite_atualiza.nrdconta%TYPE
                                      ,pr_nrctrcrd     IN tbcrd_limite_atualiza.nrctrcrd%TYPE
                                      ,pr_insitdec     IN tbcrd_limite_atualiza.insitdec%TYPE
                                      ,pr_tpsituacao   IN tbcrd_limite_atualiza.tpsituacao%TYPE
                                      ,pr_vllimite_anterior IN tbcrd_limite_atualiza.vllimite_anterior%TYPE
                                      ,pr_vllimite_alterado IN tbcrd_limite_atualiza.vllimite_alterado%TYPE
                                      ,pr_dsjustificativa   IN tbcrd_limite_atualiza.dsjustificativa%TYPE
                                      ,pr_dsiduser  IN VARCHAR2              --> ID sessao do usuario
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2) IS

    /* ..........................................................................
    
      Programa : pc_atualiza_limite_crd_web   
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Rafael Faria (Supero)
      Data     : Setembro/2018.                   Ultima atualizacao: 28/11/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Chama rotina para criar proposta de Alteração de Limite
                  
      Alteração : 28/11/2018 - PJ345 Ajustado o nome do arquivo (Rafael Faria - Supero)
                  
    ..........................................................................*/
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    vr_dsmensag VARCHAR2(4000);
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_flreiflx NUMBER(1):= 1; --> Indica se deve reiniciar o fluxo de aprovacao na esteira (1-true, 0-false)
    
    CURSOR cr_crawcrd IS
      SELECT crd.nrcctitg
            ,crd.vllimcrd
            ,crd.cdadmcrd
            ,crd.flgprcrd
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrctrcrd = pr_nrctrcrd;
    rw_crawcrd cr_crawcrd%ROWTYPE;
    
  BEGIN    
    
    --Busca dados da proposta do cartão
    OPEN cr_crawcrd;
    FETCH cr_crawcrd INTO rw_crawcrd;
    
    IF cr_crawcrd%NOTFOUND THEN
      vr_dscritic := 'Proposta nao encontrada';
      RAISE vr_exc_erro;
    END IF;    
    CLOSE cr_crawcrd;
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    pc_atualiza_limite_crd(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctrcrd => pr_nrctrcrd
                          ,pr_insitdec => pr_insitdec
                          ,pr_tpsituacao => pr_tpsituacao
                          ,pr_vllimite_anterior => pr_vllimite_anterior
                          ,pr_vllimite_alterado => pr_vllimite_alterado
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dsjustificativa => pr_dsjustificativa
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);

    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    ESTE0005.pc_verifica_regras_esteira(pr_cdcooper  => pr_cdcooper  --> Codigo da cooperativa
                                       ,pr_cdcritic => vr_cdcritic   --> Codigo da critica
                                       ,pr_dscritic => vr_dscritic); --> Descricao da critica

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
    END IF;

    este0005.pc_alterar_proposta_est(pr_cdcooper => pr_cdcooper  
                                    ,pr_cdagenci => vr_cdagenci  
                                    ,pr_cdoperad => vr_cdoperad  
                                    ,pr_cdorigem => vr_idorigem  
                                    ,pr_nrdconta => pr_nrdconta  
                                    ,pr_nrctrcrd => pr_nrctrcrd
                                    ,pr_flreiflx => vr_flreiflx
                                    ,pr_nmarquiv => pr_dsiduser
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    --Gera retorno para tela
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => 0,
                           pr_tag_nova => 'mensagem',
                           pr_tag_cont => pr_des_erro,
                           pr_des_erro => vr_dscritic);

    COMMIT;   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar atualizacao da proposta de Alteração de Limite de Crédito: '||SQLERRM;
  END pc_atualiza_limite_crd_web;
  
  PROCEDURE pc_busca_config_limite_crd_web(pr_cdcooper    IN TBCRD_CONFIG_CATEGORIA.CDCOOPER%TYPE
                                          ,pr_cdadmcrd    IN TBCRD_CONFIG_CATEGORIA.CDADMCRD%TYPE
                                          ,pr_tplimcrd    IN tbcrd_config_categoria.tplimcrd%TYPE DEFAULT 0
                                          ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro  OUT VARCHAR2) IS

    /* ..........................................................................
    
      Programa : pc_busca_config_limite_crd_web   
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Rafael Faria (Supero)
      Data     : Setembro/2018.                   Ultima atualizacao: 
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Chama rotina para criar proposta de Alteração de Limite
      Alteração : 
                  
    ..........................................................................*/
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_vllimite_minimo tbcrd_config_categoria.vllimite_minimo%type :=0;
    vr_vllimite_maximo tbcrd_config_categoria.vllimite_maximo%type :=0;
    vr_diasdebito      tbcrd_config_categoria.dsdias_debito%type :=0;
    vr_possui_registro tbcrd_config_categoria.dsdias_debito%type :=0;
    
  BEGIN    
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    cada0004.pc_busca_credito_config_categ(pr_cdcooper => pr_cdcooper
                                          ,pr_cdadmcrd => pr_cdadmcrd
                                          ,pr_tplimcrd => pr_tplimcrd
                                          ,pr_vllimite_minimo => vr_vllimite_minimo
                                          ,pr_vllimite_maximo => vr_vllimite_maximo
                                          ,pr_diasdebito      => vr_diasdebito
                                          ,pr_possui_registro => vr_possui_registro);

    --Gera retorno para tela
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => null,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    
    
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'vr_vllimite_minimo',
                           pr_tag_cont => vr_vllimite_minimo,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'vr_vllimite_maximo',
                           pr_tag_cont => vr_vllimite_maximo,
                           pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'vr_diasdebito',
                           pr_tag_cont => vr_diasdebito,
                           pr_des_erro => vr_dscritic);
                           
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'vr_possui_registro',
                           pr_tag_cont => vr_possui_registro,
                           pr_des_erro => vr_dscritic);  
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar consulta de limite de credito: '||SQLERRM;
  END pc_busca_config_limite_crd_web;
  
  PROCEDURE pc_valida_alt_nome_empr (pr_cdcooper IN crawcrd.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_valida_alt_nome_empr
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Rafael Faria (Supero)
        Data    : Outubro/2018                 Ultima atualizacao:

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Retornar se o nome da empresa foi alterado

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
    ---------> CURSORES <--------
    CURSOR cr_crawcrd (pr_cdcooper IN crawcrd.cdcooper%TYPE
                      ,pr_nrdconta IN crawcrd.nrdconta%TYPE) IS
      SELECT trunc(c.dtmvtolt)dtmvtolt
        FROM crawcrd c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta
         AND rownum <=1
      ORDER BY c.dtmvtolt desc;
    rw_crawcrd cr_crawcrd%rowtype;

    CURSOR cr_crapalt(pr_cdcooper IN crapalt.cdcooper%TYPE
                     ,pr_nrdconta IN crawcrd.nrdconta%TYPE) IS
      SELECT trunc(a.dtaltera) dtaltera
            ,a.dsaltera
        FROM crapalt a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND rownum <=1
      ORDER BY a.dtaltera desc;
    rw_crapalt cr_crapalt%ROWTYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Gerais
    vr_contador NUMBER := 0;
    vr_flgaltnm NUMBER := 0;
    
  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    OPEN cr_crawcrd(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crawcrd INTO rw_crawcrd;
    CLOSE cr_crawcrd;
    
    OPEN cr_crapalt(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapalt INTO rw_crapalt;
    CLOSE cr_crapalt;

    IF rw_crapalt.dtaltera >= rw_crawcrd.dtmvtolt and rw_crapalt.dsaltera like '%nome fantasia%' THEN
      vr_flgaltnm := 1;
    END IF;

    IF rw_crapalt.dtaltera >= rw_crawcrd.dtmvtolt and rw_crapalt.dsaltera like '%nome 1.ttl%' THEN
      vr_flgaltnm := 1;
    END IF;    

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

		gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml
													,pr_tag_pai => 'Dados'
													,pr_posicao => 0
													,pr_tag_nova => 'cartoes'
													,pr_tag_cont => NULL
													,pr_des_erro => vr_dscritic);

		gene0007.pc_insere_tag(pr_xml => pr_retxml
													,pr_tag_pai => 'cartoes'
													,pr_posicao => vr_contador
													,pr_tag_nova => 'flgaltnm'
													,pr_tag_cont => vr_flgaltnm
													,pr_des_erro => vr_dscritic);
    
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
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_valida_alt_nome_empr. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_valida_alt_nome_empr;
	
	PROCEDURE pc_valida_dtcorte_prot_entrega(pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE
																				 ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
																				 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
																				 ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
																				 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																				 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
																				 ,pr_des_erro OUT VARCHAR2) IS
    /* .............................................................................
    
    Programa: pc_valida_dtcorte_prot_entrega
    Sistema : Ayllos Web
    Autor   : Augusto (Supero)
    Data    : Dezembro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para retornar os dados para o termo/protocolo
		            de entrega do cartao de credito ao cooperado
    
    Alteracoes:
    ..............................................................................*/
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_tab_erro gene0001.typ_tab_erro;
    vr_des_reto VARCHAR2(10);
  
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
		
		--  Variaveis
		vr_dtinsori DATE;
		vr_dtcorte  DATE;
		vr_layout   INTEGER;
		
		
		CURSOR cr_proposta(pr_cdcooper crawcrd.cdcooper%TYPE
		                  ,pr_nrctrcrd crawcrd.nrctrcrd%TYPE) IS
      SELECT crd.dtinsori
			  FROM crawcrd crd
			 WHERE crd.nrctrcrd = pr_nrctrcrd
			   AND crd.cdcooper = pr_cdcooper;
				 
    CURSOR cr_parametro IS
		   SELECT to_date(prm.dsvlrprm, 'DD/MM/YYYY')
			   FROM crapprm prm
				WHERE prm.nmsistem = 'CRED'
				  AND prm.cdacesso = 'ASS_ELET_CARTAO_TERMO';
		
  BEGIN
    -- Extrai os dados vindos do XML
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    
		
		OPEN cr_proposta(pr_cdcooper => vr_cdcooper
		                ,pr_nrctrcrd => pr_nrctrcrd);
    FETCH cr_proposta INTO vr_dtinsori;
		
		IF cr_proposta%NOTFOUND THEN
      vr_dscritic := 'Solicitacao nao encontrada.';
      RAISE vr_exc_saida;		   
		END IF;
		
		OPEN cr_parametro;
    FETCH cr_parametro INTO vr_dtcorte;
		
		IF cr_parametro%NOTFOUND THEN
      vr_dscritic := 'Parametro da data de corte nao encontrada.';
      RAISE vr_exc_saida;		   
		END IF;		
		
		vr_layout := 0; -- 0: antigo; 1: novo
		IF vr_dtinsori IS NOT NULL THEN
			IF vr_dtinsori >= vr_dtcorte THEN
				vr_layout := 1;
			END IF;
		END IF;
		
		-- Criar XML de retorno
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><layout>' || vr_layout || '</layout>');
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_valida_dtcorte_prot_entrega: ' || SQLERRM;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_valida_dtcorte_prot_entrega;														 

	PROCEDURE pc_imprimir_protocolo_entrega(pr_nrctrcrd IN crapcrd.nrctrcrd%TYPE
																				 ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
																				 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
																				 ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
																				 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																				 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
																				 ,pr_des_erro OUT VARCHAR2) IS
    /* .............................................................................
    
    Programa: pc_imprimir_protocolo_entrega
    Sistema : Ayllos Web
    Autor   : Augusto (Supero)
    Data    : Dezembro/2018                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para retornar os dados para o termo/protocolo
		            de entrega do cartao de credito ao cooperado
    
    Alteracoes:
    ..............................................................................*/
  
    -- Cria o registro de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_tab_erro gene0001.typ_tab_erro;
    vr_des_reto VARCHAR2(10);
  
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
  
    -- Variaveis
    vr_xml_temp    VARCHAR2(32726) := '';
    vr_clob        CLOB;
		vr_telefone    VARCHAR(50)     := '';
		vr_dataass     VARCHAR(50)     := '';
		vr_horaass     VARCHAR(50)     := '';
		vr_local       VARCHAR(300)    := '';
		vr_nrcrcard    VARCHAR(50);
		
		-- Variaveis para flag do tipo
		vr_flgprovi    VARCHAR(3)      := '  ';
		vr_flgdefin    VARCHAR(3)      := '  ';
		vr_flgtitul    VARCHAR(3)      := '  ';
		vr_flgadici    VARCHAR(3)      := '  ';
  
    vr_nom_direto VARCHAR2(200); --> Diretório para gravação do arquivo
    vr_dsjasper   VARCHAR2(100); --> nome do jasper a ser usado
    vr_nmarqim    VARCHAR2(70); --> nome do arquivo PDF
  
    CURSOR cr_protocolo (pr_nrctrcrd crapcrd.nrctrcrd%TYPE
		                    ,pr_cdcooper crapcrd.cdcooper%TYPE) IS
      SELECT gene0002.fn_mask_cpf_cnpj(crd.nrcpftit, 1) nrcpfcnpj
						,to_char(crd.nrcrcard) nrcrcard
						,to_char(TRUNC(SYSDATE), 'DD/MM/YYYY') AS data
						,crd.nmtitcrd
						,crd.dtassele
						,crd.nrdconta
						,crd.flgprovi
						,wrd.flgprcrd
			 FROM crapcrd crd
			     ,crawcrd wrd
			WHERE crd.nrctrcrd = wrd.nrctrcrd
		    AND crd.cdcooper = wrd.cdcooper
			  AND crd.nrctrcrd = pr_nrctrcrd
			  AND crd.cdcooper = pr_cdcooper;
    rw_protocolo cr_protocolo%ROWTYPE;
		
    -- Selecionar DDD + telefone
		CURSOR cr_craptfc(pr_cdcooper IN crapass.cdcooper%TYPE
										 ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
			SELECT nrdddtfc
						,nrtelefo
				FROM (SELECT craptfc.nrdddtfc
										,craptfc.nrtelefo
								FROM craptfc
							 WHERE craptfc.cdcooper = pr_cdcooper
								 AND craptfc.nrdconta = pr_nrdconta
								 AND craptfc.tptelefo IN (1, 2, 3)
							 ORDER BY CASE tptelefo
													WHEN 2 THEN -- priorizar celular
													 0
													ELSE -- demais telefones
													 tptelefo
												END ASC)
			 WHERE rownum = 1; -- retorna apenas uma ocorrencia conforme prioridade na ordenacao
		rw_craptfc cr_craptfc%ROWTYPE;
		
		CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
		                 ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
		  SELECT e.nmcidade 
			  FROM crapage e 
			 WHERE e.cdcooper = pr_cdcooper 
			   AND e.cdagenci = pr_cdagenci;
  
  BEGIN
    -- Extrai os dados vindos do XML
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
  
    -- Abre o cursor com os dados do termo
    OPEN cr_protocolo(pr_nrctrcrd => pr_nrctrcrd
		                 ,pr_cdcooper => vr_cdcooper);
    FETCH cr_protocolo
      INTO rw_protocolo;
  
    IF cr_protocolo%NOTFOUND THEN
      CLOSE cr_protocolo;
      vr_dscritic := 'Solicitacao nao encontrada.';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_protocolo;
		
		OPEN cr_craptfc(pr_nrdconta => rw_protocolo.nrdconta
		               ,pr_cdcooper => vr_cdcooper);
		FETCH cr_craptfc INTO rw_craptfc;
		
    IF cr_craptfc%FOUND THEN
       vr_telefone := rw_craptfc.nrdddtfc || ' - ' || rw_craptfc.nrtelefo;
    END IF;
    CLOSE cr_craptfc;
		
		OPEN cr_crapage(pr_cdcooper => vr_cdcooper
		               ,pr_cdagenci => vr_cdagenci);
		FETCH cr_crapage INTO vr_local;
		CLOSE cr_crapage;
		
		vr_nrcrcard := rw_protocolo.nrcrcard;
		
		IF rw_protocolo.nrcrcard > 0 THEN
			vr_nrcrcard := SUBSTR(rw_protocolo.nrcrcard, 1,4)||'.'||
			SUBSTR(rw_protocolo.nrcrcard, 5,4)||'.'||
			SUBSTR(rw_protocolo.nrcrcard, 9,4)||'.'||
			SUBSTR(rw_protocolo.nrcrcard,13,4);
		END IF;
		
    vr_dsjasper := 'protocolo_entrega_cartao_fisico.jasper';
    vr_nmarqim  := '/ProtocoloEntregaCartaoFisico_' || to_char(SYSDATE, 'DDMMYYYYHH24MISS') || '.pdf';		
		
		-- Se já foi assinado eletronicamente
		IF rw_protocolo.dtassele IS NOT NULL THEN
		   vr_dataass := to_char(rw_protocolo.dtassele, 'DD/MM/YYYY');
			 vr_horaass := to_CHAR(rw_protocolo.dtassele, 'HH24"h"MI"min"');
       --
			 vr_dsjasper := 'protocolo_entrega_cartao_eletronico.jasper';
       vr_nmarqim  := '/ProtocoloEntregaCartaoEletronico_' || to_char(SYSDATE, 'DDMMYYYYHH24MISS') || '.pdf';			 
	  END IF;		

    --busca diretorio padrao da cooperativa
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => 'rl');
  
    -- Monta documento XML de Dados
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
  
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><protocolo>');

  
    IF nvl(rw_protocolo.flgprovi, 0) = 1 THEN
			vr_flgprovi := 'X';
		ELSE
			vr_flgdefin := 'X';
		END IF;
    
		IF nvl(rw_protocolo.flgprcrd, 0) = 1 THEN
			vr_flgtitul := 'X';
		ELSE
			vr_flgadici := 'X';
		END IF;		

		gene0002.pc_escreve_xml(pr_xml            => vr_clob,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => '<nrcpfcnpj>' || rw_protocolo.nrcpfcnpj ||' </nrcpfcnpj>'
																							|| '<nrcrcard>' || vr_nrcrcard ||' </nrcrcard>'
																							|| '<telefone>' || vr_telefone ||' </telefone>'
																							|| '<dsagencia>' || vr_local ||' </dsagencia>'
																							|| '<data>' || rw_protocolo.data ||' </data>'
																							|| '<dataass>' || vr_dataass ||' </dataass>'
																							|| '<horaass>' || vr_horaass ||' </horaass>'
																							|| '<titular>' || vr_flgtitul ||' </titular>'
																							|| '<adicional>' || vr_flgadici ||' </adicional>'
																							|| '<provisorio>' || vr_flgprovi ||' </provisorio>'
																							|| '<definitivo>' || vr_flgdefin ||' </definitivo>'
																							|| '<nmprimtl>' || rw_protocolo.nmtitcrd ||' </nmprimtl>');

	
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => '</protocolo>',
                            pr_fecha_xml      => TRUE);
  
    -- Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper,
                                pr_cdprogra  => 'ATENDA',
                                pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                                pr_dsxml     => vr_clob,
                                pr_dsxmlnode => '/protocolo',
                                pr_dsjasper  => vr_dsjasper,
                                pr_dsparams  => NULL,
                                pr_dsarqsaid => vr_nom_direto || vr_nmarqim,
                                pr_cdrelato  => 733,
                                pr_flg_gerar => 'S',
                                pr_qtcoluna  => 80,
                                pr_sqcabrel  => 1,
                                pr_flg_impri => 'N',
                                pr_nmformul  => ' ',
                                pr_nrcopias  => 1,
                                pr_parser    => 'R',
                                pr_nrvergrl  => 1,
                                pr_des_erro  => vr_dscritic);
  
    -- copia contrato pdf do diretorio da cooperativa para servidor web
    gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper,
                                 pr_cdagenci => NULL,
                                 pr_nrdcaixa => NULL,
                                 pr_nmarqpdf => vr_nom_direto || vr_nmarqim,
                                 pr_des_reto => vr_des_reto,
                                 pr_tab_erro => vr_tab_erro);
  
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);
  
    -- Criar XML de retorno
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||
                                   vr_nmarqim || '</nmarqpdf>');
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_imprimir_protocolo_entrega: ' || SQLERRM;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_imprimir_protocolo_entrega;

	PROCEDURE pc_valida_reenvio_alt_limite(pr_cdcooper  IN tbcrd_limite_atualiza.cdcooper%TYPE       --> Cooperativa
                                        ,pr_nrdconta  IN tbcrd_limite_atualiza.nrdconta%TYPE       --> Conta
																				,pr_nrcctitg  IN tbcrd_limite_atualiza.nrconta_cartao%TYPE --> Cartão
																				,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
																				,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
																				,pr_dscritic OUT VARCHAR2           --> Descricao da critica
																				,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																				,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
																				,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
  /* .............................................................................

    Programa: pc_busca_hist_limite_crd
    Sistema : Ayllos Web
    Autor   : Renato Darosci
    Data    : Agosto/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para listar o histórico de alteração de limite de
                cartão de crédito

    Alteracoes:
  ..............................................................................*/

    -- Buscar a última alteração de limite
    CURSOR cr_limite IS
      SELECT tla.nrctrcrd
					 , crd.nrcrcard
					 , tla.cdadmcrd
					 , tla.idatualizacao
					 , tla.nrproposta_est
					 , tla.tpsituacao
					 , crd.insitcrd
				FROM tbcrd_limite_atualiza tla
					 , crawcrd crd
			 WHERE tla.cdcooper = pr_cdcooper
				 AND tla.nrdconta = pr_nrdconta
				 AND tla.nrconta_cartao = pr_nrcctitg
				 AND tla.cdcooper = crd.cdcooper
				 AND tla.nrctrcrd = crd.nrctrcrd
				 AND tla.nrconta_cartao = crd.nrcctitg				 
			   AND tla.dtalteracao = (SELECT MAX(b.dtalteracao)
                                    FROM tbcrd_limite_atualiza b
                                   WHERE b.cdcooper = tla.cdcooper
                                     AND b.nrdconta = tla.nrdconta
                                     AND b.nrctrcrd = tla.nrctrcrd);
		rw_limite cr_limite%ROWTYPE;

    -- Variavel de criticas
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

  BEGIN

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
		
		OPEN cr_limite;
		FETCH cr_limite INTO rw_limite;
		--
		IF cr_limite%NOTFOUND THEN
			vr_dscritic := 'Nenhuma proposta de alteração de limite encontrada.';
			RAISE vr_exc_saida;
		END IF;
		
		-- Em Uso		
		IF rw_limite.insitcrd <> 4 THEN
			vr_dscritic := 'O cartão deve estar Em Uso.';
		END IF;		

		-- Em análise / Erro               
		IF rw_limite.tpsituacao NOT IN (4, 6) THEN
			vr_dscritic := 'A proposta de alteração de limite deve estar Em análise ou com Erro.';
		END IF;

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

		-- Insere o nodo de histórico
		GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'Dados'
													,pr_posicao  => 0
													,pr_tag_nova => 'historico'
													,pr_tag_cont => NULL
													,pr_des_erro => vr_dscritic);

		-- Insere o número do cartão
		GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'historico'
													,pr_posicao  => 0
													,pr_tag_nova => 'nrcrcard'
													,pr_tag_cont => rw_limite.nrcrcard
													,pr_des_erro => vr_dscritic);

		-- Insere o código da administradora do cartão
		GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'historico'
													,pr_posicao  => 0
													,pr_tag_nova => 'cdadmcrd'
													,pr_tag_cont => rw_limite.cdadmcrd
													,pr_des_erro => vr_dscritic);
													
		-- Insere o número da proposta de cartão
		GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'historico'
													,pr_posicao  => 0
													,pr_tag_nova => 'nrctrcrd'
													,pr_tag_cont => rw_limite.nrctrcrd
													,pr_des_erro => vr_dscritic);
													
		-- Insere o número da proposta na esteira
		GENE0007.pc_insere_tag(pr_xml      => pr_retxml
													,pr_tag_pai  => 'historico'
													,pr_posicao  => 0
													,pr_tag_nova => 'nrproposta_est'
													,pr_tag_cont => rw_limite.nrproposta_est
													,pr_des_erro => vr_dscritic);													

  EXCEPTION
		WHEN vr_exc_saida THEN
			pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina pc_valida_reenvio_alt_limite: ' || SQLERRM;

      -- Carregar XML padrão para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
	END pc_valida_reenvio_alt_limite;
	
  PROCEDURE pc_atualiza_endereco_crd(pr_cdcooper      IN  tbcrd_endereco_entrega.cdcooper%TYPE     --> Código da cooperativa
		                                ,pr_nrdconta      IN  tbcrd_endereco_entrega.nrdconta%TYPE     --> Número da conta
																		,pr_nrctrcrd      IN  tbcrd_endereco_entrega.nrctrcrd%TYPE     --> Número da proposta de cartão de crédito
																		,pr_idtipoenvio   IN  tbcrd_endereco_entrega.idtipoenvio%TYPE	 --> Tipo de envio do cartão
																		,pr_cdagenci      IN  tbcrd_endereco_entrega.cdagenci%TYPE     --> Código da agencia de envio
																		,pr_xmllog        IN  VARCHAR2                                 --> XML com informacoes de LOG
																	  ,pr_cdcritic      OUT PLS_INTEGER                              --> Codigo da critica
																		,pr_dscritic      OUT VARCHAR2                                 --> Descricao da critica
																	  ,pr_retxml        IN  OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
																		,pr_nmdcampo      OUT VARCHAR2                                 --> Nome do campo com erro
																	 	,pr_des_erro      OUT VARCHAR2) IS                             --> Erros do processo
																		
  /* .............................................................................

    Programa: pc_atualiza_endereco_crd
    Sistema : Ayllos Web
    Autor   : Augusto (Supero)
    Data    : Março/2019                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para alterar o tipo de endereço de entrega de um cartão de crédito.

    Alteracoes:
  ..............................................................................*/

	-- Tratamento de erros
	vr_cdcritic NUMBER := 0;
	vr_dscritic VARCHAR2(4000) := '';
	vr_exc_saida EXCEPTION;
	
	-- Variaveis retornadas da gene0004.pc_extrai_dados
	vr_cdcooper INTEGER;
	vr_cdoperad VARCHAR2(100);
	vr_nmdatela VARCHAR2(100);
	vr_nmeacao  VARCHAR2(100);
	vr_cdagenci VARCHAR2(100);
	vr_nrdcaixa VARCHAR2(100);
	vr_idorigem VARCHAR2(100);
	

	-- Variavel de controle de data
	rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
	-- Cursores internos
	CURSOR cr_end_agencia(pr_cdcooper IN crapenc.cdcooper%TYPE
											 ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
			SELECT crapage.dsendcop
						,crapage.nrendere
						,crapage.dscomple
						,crapage.nmbairro
						,crapage.nmcidade
						,crapage.cdufdcop
						,crapage.cdagenci
						,crapage.nrcepend
				FROM crapage
			 WHERE crapage.cdcooper = pr_cdcooper
				 AND crapage.cdagenci = pr_cdagenci;
	rw_end_agencia cr_end_agencia%ROWTYPE;
	
	-- Cursor para verificar se existe recadastro na conta
	CURSOR cr_crapalt(pr_cdcooper IN crapass.cdcooper%TYPE
									 ,pr_nrdconta IN crapass.nrdconta%TYPE
									 ,pr_dtaltera IN crapalt.dtaltera%TYPE)IS
		SELECT a.dsaltera
					,a.progress_recid
			FROM crapalt a
		 WHERE a.cdcooper = pr_cdcooper
			 AND a.nrdconta = pr_nrdconta
			 AND a.dtaltera = pr_dtaltera;
	rw_crapalt cr_crapalt%ROWTYPE;
	
    
	CURSOR cr_end_cooperado(pr_cdcooper    IN crapcop.cdcooper%TYPE
												 ,pr_nrdconta    IN crapass.nrdconta%TYPE
												 ,pr_idtipoenvio IN crapenc.tpendass%TYPE) IS
			SELECT crapenc.dsendere
						,crapenc.nrendere
						,crapenc.complend
						,crapenc.nmbairro
						,crapenc.nrcepend
						,crapenc.nmcidade
						,crapenc.cdufende
				FROM crapenc
						,crapass
			 WHERE crapenc.cdcooper = crapass.cdcooper
				 AND crapenc.nrdconta = crapass.nrdconta
				 AND crapenc.cdcooper = pr_cdcooper
				 AND crapenc.nrdconta = pr_nrdconta
				 AND crapenc.tpendass = pr_idtipoenvio;
	rw_end_cooperado cr_end_cooperado%ROWTYPE;
	
	CURSOR cr_cdadmcrd(pr_cdcooper crawcrd.cdcooper%TYPE
                  ,pr_nrctrcrd crawcrd.nrctrcrd%TYPE
									,pr_nrdconta crawcrd.nrdconta%TYPE) IS
	  SELECT d.cdadmcrd
		  FROM crawcrd d
		 WHERE d.cdcooper = pr_cdcooper
		   AND d.nrctrcrd = pr_nrctrcrd;
   rw_cdadmcrd cr_cdadmcrd%ROWTYPE;
	 
	 CURSOR cr_cartoes(pr_cdcooper crawcrd.cdcooper%TYPE
	                  ,pr_cdadmcrd crawcrd.cdadmcrd%TYPE
										,pr_nrdconta crawcrd.nrdconta%TYPE) IS
     SELECT d.nrctrcrd
		   FROM crawcrd d
			WHERE d.cdcooper = pr_cdcooper
			  AND	d.cdadmcrd = pr_cdadmcrd
				AND d.nrdconta = pr_nrdconta;
	 rw_cartoes cr_cartoes%ROWTYPE;

	BEGIN
		
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);	
	
		-- Verificacao do calendario
		OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
		FETCH btch0001.cr_crapdat
				INTO rw_crapdat;
		CLOSE btch0001.cr_crapdat;
    
		-- Se retornou alguma crítica
		IF TRIM(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
		END IF;
		
		-- Iremos retornar a administradora da proposta
		OPEN cr_cdadmcrd(pr_cdcooper => pr_cdcooper
		                ,pr_nrctrcrd => pr_nrctrcrd
									  ,pr_nrdconta => pr_nrdconta);
		FETCH cr_cdadmcrd INTO rw_cdadmcrd;
		
		IF cr_cdadmcrd%NOTFOUND THEN
			CLOSE cr_cdadmcrd;
			vr_dscritic := 'Proposta nao localizada.';
		END IF;
		CLOSE cr_cdadmcrd;
		
		-- Iremos atualizar o endereço de todos os cartões da administradora daquela conta (adicionais)
		FOR rw_cartoes IN cr_cartoes(pr_cdcooper => pr_cdcooper
			                          ,pr_cdadmcrd => nvl(rw_cdadmcrd.cdadmcrd, 0)
																,pr_nrdconta => pr_nrdconta) LOOP
			-- Indica que deve ser entregue em uma agencia (PA)
			IF pr_cdagenci > 0 THEN
					-- Busca endereço do PA
					OPEN cr_end_agencia(pr_cdcooper => pr_cdcooper, pr_cdagenci => pr_cdagenci);
					FETCH cr_end_agencia INTO rw_end_agencia;
					CLOSE cr_end_agencia;
	        
					BEGIN
							INSERT INTO tbcrd_endereco_entrega
									(cdcooper
									,nrdconta
									,nrctrcrd
									,idtipoenvio
									,nmlogradouro
									,nrlogradouro
									,dscomplemento
									,nmbairro
									,nmcidade
									,nrcep
									,cdagenci
									,cdufende)
							VALUES
									(pr_cdcooper
									,pr_nrdconta
									,rw_cartoes.nrctrcrd
									,pr_idtipoenvio
									,rw_end_agencia.dsendcop
									,rw_end_agencia.nrendere
									,rw_end_agencia.dscomple
									,rw_end_agencia.nmbairro
									,rw_end_agencia.nmcidade
									,rw_end_agencia.nrcepend
									,pr_cdagenci
									,rw_end_agencia.cdufdcop);
					EXCEPTION
							WHEN DUP_VAL_ON_INDEX THEN
								BEGIN
									UPDATE tbcrd_endereco_entrega
										 SET idtipoenvio = pr_idtipoenvio
												,nmlogradouro = rw_end_agencia.dsendcop
												,nrlogradouro = rw_end_agencia.nrendere
												,dscomplemento = rw_end_agencia.dscomple
												,nmbairro = rw_end_agencia.nmbairro
												,nmcidade = rw_end_agencia.nmcidade
												,nrcep = rw_end_agencia.nrcepend
												,cdagenci = pr_cdagenci
												,cdufende = rw_end_agencia.cdufdcop
									 WHERE cdcooper = pr_cdcooper
										 AND nrdconta = pr_nrdconta
										 AND nrctrcrd = rw_cartoes.nrctrcrd;
								EXCEPTION
									WHEN OTHERS THEN
										vr_cdcritic := 0;
										vr_dscritic := 'Erro ao atualizar a tabela tbcrd_endereco_entrega. ' || SQLERRM;
										RAISE vr_exc_saida;
								END;
							WHEN OTHERS THEN
									vr_cdcritic := 0;
									vr_dscritic := 'Erro ao inserir na tabela tbcrd_endereco_entrega. ' || SQLERRM;
									RAISE vr_exc_saida;
					END;
			ELSE
					-- Busca endereço do cooperado
					OPEN cr_end_cooperado(pr_cdcooper    => pr_cdcooper
															 ,pr_nrdconta    => pr_nrdconta
															 ,pr_idtipoenvio => pr_idtipoenvio);
					FETCH cr_end_cooperado INTO rw_end_cooperado;
					CLOSE cr_end_cooperado;
	        
					BEGIN            
							INSERT INTO tbcrd_endereco_entrega
									(cdcooper
									,nrdconta
									,nrctrcrd
									,idtipoenvio
									,nmlogradouro
									,nrlogradouro
									,dscomplemento
									,nmbairro
									,nmcidade
									,nrcep
									,cdufende)
							VALUES
									(pr_cdcooper
									,pr_nrdconta
									,rw_cartoes.nrctrcrd
									,pr_idtipoenvio
									,rw_end_cooperado.dsendere
									,rw_end_cooperado.nrendere
									,rw_end_cooperado.complend
									,rw_end_cooperado.nmbairro
									,rw_end_cooperado.nmcidade
									,rw_end_cooperado.nrcepend
									,rw_end_cooperado.cdufende);
					EXCEPTION
							WHEN DUP_VAL_ON_INDEX THEN
								BEGIN
									UPDATE tbcrd_endereco_entrega
										 SET idtipoenvio = pr_idtipoenvio
												,nmlogradouro = rw_end_cooperado.dsendere
												,nrlogradouro = rw_end_cooperado.nrendere
												,dscomplemento = rw_end_cooperado.complend
												,nmbairro = rw_end_cooperado.nmbairro
												,nmcidade = rw_end_cooperado.nmcidade
												,nrcep = rw_end_cooperado.nrcepend
												,cdagenci = 0
												,cdufende = rw_end_cooperado.cdufende
									 WHERE cdcooper = pr_cdcooper
										 AND nrdconta = pr_nrdconta
										 AND nrctrcrd = rw_cartoes.nrctrcrd;
								EXCEPTION
									WHEN OTHERS THEN
										vr_cdcritic := 0;
										vr_dscritic := 'Erro ao atualizar a tabela tbcrd_endereco_entrega. ' || SQLERRM;
										RAISE vr_exc_saida;
								END;
							WHEN OTHERS THEN
									vr_cdcritic := 0;
									vr_dscritic := 'Erro ao inserir na tabela tbcrd_endereco_entrega. ' || SQLERRM;
									RAISE vr_exc_saida;
					END;
			END IF;		
		END LOOP;
		
		-- Verifica se a conta esta recadastrada
    OPEN cr_crapalt(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_dtaltera => rw_crapdat.dtmvtolt);
                   
    FETCH cr_crapalt INTO rw_crapalt;
    
    IF cr_crapalt%NOTFOUND THEN
      CLOSE cr_crapalt;
      
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
                (pr_nrdconta,
                 rw_crapdat.dtmvtolt,
                 vr_cdoperad,
                 'end.res. 1.ttl,cep 1.ttl,',
                 1,
                 0,
                 pr_cdcooper);
    EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPALT: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
    ELSE
      CLOSE cr_crapalt;
        -- Se ja existir, deve-se validar se já não é atualização de endereço
				IF INSTR(rw_crapalt.dsaltera, 'end.res.') = 0 OR INSTR(rw_crapalt.dsaltera, 'cep 1.ttl') = 0 THEN
					BEGIN
						UPDATE crapalt
						 SET dsaltera = rw_crapalt.dsaltera || 'end.res. 1.ttl,cep 1.ttl,'
					 WHERE crapalt.progress_recid = rw_crapalt.progress_recid;
					EXCEPTION
						WHEN OTHERS THEN
							vr_dscritic := 'Erro ao atualizar crapalt: '||SQLERRM;
							RAISE vr_exc_saida;
					END;				
				END IF;
        
    END IF;
		
    COMMIT;
    
    EXCEPTION
      WHEN vr_exc_saida THEN
         IF vr_cdcritic <> 0 THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         ELSE
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
         END IF;
         ROLLBACK;
      WHEN OTHERS THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral na rotina pc_atualiza_endereco_crd: ' || SQLERRM;
          ROLLBACK;		
	END pc_atualiza_endereco_crd;
	
	PROCEDURE pc_busca_parametro_aprovador (pr_cdcooper  IN crapprm.cdcooper%TYPE   --> Código da cooperativa
		                                     ,pr_xmllog    IN VARCHAR2                --> XML com informacoes de LOG
																	       ,pr_cdcritic OUT PLS_INTEGER             --> Codigo da critica
																		     ,pr_dscritic OUT VARCHAR2                --> Descricao da critica
																	       ,pr_retxml    IN OUT NOCOPY xmltype      --> Arquivo de retorno do XML
																		     ,pr_nmdcampo OUT VARCHAR2                --> Nome do campo com erro
																	 	     ,pr_des_erro OUT VARCHAR2) IS            --> Erros do processo

  /* .............................................................................

    Programa: pc_busca_parametro_aprovador
    Sistema : Ayllos Web
    Autor   : Augusto (Supero)
    Data    : Março/2019                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar o parâmetro de aprovador

    Alteracoes:
  ..............................................................................*/
	
	vr_dsvlrprm NUMBER := 0;
	
	CURSOR cr_parametro IS
	  SELECT r.dsvlrprm
		  FROM crapprm r
		 WHERE r.cdcooper = pr_cdcooper
		   AND r.cdacesso = 'SENHA_SUPERVISOR_CRD';
	rw_parametro cr_parametro%ROWTYPE;

	BEGIN
    OPEN cr_parametro;
		FETCH cr_parametro INTO rw_parametro;
		--
		IF cr_parametro%FOUND THEN
			vr_dsvlrprm := rw_parametro.dsvlrprm;
	  END IF;
		--		
		CLOSE cr_parametro;

		pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																	 '<Root><Dados>' || vr_dsvlrprm || '</Dados></Root>');
	
		EXCEPTION
      WHEN OTHERS THEN
          pr_dscritic := 'Erro geral na rotina pc_busca_parametro_aprovador: ' || SQLERRM;
	END pc_busca_parametro_aprovador;
	
  PROCEDURE pc_busca_enderecos_crd(pr_cdcooper IN crawcrd.cdcooper%TYPE --> Codigo da cooperativa
                                  ,pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr. da Conta
																	,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS
        --> Erros do processo
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;
    
        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis internas
        vr_cont_tag     PLS_INTEGER := 0;
        vr_cont_sub_tag PLS_INTEGER := 0;
        
				-- Cursor dos dominios
				CURSOR cr_dominios(pr_cdcooper IN crapenc.cdcooper%TYPE
                          ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
            SELECT tdc.cddominio
									,tdc.dscodigo
									,enc.dsendere || ', ' || enc.nrendere ||
                   nvl2(TRIM(enc.complend), ', ' || enc.complend, '') || chr(13) || chr(10) ||
                   enc.nmbairro || ' - ' || enc.nmcidade || ' - ' || enc.cdufende || chr(13) ||
                   chr(10) || 'CEP: ' || gene0002.fn_mask_cep(enc.nrcepend) AS dsendereco
							FROM tbcrd_dominio_campo tdc
									,crapenc enc
						 WHERE tdc.nmdominio = 'TPENDERECOENTREGA'
							 AND tdc.inativo = 1
							 AND tdc.cddominio = enc.tpendass
							 AND enc.cdcooper = pr_cdcooper
							 AND enc.nrdconta = pr_nrdconta
							 AND enc.idseqttl = 1
							 AND enc.tpendass NOT IN (12)
               AND TRIM(enc.dsendere) IS NOT NULL
							 AND tdc.cddominio IN (SELECT tpec.idtipoenvio
                                       FROM tbcrd_pa_envio_cartao tpec
                                      WHERE tpec.cdcooper = pr_cdcooper
                                        AND tpec.idfuncionalidade = 1
                                        AND tpec.cdagencia = (SELECT cdagenci
                                                                FROM crapass
                                                               WHERE cdcooper = pr_cdcooper
                                                                 AND nrdconta = pr_nrdconta))
						 ORDER BY tdc.dscodigo;
				rw_dominios cr_dominios%ROWTYPE;
    
        -- Cursor dos endereços da cooperativa
				CURSOR cr_end_coop(pr_cdcooper IN crapenc.cdcooper%TYPE
                          ,pr_nrdconta IN crapenc.nrdconta%TYPE) IS
            SELECT crapage.dsendcop || ', ' || crapage.nrendere ||
                   nvl2(TRIM(crapage.dscomple), ', ' || crapage.dscomple, '') || chr(13) || chr(10) ||
                   crapage.nmbairro || ' - ' || crapage.nmcidade || ' - ' || crapage.cdufdcop || chr(13) ||
                   chr(10) || 'CEP: ' || gene0002.fn_mask_cep(crapage.nrcepend) AS dsendereco
                  ,crapage.cdagenci
              FROM crapass
                  ,crapage
									,tbcrd_pa_envio_cartao tec
             WHERE crapass.cdcooper = pr_cdcooper
               AND crapass.nrdconta = pr_nrdconta
               AND crapage.cdcooper = crapass.cdcooper
               AND crapage.cdagenci = crapass.cdagenci
							 AND crapage.cdagenci = tec.cdagencia
							 AND crapage.cdcooper = tec.cdcooper
							 AND tec.idtipoenvio = 90 -- PA
							 AND tec.idfuncionalidade = 1 -- ENVIO CARTAO
               AND TRIM(crapage.dsendcop) IS NOT NULL;
        rw_end_coop cr_end_coop%ROWTYPE;
    
        -- Cursor das agencias
				CURSOR cr_agencias_habilitadas(pr_cdcooper IN crapenc.cdcooper%TYPE) IS
            SELECT 'PA ' || tec.cdagencia || ' - ' || age.nmresage AS dsagencia
                  ,age.cdagenci
                  ,age.dsendcop || ', ' || age.nrendere || nvl2(TRIM(age.dscomple), ', ' || age.dscomple, '') ||
                   chr(13) || chr(10) || age.nmbairro || ' - ' || age.nmcidade || ' - ' || age.cdufdcop ||
                   chr(13) || chr(10) || 'CEP: ' || gene0002.fn_mask_cep(age.nrcepend) AS dsendereco
              FROM tbcrd_pa_envio_cartao tec
                  ,crapage               age
             WHERE tec.cdcooper = pr_cdcooper
               AND tec.idtipoenvio = 91
               AND age.cdcooper = pr_cdcooper
               AND age.cdagenci = tec.cdagencia
               AND TRIM(age.dsendcop) IS NOT NULL;
        rw_agencias_habilitadas cr_agencias_habilitadas%ROWTYPE;
		
    BEGIN
    
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela, pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
    
        -- Criar cabecalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dominios'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
    
        
				------------------------------
				
				FOR rw_dominios IN cr_dominios(pr_cdcooper => pr_cdcooper
					                            ,pr_nrdconta => pr_nrdconta) LOOP
					
					gene0007.pc_insere_tag(pr_xml      => pr_retxml
																,pr_tag_pai  => 'Dominios'
																,pr_posicao  => 0
																,pr_tag_nova => 'Dominio'
																,pr_tag_cont => NULL
																,pr_des_erro => vr_dscritic);
																
          gene0007.pc_insere_tag(pr_xml      => pr_retxml
																,pr_tag_pai  => 'Dominio'
																,pr_posicao  => vr_cont_tag
																,pr_tag_nova => 'cddominio'
																,pr_tag_cont => rw_dominios.cddominio
																,pr_des_erro => vr_dscritic);
																
          gene0007.pc_insere_tag(pr_xml      => pr_retxml
																,pr_tag_pai  => 'Dominio'
																,pr_posicao  => vr_cont_tag
																,pr_tag_nova => 'dscodigo'
																,pr_tag_cont => rw_dominios.dscodigo
																,pr_des_erro => vr_dscritic);
					
					gene0007.pc_insere_tag(pr_xml      => pr_retxml
																,pr_tag_pai  => 'Dominio'
																,pr_posicao  => vr_cont_tag
																,pr_tag_nova => 'dsendereco'
																,pr_tag_cont => rw_dominios.dsendereco
																,pr_des_erro => vr_dscritic);
																
					gene0007.pc_insere_tag(pr_xml      => pr_retxml
															,pr_tag_pai  => 'Dominio'
															,pr_posicao  => vr_cont_tag
															,pr_tag_nova => 'cdagenci'
															,pr_tag_cont => 0
															,pr_des_erro => vr_dscritic);																
																
					vr_cont_tag := vr_cont_tag + 1;
				
				END LOOP;
				
				----------------------------------------
				
				
				
				OPEN cr_end_coop(pr_cdcooper => pr_cdcooper
					              ,pr_nrdconta => pr_nrdconta);
				FETCH cr_end_coop INTO rw_end_coop;
				--
				IF cr_end_coop%FOUND THEN
					gene0007.pc_insere_tag(pr_xml      => pr_retxml
															,pr_tag_pai  => 'Dominios'
															,pr_posicao  => 0
															,pr_tag_nova => 'Dominio'
															,pr_tag_cont => NULL
															,pr_des_erro => vr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml
															,pr_tag_pai  => 'Dominio'
															,pr_posicao  => vr_cont_tag
															,pr_tag_nova => 'cddominio'
															,pr_tag_cont => 90
															,pr_des_erro => vr_dscritic);

				  gene0007.pc_insere_tag(pr_xml      => pr_retxml
															,pr_tag_pai  => 'Dominio'
															,pr_posicao  => vr_cont_tag
															,pr_tag_nova => 'dscodigo'
															,pr_tag_cont => 'PA'
															,pr_des_erro => vr_dscritic);

					gene0007.pc_insere_tag(pr_xml      => pr_retxml
															,pr_tag_pai  => 'Dominio'
															,pr_posicao  => vr_cont_tag
															,pr_tag_nova => 'dsendereco'
															,pr_tag_cont => rw_end_coop.dsendereco
															,pr_des_erro => vr_dscritic);
															
					gene0007.pc_insere_tag(pr_xml      => pr_retxml
															,pr_tag_pai  => 'Dominio'
															,pr_posicao  => vr_cont_tag
															,pr_tag_nova => 'cdagenci'
															,pr_tag_cont => rw_end_coop.cdagenci
															,pr_des_erro => vr_dscritic);														

				  vr_cont_tag := vr_cont_tag + 1;
				
				END IF;
				--
				CLOSE cr_end_coop;
				
				-----------------------
				
				gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Cooperativas'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
				
				FOR rw_agencias_habilitadas IN cr_agencias_habilitadas(pr_cdcooper => pr_cdcooper) LOOP
				
					gene0007.pc_insere_tag(pr_xml      => pr_retxml
																,pr_tag_pai  => 'Cooperativas'
																,pr_posicao  => 0
																,pr_tag_nova => 'Cooperativa'
																,pr_tag_cont => NULL
																,pr_des_erro => vr_dscritic);

					gene0007.pc_insere_tag(pr_xml      => pr_retxml
																,pr_tag_pai  => 'Cooperativa'
																,pr_posicao  => vr_cont_sub_tag
																,pr_tag_nova => 'dsagencia'
																,pr_tag_cont => rw_agencias_habilitadas.dsagencia
																,pr_des_erro => vr_dscritic);

					gene0007.pc_insere_tag(pr_xml      => pr_retxml
																,pr_tag_pai  => 'Cooperativa'
																,pr_posicao  => vr_cont_sub_tag
																,pr_tag_nova => 'cdagenci'
																,pr_tag_cont => rw_agencias_habilitadas.cdagenci
																,pr_des_erro => vr_dscritic);

					gene0007.pc_insere_tag(pr_xml      => pr_retxml
																,pr_tag_pai  => 'Cooperativa'
																,pr_posicao  => vr_cont_sub_tag
																,pr_tag_nova => 'dsendereco'
																,pr_tag_cont => rw_agencias_habilitadas.dsendereco
																,pr_des_erro => vr_dscritic);
																
					vr_cont_sub_tag := vr_cont_sub_tag + 1;

				END LOOP;			
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_PARECC.pc_busca_dominio_parecc. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_busca_enderecos_crd;	
		

    PROCEDURE pc_verifica_cooperativa_pa(pr_cdcooper          IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                        ,pr_nrdconta          IN crapass.nrdconta%TYPE --> Numero da Conta
                                        ,pr_coop_envio_cartao OUT INTEGER --> Indica se cooperativa esta habilitada para envio de cartao
                                        ,pr_pa_envio_cartao   OUT INTEGER --> Indica se o PA esta habilitado para envio de cartao
                                        ,pr_cdcritic          OUT PLS_INTEGER --> Código da crítica
                                        ,pr_dscritic          OUT VARCHAR2) IS
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;
        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis internas
        vr_envio_cartao INTEGER := 0;
    
        -- Cursores internos
        CURSOR cr_coop_envio_cartao(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
            SELECT tec.flghabilitar FROM tbcrd_envio_cartao tec WHERE tec.cdcooper = pr_cdcooper;
        rw_coop_envio_cartao cr_coop_envio_cartao%ROWTYPE;
    
        CURSOR cr_pa_envio_cartao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
            SELECT COUNT(1) pode_enviar
              FROM crapass
                  ,tbcrd_envio_cartao tec
             WHERE crapass.cdcooper = tec.cdcooper
               AND crapass.cdcooper = pr_cdcooper
               AND crapass.nrdconta = pr_nrdconta
               AND crapass.cdagenci IN
                   (SELECT tp.cdagencia FROM tbcrd_pa_envio_cartao tp WHERE tp.cdcooper = crapass.cdcooper)
               AND tec.flghabilitar = 1;
    
    BEGIN
        -- Criar cabecalho do XML
        OPEN cr_coop_envio_cartao(pr_cdcooper => pr_cdcooper);
        FETCH cr_coop_envio_cartao
            INTO rw_coop_envio_cartao;
        CLOSE cr_coop_envio_cartao;
    
        OPEN cr_pa_envio_cartao(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
        FETCH cr_pa_envio_cartao
            INTO vr_envio_cartao;
        CLOSE cr_pa_envio_cartao;
    
        pr_coop_envio_cartao := nvl(rw_coop_envio_cartao.flghabilitar, 0);
        pr_pa_envio_cartao   := vr_envio_cartao;
    
    EXCEPTION
        WHEN vr_exc_saida THEN
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        WHEN OTHERS THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina pc_inclui_end_entrega_cartao: ' || SQLERRM;
    END pc_verifica_cooperativa_pa;

    PROCEDURE pc_verifica_cooperativa_pa_web(pr_nrdconta IN crapass.nrdconta%TYPE
                                            ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                            ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                            ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                            ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                            ,pr_des_erro OUT VARCHAR2) IS
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;
        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis internas
        vr_coop_envio_cartao INTEGER := 0;
        vr_pa_envio_cartao   INTEGER := 0;
    
        -- Cursores internos
        CURSOR cr_coop_envio_cartao(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
            SELECT tec.flghabilitar FROM tbcrd_envio_cartao tec WHERE tec.cdcooper = pr_cdcooper;
        rw_coop_envio_cartao cr_coop_envio_cartao%ROWTYPE;
    
        CURSOR cr_pa_envio_cartao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
            SELECT COUNT(1) pode_enviar
              FROM crapass
                  ,tbcrd_envio_cartao tec
             WHERE crapass.cdcooper = tec.cdcooper
               AND crapass.cdcooper = pr_cdcooper
               AND crapass.nrdconta = pr_nrdconta
               AND crapass.cdagenci IN
                   (SELECT tp.cdagencia FROM tbcrd_pa_envio_cartao tp WHERE tp.cdcooper = crapass.cdcooper)
               AND tec.flghabilitar = 1;
    
    BEGIN
        pr_des_erro := 'OK';
    
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela, pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
    
        pc_verifica_cooperativa_pa(pr_cdcooper          => vr_cdcooper
                                  ,pr_nrdconta          => pr_nrdconta
                                  ,pr_coop_envio_cartao => vr_coop_envio_cartao
                                  ,pr_pa_envio_cartao   => vr_pa_envio_cartao
                                  ,pr_cdcritic          => vr_cdcritic
                                  ,pr_dscritic          => vr_dscritic);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
    
        -- Criar cabecalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'coop_envio_cartao'
                              ,pr_tag_cont => vr_coop_envio_cartao
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'pa_envio_cartao'
                              ,pr_tag_cont => vr_pa_envio_cartao
                              ,pr_des_erro => vr_dscritic);
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        
            IF cr_coop_envio_cartao%ISOPEN THEN
                CLOSE cr_coop_envio_cartao;
            END IF;
        
            IF cr_pa_envio_cartao%ISOPEN THEN
                CLOSE cr_pa_envio_cartao;
            END IF;
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAOCREDITO.pc_verifica_cooperado_pa. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        
            IF cr_coop_envio_cartao%ISOPEN THEN
                CLOSE cr_coop_envio_cartao;
            END IF;
        
            IF cr_pa_envio_cartao%ISOPEN THEN
                CLOSE cr_pa_envio_cartao;
            END IF;
    END pc_verifica_cooperativa_pa_web;    
		
    PROCEDURE pc_busca_dados_crd(pr_cdcooper IN crawcrd.cdcooper%TYPE --> Nr. da Cooperativa
															  ,pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr. da Conta
															  ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. proposta do cartao
																,pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE --> Nr. da administradora do cartao
															  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
															  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
															  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
															  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
															  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
															  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_busca_dados_crd
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Augusto - supero
        Data    : Abril/2019                 Ultima atualizacao: 05/04/2019

        Dados referentes ao programa:

        Frequencia: Sempre que continuarmos uma proposta

        Objetivo  : Retornar os dados da proposta de cartão de crédito (titularidade, limite...)

        Observacao: -----

        Alteracoes: 
    ..............................................................................*/
		
		CURSOR cr_titular(pr_cdcooper crawcrd.cdcooper%TYPE
		                 ,pr_nrdconta crawcrd.nrdconta%TYPE
										 ,pr_cdadmcrd crawcrd.cdadmcrd%TYPE) IS
		  SELECT d.nrctrcrd
			      ,d.vllimcrd
			  FROM crawcrd d
			 WHERE d.cdcooper = pr_cdcooper
			   AND d.nrdconta = pr_nrdconta
				 AND d.cdadmcrd = pr_cdadmcrd
				 AND d.flgprcrd = 1
				 AND d.insitcrd NOT IN(5,6); --bloqueado, cancelado
		rw_titular cr_titular%ROWTYPE;
		
		-- variaveis gerais
		vr_flgTitular NUMBER := 1;
		vr_limite_titular NUMBER := 0;
		
		-- variaveis de erro
		vr_dscritic VARCHAR2(500);
		
	  BEGIN
			
      OPEN cr_titular(pr_cdcooper => pr_cdcooper
			               ,pr_nrdconta => pr_nrdconta
										 ,pr_cdadmcrd => pr_cdadmcrd);
		  FETCH cr_titular INTO rw_titular;
			CLOSE cr_titular;
			
			IF pr_nrctrcrd <> rw_titular.nrctrcrd THEN
				vr_flgTitular := 0;
			END IF;
			vr_limite_titular := rw_titular.vllimcrd;
			
			-- Criar cabecalho do XML
			pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

			gene0007.pc_insere_tag(pr_xml      => pr_retxml
														,pr_tag_pai  => 'Root'
														,pr_posicao  => 0
														,pr_tag_nova => 'Dados'
														,pr_tag_cont => NULL
														,pr_des_erro => vr_dscritic);
														
			gene0007.pc_insere_tag(pr_xml      => pr_retxml
														,pr_tag_pai  => 'Dados'
														,pr_posicao  => 0
														,pr_tag_nova => 'flgTitular'
														,pr_tag_cont => vr_flgTitular
														,pr_des_erro => vr_dscritic);
														
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
														,pr_tag_pai  => 'Dados'
														,pr_posicao  => 0
														,pr_tag_nova => 'limiteTitular'
														,pr_tag_cont => vr_limite_titular
														,pr_des_erro => vr_dscritic);
			
		
	 END pc_busca_dados_crd;	

-- Busca parametros de majoracao do cooperado
  PROCEDURE pc_busca_param_majora(pr_nrdconta              IN crapass.nrdconta%TYPE
                                  -- Mensageria
                                 ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK

  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_busca_param_majora 
    --  Sistema  : Emprestimo Pre-Aprovado - Cooperativa de Credito
    --  Sigla    : EMPR
    --  Autor    : Marcos (Envolti)
    --  Data     : Fevereiro/2019                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Busca status da Majoracao Automatica de Credito
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

      -- Variaveis de locais
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);        
    
      --Variaveis Auxiliares
      vr_nrdrowid    ROWID;
      
      vr_flgdesativa NUMBER;
      vr_dtatualiza  DATE;
      vr_idmotivo    NUMBER;
      
      -- Variaveis de Erro
      vr_dscritic  VARCHAR2(1000);
      vr_exc_saida EXCEPTION;
      
    BEGIN
      pr_des_erro := 'OK';
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'ATENDA_CREDITO'
                                ,pr_action => 'pc_mantem_param_majora');
 
      -- Recupera dados de log para consulta posterior
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
      
      -- Direcionar para a rotina genérica
      cada0006.pc_busca_param_pessoa_prod(pr_cdcooper           => vr_cdcooper
                                         ,pr_nrdconta           => pr_nrdconta
                                         ,pr_cdproduto          => 4 -- Cartão
                                         ,pr_cdoperac_produto   => 2 -- Majoração
                                         ,pr_flglibera          => vr_flgdesativa
                                         ,pr_dtvigencia_paramet => vr_dtatualiza
                                         ,pr_idmotivo           => vr_idmotivo
                                         ,pr_dscritic           => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;   
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados/></Root>');

      -- Pre aprovado liberado para o cooperado
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'flgativa'
                            ,pr_tag_cont => vr_flgdesativa
                            ,pr_des_erro => vr_dscritic);
      
      COMMIT;
        
    EXCEPTION        
      WHEN vr_exc_saida THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral em CARTAO_CRED: ' || SQLERRM;
          
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    END;
  END pc_busca_param_majora;
  
  
  -- Mantem párametros de majoracao do cooperado
  PROCEDURE pc_mantem_param_majora(pr_nrdconta              IN crapass.nrdconta%TYPE
                                  -- Mensageria
                                  ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK

  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_mantem_param_majora 
    --  Sistema  : Emprestimo Pre-Aprovado - Cooperativa de Credito
    --  Sigla    : EMPR
    --  Autor    : Marcos (Envolti)
    --  Data     : Fevereiro/2019                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Mantem status da Majoracao Automatica de Credito
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

      -- Variaveis de locais
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);        
    
      --Variaveis Auxiliares
      vr_flgativa NUMBER;
      vr_dtatualiza  DATE;
      vr_idmotivo    NUMBER;
      
      -- Variaveis de Erro
      vr_dscritic  VARCHAR2(1000);
      vr_exc_saida EXCEPTION;
      
    BEGIN
      pr_des_erro := 'OK';
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'ATENDA_CARTAO'
                                ,pr_action => 'pc_mantem_param_majora');

      -- Recupera dados de log para consulta posterior
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
      
      -- Direcionar para a rotina genérica para buscar o valor atual
      cada0006.pc_busca_param_pessoa_prod(pr_cdcooper           => vr_cdcooper
                                         ,pr_nrdconta           => pr_nrdconta
                                         ,pr_cdproduto          => 4 -- Cartão
                                         ,pr_cdoperac_produto   => 2 -- Majoração
                                         ,pr_flglibera          => vr_flgativa
                                         ,pr_dtvigencia_paramet => vr_dtatualiza
                                         ,pr_idmotivo           => vr_idmotivo
                                         ,pr_dscritic           => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;        
      
      -- Inverter 
      IF vr_flgativa = 0 THEN
        vr_flgativa := 1;
      ELSE
        vr_flgativa := 0;
      END IF;
      
      -- Direcionar para rotina genérica
      cada0006.pc_mantem_param_pessoa_prod(pr_cdcooper           => vr_cdcooper
                                          ,pr_nrdconta           => pr_nrdconta
                                          ,pr_cdproduto          => 4 -- Cartão de Crédito
                                          ,pr_cdoperac_produto   => 2 -- Sem Majoração
                                          ,pr_flglibera          => vr_flgativa
                                          ,pr_dtvigencia_paramet => NULL
                                          ,pr_idmotivo           => 72
                                          ,pr_cdoperad           => vr_cdoperad
                                          ,pr_idorigem           => vr_idorigem
                                          ,pr_nmdatela           => vr_nmdatela
                                          ,pr_dscritic           => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF; 
      
      COMMIT;
        
    EXCEPTION        
      WHEN vr_exc_saida THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral em CARTAO_CRED: ' || SQLERRM;
          
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    END;
  END pc_mantem_param_majora;

END TELA_ATENDA_CARTAOCREDITO;
/
