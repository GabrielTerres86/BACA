CREATE OR REPLACE PACKAGE CECRED.EMPR0012 IS

  TYPE typ_cmp_bens IS TABLE OF VARCHAR2(200) 
      INDEX BY VARCHAR2(200);

  TYPE typ_tab_bens IS TABLE OF typ_cmp_bens  -- Associative array type
      INDEX BY PLS_INTEGER;            --  indexed by string

  FUNCTION fn_retorna_comissao_emp(pr_cdcooper IN crawepr.cdcooper%TYPE
                                  ,pr_nrdconta IN crawepr.nrdconta%TYPE
                                  ,pr_nrctremp IN crawepr.nrctremp%TYPE) RETURN NUMBER;
  
  /* Validar dados da inclusão da proposta */               
  PROCEDURE pc_valida_dados_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa do proponente
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta do proponente
                                    ,pr_tpemprst IN NUMBER     --> Tipo de empréstimo
                                    ,pr_cdlcremp IN NUMBER     --> Código da linha de crédito
                                    ,pr_cdfinemp IN NUMBER     --> Código da finalidade
                                    ,pr_dsbensal IN VARCHAR2   --> Bens em alienação 
                                    ,pr_dsbensal_out OUT CLOB  --> Bens em alienação alterados
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE);

  /* Responsável pela montagem do retorna das propostas */
  PROCEDURE pc_monta_retorno_proposta(pr_cdcooper IN crawepr.cdcooper%TYPE  --> Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE  --> PA
                                     ,pr_nrdconta IN crawepr.nrdconta%TYPE  --> Nr. da conta
                                     ,pr_nrctremp IN crawepr.nrctremp%TYPE  --> Nr. contrato
                                     ,pr_nrctaav1 IN crawepr.nrctaav1%TYPE  --> Codigo do avalista 1
                                     ,pr_nrctaav2 IN crawepr.nrctaav2%TYPE  --> Codigo do avalista 2
                                     ,pr_inresapr IN numeric default 1      --> reinicia fluxo
                                     ,pr_idacionamento IN tbgen_webservice_aciona.idacionamento%type
                                     ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK 

   PROCEDURE pc_monta_ret_proposta_json(pr_cdcooper IN crawepr.cdcooper%TYPE  --> Cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE  --> PA
                                       ,pr_nrdconta IN crawepr.nrdconta%TYPE  --> Nr. da conta
                                       ,pr_nrctremp IN crawepr.nrctremp%TYPE  --> Nr. contrato
                                       ,pr_nrctaav1 IN crawepr.nrctaav1%TYPE  --> Codigo do avalista 1
                                       ,pr_nrctaav2 IN crawepr.nrctaav2%TYPE  --> Codigo do avalista 2
                                       ,pr_inresapr IN numeric default 1      --> reinicia fluxo
                                       ,pr_idacionamento IN tbgen_webservice_aciona.idacionamento%type
                                       ,pr_retjson  OUT CLOB                  --> Retorno json proposta
                                       ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

   PROCEDURE pc_valida_dados_integracao(pr_cdcooper  IN NUMBER                 --> Código da cooperativa
                                       ,pr_dsusuari  IN VARCHAR2               --> Usuário
                                       ,pr_dsdsenha  IN VARCHAR2               --> Senha
                                       ,pr_cdcliente IN PLS_INTEGER            --> Código do cliente
                                       ,pr_xmllog    IN VARCHAR2               --> XML com informações de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic  OUT VARCHAR2              --> Descrição da crítica
                                       ,pr_retxml    IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2              --> Nome do Campo
                                       ,pr_des_erro  OUT VARCHAR2);          --> Saida OK/NOK
   
   /* Processa retorno analise motor de credito */
   PROCEDURE pc_processa_analise(pr_cdorigem IN NUMBER                --> Origem da Requisição (9-Esteira ou 5-Ayllos)
                                ,pr_dsprotoc IN VARCHAR2              --> Protocolo da análise
                                ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa da proposta
                                ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da conta da proposta
                                ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero da proposta
                                ,pr_nrtransa IN NUMBER                --> Transacao do acionamento
                                ,pr_dsresana IN VARCHAR2              --> Resultado da análise automática; Contendo as seguintes opções: APROVAR, REPROVAR, DERIVAR ou ERRO
                                ,pr_indrisco IN VARCHAR2              --> Nível do risco calculado para a operação
                                ,pr_nrnotrat IN VARCHAR2              --> Valor do rating calculado para a operação
                                ,pr_nrinfcad IN VARCHAR2              --> Valor do item Informações Cadastrais calculado no Rating
                                ,pr_nrliquid IN VARCHAR2              --> Valor do item Liquidez calculado no Rating
                                ,pr_nrgarope IN VARCHAR2              --> Valor das Garantias calculada no Rating
                                ,pr_nrparlvr IN VARCHAR2              --> Valor do Patrimônio Pessoal Livre calculado no Rating
                                ,pr_nrperger IN VARCHAR2              --> Valor da Percepção Geral da Empresa calculada no Rating
                                ,pr_desscore IN VARCHAR2              --> Descrição do Score Boa Vista
                                ,pr_datscore IN VARCHAR2              --> Data do Score Boa Vista
                                ,pr_flgpreap IN NUMBER                --> Identificador de pre aprovado
                                ,pr_dsrequis IN VARCHAR2              --> Conteúdo da requisição oriunda da Análise Automática na Esteira
                                ,pr_namehost IN VARCHAR2              --> Nome do host oriundo da requisição da Análise Automática na Esteira
                                ,pr_idfluata IN BOOLEAN DEFAULT FALSE --> Indicador Segue Fluxo Atacado -- P637
                                ,pr_scorerat IN VARCHAR2 DEFAULT ''   --> Score Rating -- P450 - 29/07/2019
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);         --> Erros do processo

  --> Rotina responsavel por validar se cooperativa está em contingência
  PROCEDURE pc_verifica_contingencia_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE
                                        ,pr_incdccon OUT tbepr_cdc_parametro.inintegra_cont%TYPE
                                        ,pr_cdcritic OUT NUMBER
                                        ,pr_dscritic OUT VARCHAR2);

  --> Rotina para retorno dos dados do municipio das cooperativas
  PROCEDURE pc_busca_cooperativa_area(pr_dscidade IN VARCHAR2       --> Descricao da cidade
                                     ,pr_retxml   OUT xmltype       --> XML de retorno
                                     ,pr_dscritic OUT VARCHAR2);    --> Retorno de Erro    

  --> Rotina para retorno dos dados do subsegmento
  PROCEDURE pc_retorna_subsegmento(pr_cdsubsegmento  IN tbepr_cdc_subsegmento.cdsubsegmento%type --> Codigo do sub segmento
                                  ,pr_dssubsegmento  IN tbepr_cdc_subsegmento.dssubsegmento%type --> descricao do sub segmento
                                  ,pr_cdsegmento     IN tbepr_cdc_segmento.cdsegmento%type       --> Codigo do segmento
                                  ,pr_dssegmento     IN tbepr_cdc_segmento.dssegmento%type       --> descricao do segmento
                                  ,pr_retorno        OUT xmltype                                 --> XML de retorno
                                  ,pr_dscritic       OUT VARCHAR2);                              --> Retorno de Erro  
                                
                                
  --> Rotina para retorno dos dados do segmento
  PROCEDURE pc_retorna_segmento(pr_cdsegmento   IN tbepr_cdc_segmento.cdsegmento%type  --> Codigo do segmento
                               ,pr_dssegmento   in tbepr_cdc_segmento.dssegmento%type  --> descricao do segmento
                               ,pr_retorno      OUT xmltype                            --> XML de retorno
                               ,pr_dscritic     OUT VARCHAR2);                         --> Retorno de Erro  

  --> Rotina para retorno dos dados do logista
  PROCEDURE pc_retorna_lojista(pr_cdcooper        IN crapcop.cdcooper%TYPE default 0                      --> Cooperativa
                              ,pr_idcooperado_cdc IN tbsite_cooperado_cdc.idcooperado_cdc%type default 0 --> Identificador do cooperado conveniado no cdc
                              ,pr_nmfantasia      IN tbsite_cooperado_cdc.nmfantasia%type default ' '      --> Nome fantasia
                              ,pr_dssubsegmento   IN TBEPR_CDC_SUBSEGMENTO.DSSUBSEGMENTO%type default ' '  -->Subsegmento do lojista
                              ,pr_pagina          IN pls_integer                                    -- número da página desejada 
                              ,pr_limite          IN pls_integer                                    -- limite de linhas desejadas
                              ,pr_retorno         OUT xmltype                                   --> XML de retorno
                              ,pr_dscritic        OUT VARCHAR2);                                --> Retorno de Erro  
                                                              
  --> Rotina atualizar logista
  PROCEDURE pc_atualiza_lojista(pr_idcooperado_cdc in tbsite_cooperado_cdc.idcooperado_cdc%type  --> identificação do lojista
                               ,pr_nmfantasia       in tbsite_cooperado_cdc.nmfantasia%type      --> nome fantasia
                               ,pr_nrcep            in tbsite_cooperado_cdc.nrcep%type           --> cep
                               ,pr_dslogradouro     in tbsite_cooperado_cdc.dslogradouro%type    --> descrição do logradouro
                               ,pr_nrendereco       in tbsite_cooperado_cdc.nrendereco%type      --> numero do endereço
                               ,pr_dscomplemento    in tbsite_cooperado_cdc.dscomplemento%type   --> descrição do complemento
                               ,pr_nmbairro         in tbsite_cooperado_cdc.nmbairro%type        --> nome do bairro
                               ,pr_idcidade         in tbsite_cooperado_cdc.idcidade%type        --> código da cidade
                               ,pr_dsemail          in tbsite_cooperado_cdc.dsemail%type         --> descrição do e-mail
                               ,pr_dstelefone       in tbsite_cooperado_cdc.dstelefone%type      --> descrição do telefone
                               ,pr_dtacectr         in crapcdr.dtacectr%type                     --> Data de aceite do novo contrato
                               ,pr_retorno          OUT xmltype                                  --> XML de retorno
                               ,pr_dscritic         OUT VARCHAR2);                               --> Retorno de Erro   

 
  --> Rotina para retorno dos dados do usuario
  PROCEDURE pc_cadastra_usuario(pr_idusuario        IN tbepr_cdc_usuario.idusuario%type     --> Identificacao do usuario
                               ,pr_dslogin          IN tbepr_cdc_usuario.dslogin%type       --> Login do usuario
                               ,pr_dssenha          IN tbepr_cdc_usuario.dssenha%type       --> Senha do usuario
                               ,pr_dtinsori         IN tbepr_cdc_usuario.dtinsori%type      --> Data de criacao do registro
                               ,pr_flgativo         IN tbepr_cdc_usuario.flgativo%type      --> Flag de controle de ativacao (0-Inativo, 1-Ativo)
							                 ,pr_fladmin          IN tbepr_cdc_usuario.flgadmin%type      --Flag de controle de usuario ADM (0-Nao, 1-Sim)
                               ,pr_idcooperado_cdc  IN tbepr_cdc_usuario_vinculo.idcooperado_cdc%type --> Identificacao do lojista
                               --,pr_idvendedor       IN tbepr_cdc_usuario_vinculo.idvendedor%type      --> Identificacao do vendedor
                               ,pr_nmvendedor       IN tbepr_cdc_vendedor.nmvendedor%type   --> Nome do vendedor
                               ,pr_nrcpf            IN tbepr_cdc_vendedor.nrcpf%type        --> Numero do CPF
                               ,pr_dsemail          IN tbepr_cdc_vendedor.dsemail%type      --> Descricao do email
                               ,pr_idcomissao       IN tbepr_cdc_vendedor.idcomissao%type   --> Comissao
                               ,pr_dscritic         OUT VARCHAR2) ;                         --> Retorno de Erro           --> Retorno de Erro  
                
  --> Rotina para retorno dos dados da comissao
  PROCEDURE pc_retorna_comissao(pr_cdcooper          IN crapepr.cdcooper%type                     --> Codigo que identifica a Cooperativa.
                               ,pr_idcoooperado_cdc  IN tbepr_cdc_emprestimo.idcooperado_cdc%type --> Identificacao do lojista
                               ,pr_idvendedor        IN tbepr_cdc_vendedor.idvendedor%type        --> Identificacao do vendedor
                               ,pr_mes_efetivacao    IN crapepr.dtmvtolt%type                     --> Data do movimento atual.
                               ,pr_tipo_comissao     IN integer                                   --> Tipo de comissao 1-Logista 2-Vendedor
                               ,pr_retorno           OUT xmltype                                  --> XML de retorno
                               ,pr_dscritic          OUT VARCHAR2);                               --> Retorno de Erro  
                              
  --> Rotina para retorno dos dados do produto de credito
  PROCEDURE pc_lista_produto_credito(pr_cdcooper       IN tbepr_cdc_subsegmento_coop.cdcooper%type  --> Código da cooperativa
                                    ,pr_cdsegmento     IN tbepr_cdc_subsegmento.cdsegmento%type     --> Código do segmento
                                    ,pr_cdsubsegmento  IN tbepr_cdc_subsegmento.cdsubsegmento%type  --> Código do subsegmento
                                    --,pr_dssegmento     IN tbepr_cdc_segmento.dssegmento%type        --> Descricao de segmento
                                    --,pr_dssubsegmento  IN tbepr_cdc_subsegmento.dssubsegmento%type  --> Descricao do subsegmento
                                    ,pr_retorno        OUT xmltype                                  --> XML de retorno
                                    ,pr_dscritic       OUT VARCHAR2);                               --> Retorno de Erro
                                   
  --> Cadastra Vendedor
  PROCEDURE pc_manter_vendedor  (pr_idvendedor       IN OUT tbepr_cdc_vendedor.idvendedor%type  --> Identificacao do vendedor
                                ,pr_nmvendedor       IN tbepr_cdc_vendedor.nmvendedor%type      --> Nome do vendedor
                                ,pr_nrcpf            IN tbepr_cdc_vendedor.nrcpf%type           --> Numero do CPF
                                ,pr_dsemail          IN tbepr_cdc_vendedor.dsemail%type         --> Descricao do email
                                ,pr_idcomissao       IN tbepr_cdc_vendedor.idcomissao%type      --> Comissão
                                ,pr_idcooperado_cdc  IN tbepr_cdc_vendedor.idcooperado_cdc%type --> Identificacao do lojista
                                ,pr_dscritic         OUT VARCHAR2);                             --> Retorno de Erro 
                                
  --> Rotina para cadastramento do vendedor
  PROCEDURE pc_cadastra_vendedor(pr_idvendedor        IN tbepr_cdc_vendedor.idvendedor%type      --> Identificacao do vendedor
                                ,pr_nmvendedor        IN tbepr_cdc_vendedor.nmvendedor%type      --> Nome do vendedor
                                ,pr_nrcpf             IN tbepr_cdc_vendedor.nrcpf%type           --> Numero do CPF
                                ,pr_dsemail           IN tbepr_cdc_vendedor.dsemail%type         --> Descricao do email
                                ,pr_idcomissao        IN tbepr_cdc_vendedor.idcomissao%type      --> Comissao
                                ,pr_idcooperado_cdc   IN tbepr_cdc_vendedor.idcooperado_cdc%type --> Identificacao do lojista
                                ,pr_dscritic          OUT VARCHAR2);                             --> Retorno de Erro

  --> Gravar Vendedor do emprestimo
  PROCEDURE pc_manter_empr_cdc_prog (pr_cdcooper         IN tbepr_cdc_emprestimo.cdcooper%type  --> Codigo da cooperativa
                                    ,pr_nrdconta         IN tbepr_cdc_emprestimo.nrdconta%type  --> Numero da conta
                                    ,pr_nrctremp         IN tbepr_cdc_emprestimo.nrctremp%type  --> Numero da proposta
                                    ,pr_cdcoploj         IN tbepr_cdc_emprestimo.cdcooper%type  --> Codigo da cooperativa
                                    ,pr_nrctaloj         IN tbepr_cdc_emprestimo.nrdconta%type  --> Numero da conta                                      
                                    ,pr_dsvendedor       IN varchar2 --> descricao do vendedor
                                    ,pr_vlrepasse        IN tbepr_cdc_emprestimo.vlrepasse%type --> valor de repasse lojista
                                    ,pr_dscritic         OUT VARCHAR2);    
                                    
  --> Inclui Vendedor
  PROCEDURE pc_manter_emprestimo_cdc(pr_cdcooper        IN tbepr_cdc_emprestimo.cdcooper%type   --> Codigo da cooperativa
                                    ,pr_nrdconta        IN tbepr_cdc_emprestimo.nrdconta%type   --> Numero da conta   
                                    ,pr_nrctremp        IN tbepr_cdc_emprestimo.nrctremp%type   --> Numero da proposta
                                    ,pr_idvendedor      IN tbepr_cdc_emprestimo.idvendedor%type --> identificacao do vendedor
                                    ,pr_idcooperado_cdc IN tbepr_cdc_emprestimo.idcooperado_cdc%type  --> Identificacao do lojista
                                    ,pr_vlrepasse       IN tbepr_cdc_emprestimo.vlrepasse%type  --> Valor de repasse pro lojista
                                    ,pr_cdcooper_cred    IN tbepr_cdc_emprestimo.cdcooper_cred%type  --> Codigo da cooperativa de credito
                                    ,pr_nrdconta_cred    IN tbepr_cdc_emprestimo.nrdconta_cred%type  --> Numero da conta de credito
                                    ,pr_dscritic        OUT VARCHAR2) ;                         --> Retorno de OK/NOK 

  --> Rotina para listar do vendedor
  PROCEDURE pc_lista_vendedor(pr_idcooperado_cdc  IN tbepr_cdc_vendedor.idcooperado_cdc%type --> Identificacao do lojista
                             ,pr_idvendedor       IN tbepr_cdc_vendedor.idvendedor%type      --> Identificacao do vendedor
                             ,pr_retorno          OUT xmltype                                --> XML de retorno
                             ,pr_dscritic         OUT VARCHAR2);                             --> Retorno de Erro

  --> Lista Estado
  PROCEDURE pc_retorna_estado_atua(pr_retorno    OUT xmltype       --> XML de retorno
                                  ,pr_dscritic   OUT VARCHAR2);    --> Retorno de Erro 

  --> Lista Municipio
  PROCEDURE pc_retorna_munic_atua(pr_cdestado   IN crapmun.cdestado%type  --> Codigo do estado 
                                 ,pr_retorno    OUT xmltype               --> XML de retorno
                                 ,pr_dscritic   OUT VARCHAR2);            --> Retorno de Erro  
                                 
  --> Login do Logista
  PROCEDURE pc_login_lojista(pr_dslogin    in tbepr_cdc_usuario.dslogin%type  --> Login do usuario
						                ,pr_dssenha    in tbepr_cdc_usuario.dssenha%type  --> Senha do usuario
                            ,pr_dstoken    in tbepr_cdc_usuario.dstoken_ios%type --Token 
                            ,pr_retorno    OUT xmltype                        --> XML de retorno
                            ,pr_dscritic   OUT VARCHAR2);                     --> Retorno de Erro
                        
  --> Rotina para retorno dos dados do logista
  PROCEDURE pc_lista_usuario(pr_idusuario        IN tbepr_cdc_usuario.idusuario%type        --> Identificacao do usuario
                            ,pr_idcooperado_cdc  IN tbepr_cdc_vendedor.idcooperado_cdc%type --> Identificacao do lojista
                            ,pr_retorno          OUT xmltype                                --> XML de retorno
                            ,pr_dscritic         OUT VARCHAR2);                             --> Retorno de Erro

  --> Rotina referente a finalizacao de documento CDC
  PROCEDURE pc_atualiza_doc_digital(pr_dadosxml   in XMLType                --> xml de pendencias 
                                   ,pr_dscritic      OUT VARCHAR2);            --> Retorno de Erro                                                                     

  --> Rotina para gravação de log do cdc
  PROCEDURE pc_grava_log(pr_idlog           IN tbepr_cdc_log.idlog%type      --> Identificacao do log
                        ,pr_dtoperacao      IN tbepr_cdc_log.dtoperacao%type --> Data da operacao
                        ,pr_hroperacao      IN tbepr_cdc_log.hroperacao%type --> Hora da operacao
                        ,pr_nmoperacao      IN tbepr_cdc_log.nmoperacao%type --> Nome da operacao
                        ,pr_dsoperacao      IN tbepr_cdc_log.dsoperacao%type --> Descricao da operacao
                        ,pr_dsorigem        IN tbepr_cdc_log.dsorigem%type   --> Descricao da origem
                        ,pr_idcooperado_cdc IN tbepr_cdc_log.idcooperado_cdc%type --> Identificacao do cooperado
                        ,pr_idusuario       IN tbepr_cdc_log.idusuario%type  --> Identificacao do usuario
                        ,pr_dscritic        OUT VARCHAR2);                   --> Retorno de Erro

  --> Rotina para retorno dos dados da comissao
  PROCEDURE pc_lista_comissao(pr_idcomissao   IN tbepr_cdc_parm_comissao.idcomissao%type  --> Identificacao da comissao
                             ,pr_retorno      OUT xmltype                                 --> XML de retorno
                             ,pr_dscritic     OUT VARCHAR2);                              --> Retorno de Erro 
                               
  --> Rotina para retorno dos dados da comissao
  PROCEDURE pc_recuperar_senha_usuario(pr_dslogin   IN tbepr_cdc_usuario.dslogin%type  --> Login usuario
                                      ,pr_retorno   OUT xmltype                        --> XML de retorno
                                      ,pr_dscritic  OUT VARCHAR2);                     --> Retorno de Erro 

  --> Mudar senha do usuario
  PROCEDURE pc_mudar_senha_usuario(pr_idusuario       in tbepr_cdc_usuario.idusuario%type --> Identificacao do usuario
                                  ,pr_dssenha         in tbepr_cdc_usuario.dssenha%type   --> senha
                                  ,pr_dscritic        OUT VARCHAR2);                      --> Retorno de Erro

  --> Criar Lote
  PROCEDURE pc_cria_lote (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do Movimento
                         ,pr_nrdolote IN craplot.nrdolote%TYPE  --> Numero do Lote
                         ,pr_des_reto OUT VARCHAR2         --> Descrição da crítica do lote
                         ,pr_dscritic OUT VARCHAR);        --> Descrição da crítica

  --> Rotina referente a finalizacao de documento CDC
  PROCEDURE pc_efetuar_repasse_cdc (pr_cdcooper  in crawepr.cdcooper%type  --> cooperativa
                                   ,pr_nrdconta  in crawepr.nrdconta%type  --> numero da conta
                                   ,pr_nrctremp  in crawepr.nrctremp%type  --> numero do contrato
                                   ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2);            --> Descrição da crítica

  --> Gera e-mail
  PROCEDURE pc_gera_email(pr_cdcooper         IN crapepr.cdcooper%type  --> Codigo que identifica a Cooperativa.
                         ,pr_nmdatela         IN VARCHAR2               --> Nome da tela
                         ,pr_dsassunto        IN VARCHAR2               --> Descricao do Assunto
                         ,pr_dsconteudo_mail  IN VARCHAR2               --> Descricao do E-mail
                         ,pr_cdcritic        OUT NUMBER          --> Codigo da critica
                         ,pr_dscritic        OUT VARCHAR2);      --> Descricao da critica

  --> Rotina JOB para finalizacao de documentos
  PROCEDURE pc_efetivar_proposta_cdc(pr_cdcooper  in crawepr.cdcooper%type  --> cooperativa
                                    ,pr_nrdconta  in crawepr.nrdconta%type  --> numero da conta
                                    ,pr_nrctremp  in crawepr.nrctremp%type  --> numero do contrato
                                    ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2);            --> Descrição da crítica

  --> Rotinapara finalizacao de documento CDC
  PROCEDURE pc_job_efetivar_proposta_cdc(pr_cdcritic  OUT PLS_INTEGER     --> Código da crítica
                                        ,pr_dscritic  OUT VARCHAR2);      --> Descrição da crítica

  --> Rotina sera utilizada para chamar a rotina do progress                           
  PROCEDURE pc_crps751 (pr_cdcooper IN crawepr.cdcooper%type
                       ,pr_nrdconta IN crawepr.nrdconta%type
                       ,pr_nrctremp IN crawepr.nrctremp%type
                       ,pr_cdagenci IN crawepr.cdagenci%type
                       ,pr_cdoperad IN crawepr.cdoperad%type
                       ,pr_dtmvtolt IN crawepr.dtmvtolt%type
                       ,pr_dtmvtopr IN crapdat.dtmvtopr%type
                       ,pr_cdcritic OUT crapcri.cdcritic%type
                       ,pr_dscritic OUT crapcri.dscritic%type);
  
  --> Rotina será utilizado para manter as configurações de push dos usuários, ele terá que controla tanto a criação como também a alteração;                                 
  PROCEDURE pc_manter_config_push(pr_idusuario         IN tbepr_cdc_usuario_notifica.idusuario%type        --Identificacao do usuario
  								               ,pr_flgnotifica       IN tbepr_cdc_usuario_notifica.flgnotifica%type       -- Flag de notificacao principal (0-Inativa, 1-Ativa) para todas as notificacao
	  							               ,pr_flgprop_aprovada  IN tbepr_cdc_usuario_notifica.flgprop_aprovada%type  -- Flag de aprovacao da proposta (0-Inativa, 1-Ativa)
                                 ,pr_flgprop_negagada  IN tbepr_cdc_usuario_notifica.flgprop_negagada%type  --Flag de negacao da proposta (0-Inativa, 1-Ativa)
                                 ,pr_flgprop_cancelada IN tbepr_cdc_usuario_notifica.flgprop_cancelada%type --Flag de cancelamento da proposta (0-Inativa, 1-Ativa)
                                 ,pr_flgpgto_efetuado  IN tbepr_cdc_usuario_notifica.flgpgto_efetuado%type  --Flag de pagamento efetuado (0-Inativa, 1-Ativa)
                                 ,pr_flgpgto_analise   IN tbepr_cdc_usuario_notifica.flgpgto_analise%type   --Flag de pagamento em analise (0-Inativa, 1-Ativa)
                                 ,pr_flgpgto_negado    IN tbepr_cdc_usuario_notifica.flgpgto_negado%type    --Flag de pagamento negado (0-Inativa, 1-Ativa)
                                 ,pr_flgpgto_pendente  IN tbepr_cdc_usuario_notifica.flgpgto_pendente%type  --Flag pendente (0-Inativa, 1-Ativa)
                                 ,pr_dscritic          OUT VARCHAR2);
  
  --> Rotina para retorno dos dados do logista
  PROCEDURE pc_consulta_config_push(pr_idusuario IN tbepr_cdc_usuario_notifica.idusuario%type        --> Identificacao do usuario
                                   ,pr_idcooperado_cdc  IN tbepr_cdc_usuario_vinculo.idcooperado_cdc%type --> Identificacao do lojista
                                   ,pr_retorno          OUT xmltype                                --> XML de retorno
                                  ,pr_dscritic         OUT VARCHAR2);                             --> Retorno de Erro                               


  PROCEDURE pc_consulta_pend_proposta(pr_cdcooper in tbepr_cdc_empr_doc.cdcooper%type -- cooperativa
                                     ,pr_ndrconta in tbepr_cdc_empr_doc.nrdconta%type -- conta
                                     ,pr_nrctremp in tbepr_cdc_empr_doc.nrctremp%type -- contrato de emprestimo
                                     ,pr_retorno          OUT xmltype                 --> XML de retorno
                                     ,pr_dscritic         OUT VARCHAR2);             --> Retorno de Erro                                                                    

  PROCEDURE  pc_gravames_proposta_cdc (pr_cdcooper IN crapbpr.cdcooper%TYPE       -- Cód. cooperativa
                                      ,pr_nrdconta IN crapbpr.nrdconta%TYPE       -- Nr. da conta
                                      ,pr_nrctremp IN crapbpr.nrctrpro%TYPE       -- Nr. contrato                                        
                                      ,pr_flaliena OUT INTEGER                    -- Retorna se bem já esta alienado
                                      ,pr_cdcritic OUT INTEGER                    -- Codigo de critica de sistema
                                      ,pr_dscritic OUT VARCHAR2);                -- Descrição da critica de sistema

  PROCEDURE pc_manter_tarifa_adesao_cdc(pr_cdcooper  IN crapcop.cdcooper%TYPE     -- Código da cooperativa do lojista 
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE     -- Número da conta do lojista 
                                       ,pr_flgconve  IN crapcdr.flgconve%TYPE     -- Flag de convenio (1-Sim, 0-Não) 
                                       ,pr_flcnvold  IN crapcdr.flgconve%TYPE     -- Flag de convenio anterior (1-Sim, 0-Não) 
                                       ,pr_flgitctr  IN crapcdr.flgitctr%TYPE     -- Flag de isencao de cobranca de tarifa cdc (0-nao isento, 1-isento)
                                       ,pr_flitctro  IN crapcdr.flgitctr%TYPE     -- Flag de isencao de cobranca de tarifa cdc anterior (0-nao isento, 1-isento)
                                       ,pr_cdoperad  IN crapope.cdoperad%TYPE     -- Operador
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE     -- Código de erro 
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE); -- Descrição de erro

  PROCEDURE pc_manter_tarifa_renovacao_cdc(pr_cdcritic OUT crapcri.cdcritic%TYPE   -- Código de erro 
                                          ,pr_dscritic OUT crapcri.dscritic%TYPE); -- Descrição de erro

  --> Rotina para atualizar situação da propost - Rotina utilizada pelo CDC atraves do barramento                                         
  PROCEDURE pc_altera_situacao_proposta (pr_cdcooper  IN crapcop.cdcooper%TYPE    -- Código da cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE    -- Número da conta
                                        ,pr_nrctremp  IN crawepr.nrdconta%TYPE    -- Número do contrato
                                        ,pr_insitapr  IN crawepr.insitapr%TYPE    -- situação da proposta 
                                        ,pr_insitest  IN crawepr.insitest%TYPE    -- Situação da esteira      
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE    -- Código de erro 
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE);   -- Descrição de erro                                                                        

  PROCEDURE pc_retorna_situacao_ibracred (pr_cdcooper  IN crapcop.cdcooper%TYPE      --> Coodigo Cooperativa
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE      --> Numero da Conta do Associado
                                         ,pr_nrctremp  IN crapepr.nrctremp%TYPE      --> Numero do contrato
                                         ,pr_cdoperad  IN crapope.cdoperad%TYPE      --> Codigo do operador
                                         ,pr_cdsitprp  IN INTEGER                    --> Situação da proposta na IBRACRED
                                         -->> SAIDA
                                         ,pr_cdcritic OUT PLS_INTEGER                --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2                   --> Descrição da crítica
                                         );  
                                         
  PROCEDURE pc_reinicia_fluxo_efetivacao (pr_cdcooper  IN crapcop.cdcooper%TYPE      --> Coodigo Cooperativa
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE      --> Numero da Conta do Associado
                                         ,pr_nrctremp  IN crapepr.nrctremp%TYPE      --> Numero do contrato
                                         -->> SAIDA
                                         ,pr_cdcritic OUT PLS_INTEGER                --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2);               --> Descrição da crítica
  
  PROCEDURE pc_grava_pedencia_emprestimo (pr_cdcooper   IN tbepr_cdc_empr_doc.cdcooper%TYPE      --> Coodigo Cooperativa
                                         ,pr_nrdconta   IN tbepr_cdc_empr_doc.nrdconta%TYPE      --> Numero da Conta do Associado
                                         ,pr_nrctremp   IN tbepr_cdc_empr_doc.nrctremp%TYPE      --> Numero do contrato
                                         ,pr_dstipo_doc IN tbepr_cdc_empr_doc.dstipo_doc%TYPE         --> dstipo_doc
                                         ,pr_dsreprovacao IN tbepr_cdc_empr_doc.dsreprovacao%TYPE     --> dsreprovacao (0-aprovado, 2-nao aprovado)
                                         ,pr_dsobservacao IN tbepr_cdc_empr_doc.dsobservacao%TYPE     --> observacao da reprovacao
                                         -->> SAIDA
                                         ,pr_cdcritic OUT PLS_INTEGER                --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2);               --> Descrição da crítica

  PROCEDURE pc_reg_push_sit_prop_cdc_web (pr_cdcooper   IN tbgen_evento_soa.cdcooper%TYPE      --> Coodigo Cooperativa
                                         ,pr_nrdconta   IN tbgen_evento_soa.nrdconta%TYPE      --> Numero da Conta do Associado
                                         ,pr_nrctremp   IN tbgen_evento_soa.nrctrprp%TYPE      --> Numero do contrato
                                         ,pr_insitpro   IN NUMBER                              --> Situação da proposta
                                         ,pr_xmllog     IN VARCHAR2                            --> XML com informações de LOG
                                         ,pr_cdcritic   OUT PLS_INTEGER                        --> Código da crítica
                                         ,pr_dscritic   OUT VARCHAR2                           --> Descrição da crítica
                                         ,pr_retxml     IN OUT NOCOPY xmltype                  --> Arquivo de retorno do XML
                                         ,pr_nmdcampo   OUT VARCHAR2                           --> Nome do Campo
                                         ,pr_des_erro   OUT VARCHAR2) ;                       --> Saida OK/NOK
  
   PROCEDURE pc_registra_push_sit_prop_cdc (pr_cdcooper   IN tbgen_evento_soa.cdcooper%TYPE     --> Coodigo Cooperativa
                                          ,pr_nrdconta   IN VARCHAR2                            --> Numero da Conta do Associado
                                          ,pr_nrctremp   IN VARCHAR2                            --> Numero do contrato
                                          ,pr_insitpro   IN NUMBER                              --> Situação da proposta
                                          -->> SAIDA
                                          ,pr_cdcritic OUT PLS_INTEGER                          --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2);                           --> Descrição da crítica

  PROCEDURE pc_prepara_push_prop_cdc (pr_cdcooper   IN tbepr_cdc_emprestimo.cdcooper%TYPE      --> Coodigo Cooperativa
                                     ,pr_nrdconta   IN tbepr_cdc_emprestimo.nrdconta%TYPE      --> Numero da Conta do Associado
                                     ,pr_nrctremp   IN tbepr_cdc_emprestimo.nrctremp%TYPE      --> Numero do contrato
                                     ,pr_insitpro   IN NUMBER                                  --> Situação da proposta
                                     -->> SAIDA
                                     ,pr_retorno     OUT xmltype                               --> XML de retorno
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);               --> Descrição da crítica

  PROCEDURE pc_valida_envio_proposta(pr_cdcooper IN NUMBER     --> Código da cooperativa do lojista
																		,pr_nrdconta IN NUMBER     --> Número da conta do lojista
                                    ,pr_insitblq OUT NUMBER     --> 0 bloqueado 1 liberado
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_valida_geracao_contrato (pr_cdcooper  IN crapcop.cdcooper%TYPE    -- Código da cooperativa
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE    -- Número da conta
                                       ,pr_nrctremp  IN crawepr.nrctremp%TYPE    -- Número do contrato
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE    -- Código de erro 
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE);   -- Descrição de erro                              
                                    
  PROCEDURE pc_gera_numero_proposta(pr_cdcooper IN tbgen_evento_soa.cdcooper%TYPE --> Coodigo Cooperativa  
                                   ,pr_nrctremp OUT crawepr.nrctremp%TYPE
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2); --> Descrição da crítica                                                                                              
                                    

END EMPR0012;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0012 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : EMPR0012
  --  Sistema  : Integração CDC x Autorizador
  --  Sigla    : CRED
  --  Autor    : Lucas Reinert
  --  Data     : Outubro - 2017                 Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas para integração do CDC x Autorizador.
  --
  -- Alteracoes: 21/11/2018 - pc_retorna_lojista para usar subsegmento (Fabio - AMcom).
  -- 
  --             29/07/2019 - Adicionada a gravação do Rating após análise da proposta
  --                          no portal do lojista (Luiz Otávio Olinger Momm - AMCOM).
  --
  --             31/07/2019 - Adicionada a efetivação do Rating ao efetiver uma proposta
  --                          do CDC com validação de Endividamento do cooperado
  --                          (Luiz Otávio Olinger Momm - AMCOM).
  --
  ---------------------------------------------------------------------------

  FUNCTION fn_retorna_chassi_seq(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN VARCHAR2 IS --> Cooperativa
  /* .............................................................................
    Programa: fn_retorna_chassi_seq
    Sistema : Integração CDC x Autorizador
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : Novembro/2017                       Ultima atualizacao: 
      
    Dados referentes ao programa:
      
    Frequencia: Sempre que for chamado
    Objetivo  : Function para retornar nr. do chassi ficticio
      
    Alteracoes: 
  ............................................................................. */
    -- Variáveis auxiliáres
    vr_nrchassi VARCHAR2(40);
  BEGIN
    -- Buscar nr. do chassi
    vr_nrchassi := 'CDC' 
                || to_char(pr_cdcooper, 'fm000') 
                || to_char(SEQEPR_DSCHASSI.nextval,'fm00000000000');
    -- Retornar chassi
    RETURN vr_nrchassi;
  END fn_retorna_chassi_seq;
  
  FUNCTION fn_retorna_comissao_emp(pr_cdcooper IN crawepr.cdcooper%TYPE
                                  ,pr_nrdconta IN crawepr.nrdconta%TYPE
                                  ,pr_nrctremp IN crawepr.nrctremp%TYPE) RETURN NUMBER IS
  /* .............................................................................
    Programa: fn_retorna_chassi_seq
    Sistema : Integração CDC x Autorizador
    Sigla   : CRED
    Autor   : Rafael Faria (Supero)
    Data    : Agosto/2018                       Ultima atualizacao: 
      
    Dados referentes ao programa:
      
    Frequencia: Sempre que for chamado
    Objetivo  : Function para retornar o valor de uma comissao de uma proposta
      
    Alteracoes: 
  ............................................................................. */
    cursor cr_crawepr is
      select epr.vlemprst
            ,tcc.idcomissao
        from crawepr epr
            ,tbepr_cdc_emprestimo tce
            ,tbsite_cooperado_cdc tcc
       where epr.cdcooper = pr_cdcooper
         and epr.nrdconta = pr_nrdconta         
         and epr.nrctremp = pr_nrctremp
         and epr.cdcooper = tce.cdcooper
         and epr.nrdconta = tce.nrdconta         
         and epr.nrctremp = tce.nrctremp
         and tce.idcooperado_cdc = tcc.idcooperado_cdc;
    rw_crawepr cr_crawepr%ROWTYPE;
    
    cursor cr_comissao (pr_idcomissao IN tbepr_cdc_parm_comissao.idcomissao%type
                       ,pr_vlemprst IN crawepr.vlemprst%type) is
      select decode(tcpc.tpcomissao,1,tcpcr.vlcomissao,round(((tcpcr.vlcomissao*pr_vlemprst)/100),2))  vlcomemp
        from tbepr_cdc_parm_comissao  tcpc
            ,tbepr_cdc_parm_comissao_regra tcpcr
       where tcpc.idcomissao = pr_idcomissao
         and tcpc.idcomissao = tcpcr.idcomissao
         and pr_vlemprst between tcpcr.vlinicial and tcpcr.vlfinal;
    rw_comissao cr_comissao%ROWTYPE;

    -- Variáveis auxiliáres
    vr_vlcomemp NUMBER(25,2)  := 0;
    
  BEGIN
    -- Buscar nr. do chassi
    OPEN cr_crawepr;
    FETCH cr_crawepr INTO rw_crawepr;

    IF cr_crawepr%FOUND THEN
      OPEN cr_comissao (pr_idcomissao    => rw_crawepr.idcomissao
                       ,pr_vlemprst      => rw_crawepr.vlemprst);
      FETCH cr_comissao INTO rw_comissao;

      IF cr_comissao%FOUND THEN
        vr_vlcomemp := rw_comissao.vlcomemp;
      END IF;
      CLOSE cr_comissao;

    END IF;
    CLOSE cr_crawepr;
    
    RETURN vr_vlcomemp;
  END fn_retorna_comissao_emp;
  
  PROCEDURE pc_valida_dados_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa do proponente
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta do proponente
                                    ,pr_tpemprst IN NUMBER     --> Tipo de empréstimo
                                    ,pr_cdlcremp IN NUMBER     --> Código da linha de crédito
                                    ,pr_cdfinemp IN NUMBER     --> Código da finalidade
                                    ,pr_dsbensal IN VARCHAR2   --> Bens em alienação 
                                    ,pr_dsbensal_out OUT CLOB  --> Bens em alienação alterados
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  /* .............................................................................
    Programa: pc_valida_dados_proposta
    Sistema : Integração CDC x Autorizador
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : Outubro/2017                       Ultima atualizacao: 
      
    Dados referentes ao programa:
      
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina responsável por validar a inclusão da proposta.
      
    Alteracoes: 
  ............................................................................. */
  
    -- Variáveis para tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variáveis auxiliares
    vr_nrchassi  VARCHAR2(40);
    vr_dsbensal_out  CLOB;

     -- data das coopeativas
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -- Verficar tipo de finalidade
    CURSOR cr_crapfin(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
      SELECT 1
        FROM crapfin fin
       WHERE fin.cdcooper = pr_cdcooper
         AND fin.cdfinemp = pr_cdfinemp
         AND fin.flgstfin = 1
         AND fin.tpfinali = 3; -- CDC
    rw_crapfin cr_crapfin%ROWTYPE;
    
    -- Verificar se a linha de crédito está em uma finalidade CDC
    CURSOR cr_craplch(pr_cdcooper IN craplch.cdcooper%TYPE
                     ,pr_cdfinemp IN craplch.cdfinemp%TYPE
                     ,pr_cdlcremp IN craplch.cdlcrhab%TYPE) IS
      SELECT 1
        FROM craplch lch,
             crapfin fin
       WHERE lch.cdcooper = pr_cdcooper
         AND lch.cdlcrhab = pr_cdlcremp
         AND lch.cdfinemp = pr_cdfinemp
         AND fin.cdcooper = lch.cdcooper
         AND fin.cdfinemp = lch.cdfinemp
         AND fin.flgstfin = 1
         AND fin.tpfinali = 3; -- CDC
    rw_craplch cr_craplch%ROWTYPE;
    
    -- Percorrer os bens alienados
    CURSOR cr_dsbensal IS
      SELECT trim(regexp_substr(texto, '[^\;]+', 1, 1)) categoriaBem
            ,trim(regexp_substr(texto, '[^\;]+', 1, 2)) descricaoFinalidadeBem
            ,coalesce(trim(regexp_substr(texto, '[^\;]+', 1, 3)),'BRANCO') corBem
            ,trim(regexp_substr(texto, '[^\;]+', 1, 4)) valorMercadoBem
            ,trim(regexp_substr(texto, '[^\;]+', 1, 5)) chassiBem
            ,trim(regexp_substr(texto, '[^\;]+', 1, 6)) anoFabricacaoBem
            ,trim(regexp_substr(texto, '[^\;]+', 1, 7)) anoModeloBem
            ,coalesce(trim(regexp_substr(texto, '[^\;]+', 1, 8)),'ABC1234') numeroPlaca
            ,coalesce(trim(regexp_substr(texto, '[^\;]+', 1, 9)),'123456789') numeroRenavam
            ,coalesce(trim(regexp_substr(texto, '[^\;]+', 1, 10)),'2') tipoChassi
            ,coalesce(trim(regexp_substr(texto, '[^\;]+', 1, 11)),'SC') UFPlaca
            ,trim(regexp_substr(texto, '[^\;]+', 1, 12)) documentoProprietario
            ,coalesce(trim(regexp_substr(texto, '[^\;]+', 1, 13)),'SC') UFLicenciamento
            ,decode(trim(regexp_substr(texto, '[^\;]+', 1, 14)),'1','ZERO KM','USADO') tipoBem
            ,trim(regexp_substr(texto, '[^\;]+', 1, 15)) identificacaoBem            
      FROM (      
        SELECT regexp_substr(pr_dsbensal, '[^|]+', 1, LEVEL) texto
          FROM dual
        CONNECT BY LEVEL <= regexp_count(pr_dsbensal, '[^|]+')
      );
    
  BEGIN
       
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
       
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    IF pr_tpemprst <> 1 THEN
      -- Gerar crítica
      vr_cdcritic    := 0;
      vr_dscritic    := 'Tipo de emprestimo invalido';
      -- Levantar exceção
      RAISE vr_exc_erro;      
    END IF;
   
    -- Verificar se finalidade de empréstimo é do tipo CDC
    OPEN cr_crapfin(pr_cdcooper => pr_cdcooper
                   ,pr_cdfinemp => pr_cdfinemp);
    FETCH cr_crapfin INTO rw_crapfin;
    
    -- Se não encontrou
    IF cr_crapfin%NOTFOUND THEN
      -- Fechar cursor
      CLOSE cr_crapfin;
      -- Gerar crítica
      vr_cdcritic    := 0;
      vr_dscritic    := 'Finalidade de emprestimo invalida.';
      -- Levantar exceção
      RAISE vr_exc_erro;            
    END IF;

    -- Verificar se linha de crédito pertence a finalidade CDC
    OPEN cr_craplch(pr_cdcooper => pr_cdcooper
                   ,pr_cdfinemp => pr_cdfinemp
                   ,pr_cdlcremp => pr_cdlcremp);
    FETCH cr_craplch INTO rw_craplch;

    -- Se não encontrou
    IF cr_crapfin%NOTFOUND THEN
      -- Fechar cursor
      CLOSE cr_crapfin;
      -- Gerar crítica
      vr_cdcritic    := 0;
      vr_dscritic    := 'Linha de credito invalida.';
      -- Levantar exceção
      RAISE vr_exc_erro;            
    END IF;
    
    -- Percorrer bens em alienação
    FOR rw_dsbensal IN cr_dsbensal LOOP
      -- O tipo do chassi deve ser sempre 2 (Normal)
      IF rw_dsbensal.tipoChassi <> '2' THEN
        -- Gerar crítica
        vr_cdcritic    := 0;
        vr_dscritic    := 'Tipo do Chassi invalido.';
        -- Levantar exceção
        RAISE vr_exc_erro;                    
      END IF;
      
      -- Se não possuir nr. do chassi
      IF rw_dsbensal.chassibem IS NULL THEN
        -- Devemos buscar o número do chassi
        vr_nrchassi := fn_retorna_chassi_seq(pr_cdcooper => pr_cdcooper);
      ELSE 
        -- Recebe o valor do chassi recebido
        vr_nrchassi := rw_dsbensal.chassibem;
      END IF;
      -- Preparar o retorno dos bens alienados
      vr_dsbensal_out := nvl(vr_dsbensal_out, '')
                      || rw_dsbensal.categoriaBem
                      || ';' || rw_dsbensal.descricaoFinalidadeBem
                      || ';' || rw_dsbensal.corBem
                      || ';' || TO_NUMBER(rw_dsbensal.valorMercadoBem, '999999999999999.99')
                      || ';' || vr_nrchassi
                      || ';' || rw_dsbensal.anoFabricacaoBem
                      || ';' || rw_dsbensal.anoModeloBem
                      || ';' || rw_dsbensal.numeroPlaca
                      || ';' || rw_dsbensal.numeroRenavam
                      || ';' || rw_dsbensal.tipoChassi
                      || ';' || rw_dsbensal.UFPlaca
                      || ';' || rw_dsbensal.documentoProprietario
                      || ';' || rw_dsbensal.UFLicenciamento
                      || ';' || rw_dsbensal.tipoBem
                      || ';' || rw_dsbensal.identificacaoBem || '|';
    END LOOP;
    
    -- Retornar bens alienados alterados
    pr_dsbensal_out := vr_dsbensal_out;
  EXCEPTION
    WHEN vr_exc_erro THEN    
      -- Atribuir críticas
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral do sistema ' || SQLERRM;
                                        
  END pc_valida_dados_proposta;
  
  PROCEDURE pc_monta_ret_proposta_json(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> PA
                                      ,pr_nrdconta IN crawepr.nrdconta%TYPE  --> Nr. da conta
                                      ,pr_nrctremp IN crawepr.nrctremp%TYPE  --> Nr. contrato
                                      ,pr_nrctaav1 IN crawepr.nrctaav1%TYPE  --> Codigo do avalista 1
                                      ,pr_nrctaav2 IN crawepr.nrctaav2%TYPE  --> Codigo do avalista 2
                                      ,pr_inresapr IN numeric default 1      --> reinicia fluxo
                                      ,pr_idacionamento IN tbgen_webservice_aciona.idacionamento%type
                                      ,pr_retjson  OUT CLOB                  --> Retorno json proposta
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica

  /* .............................................................................
    Programa: pc_monta_ret_proposta_json
    Sistema : Integração CDC x Autorizador
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : Novembro/2017                       Ultima atualizacao: 
      
    Dados referentes ao programa:
      
    Frequencia: Sempre que for chamado
    Objetivo  : Montar retorno da proposta criada para envio de dados a Ibratan para a 
                chamada do Motor de Crédito
      
    Alteracoes: 
  ............................................................................. */
  
    -- Variáveis para tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    vr_dsjsonan json;
    vr_dsjsonan_clob CLOB;

    vr_cdstatus_http tbgen_webservice_aciona.cdstatus_http%type := 200; -- sucesso
    vr_flgreenvia    tbgen_webservice_aciona.flgreenvia%type := 0; -- nao

    BEGIN
      -- Enviar proposta para análise no motor
      este0002.pc_gera_json_analise(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctremp => pr_nrctremp
                                   ,pr_nrctaav1 => pr_nrctaav1
                                   ,pr_nrctaav2 => pr_nrctaav2
                                   ,pr_dsjsonan => vr_dsjsonan
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
            
      -- Se retornou alguma crítica                       
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levantar exceção
        RAISE vr_exc_erro;
      END IF;
      
      IF pr_inresapr=1 THEN
        BEGIN
          update crawepr wpr
             set wpr.insitest = 1 -- enviado para analise automatica
                ,wpr.insitapr = 0
                ,wpr.cdopeapr = NULL
                ,wpr.dtaprova = NULL
                ,wpr.hraprova = 0
           where wpr.cdcooper=pr_cdcooper
             and wpr.nrdconta=pr_nrdconta
             and wpr.nrctremp=pr_nrctremp;
          EXCEPTION    
            WHEN OTHERS THEN
              vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da Análise Automática de Crédito: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      END IF;

      -- Criar o CLOB para converter JSON para CLOB
      dbms_lob.createtemporary(vr_dsjsonan_clob, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_dsjsonan_clob, dbms_lob.lob_readwrite);
      json.to_clob(vr_dsjsonan,vr_dsjsonan_clob);

       -- atualiza acionamento com sucesso
      webs0003.pc_atualiza_acionamento(pr_cdstatus_http => vr_cdstatus_http
                                      ,pr_nrctrprp => pr_nrctremp
                                      ,pr_flgreenvia => vr_flgreenvia
                                      ,pr_idacionamento => pr_idacionamento
                                      ,pr_dsresposta_requisicao => vr_dsjsonan_clob
                                      ,pr_dscritic => vr_dscritic);
                                      
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_erro;
      END IF;

      --> Atribuir JSON para o parametro
      pr_retjson := vr_dsjsonan_clob;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_dsjsonan_clob);
      dbms_lob.freetemporary(vr_dsjsonan_clob);                        
            
    EXCEPTION
      WHEN vr_exc_erro THEN    
        -- Se crítica possui código e não tem descrição
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
          -- Buscar descrição da crítica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
      
        -- Atribuir críticas
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0007.fn_caract_acento(vr_dscritic);
        
      WHEN OTHERS THEN      
        -- Erro
        pr_cdcritic := 0;
        pr_dscritic := gene0007.fn_caract_acento('Erro geral ao gerar retorno da proposta: ' || SQLERRM);

  END pc_monta_ret_proposta_json;

  
  PROCEDURE pc_monta_retorno_proposta(pr_cdcooper IN crawepr.cdcooper%TYPE  --> Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE  --> PA
                                     ,pr_nrdconta IN crawepr.nrdconta%TYPE   --> Nr. da conta
                                     ,pr_nrctremp IN crawepr.nrctremp%TYPE  --> Nr. contrato
                                     ,pr_nrctaav1 IN crawepr.nrctaav1%TYPE  --> Codigo do avalista 1
                                     ,pr_nrctaav2 IN crawepr.nrctaav2%TYPE  --> Codigo do avalista 2
                                     ,pr_inresapr IN numeric default 1      --> reinicia fluxo
                                     ,pr_idacionamento IN tbgen_webservice_aciona.idacionamento%type
                                     ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK

  /* .............................................................................
    Programa: pc_monta_retorno_proposta
    Sistema : Integração CDC x Autorizador
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : Novembro/2017                       Ultima atualizacao: 
      
    Dados referentes ao programa:
      
    Frequencia: Sempre que for chamado
    Objetivo  : Montar retorno da proposta criada para envio de dados a Ibratan para a 
                chamada do Motor de Crédito
      
    Alteracoes: 26/07/2019 - Adicionado rotina para ler o JSON de retorno e atualiza
                             os dados do Rating enviado pela IBRATAN - P450
                             (Luiz Otávio Olinger Momm - AMCOM)
  ............................................................................. */
  
    -- Variáveis para tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    vr_dsjsonan_clob CLOB;
    
    BEGIN
    
      pc_monta_ret_proposta_json( pr_cdcooper => pr_cdcooper      --> Cooperativa
                                 ,pr_cdagenci => pr_cdagenci      --> PA
                                 ,pr_nrdconta => pr_nrdconta      --> Nr. da conta
                                 ,pr_nrctremp => pr_nrctremp      --> Nr. contrato
                                 ,pr_nrctaav1 => pr_nrctaav1      --> Avalista 1
                                 ,pr_nrctaav2 => pr_nrctaav2      --> Avalista 2
                                 ,pr_inresapr => pr_inresapr      --> reinicia fluxo
                                 ,pr_idacionamento => pr_idacionamento --> acionamento
                                 ,pr_retjson  => vr_dsjsonan_clob --> Retorno json proposta
                                 ,pr_cdcritic => vr_cdcritic      --> Código da crítica
                                 ,pr_dscritic => vr_dscritic);   --> Descrição da crítica

      -- Retornar para o XML
      pr_retxml := XMLType.createXML('<Root><Dados><dsjsonan><![CDATA[' || vr_dsjsonan_clob ||']]></dsjsonan></Dados></Root>');
                      
            
    EXCEPTION
      WHEN vr_exc_erro THEN    
        -- Se crítica possui código e não tem descrição
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
          -- Buscar descrição da crítica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
      
        -- Atribuir críticas
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
      WHEN OTHERS THEN      
        -- Erro
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral do sistema ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_monta_retorno_proposta;
  
  PROCEDURE pc_valida_dados_integracao(pr_cdcooper  IN NUMBER                 --> Código da cooperativa
                                      ,pr_dsusuari  IN VARCHAR2               --> Usuário
                                      ,pr_dsdsenha  IN VARCHAR2               --> Senha
                                      ,pr_cdcliente IN PLS_INTEGER            --> Código do cliente
                                      ,pr_xmllog    IN VARCHAR2               --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2              --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2              --> Nome do Campo
                                      ,pr_des_erro  OUT VARCHAR2) IS          --> Saida OK/NOK
  /* .............................................................................
    Programa: pc_valida_gravames
    Sistema : Integração CDC x Autorizador
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : Janeiro/2018                       Ultima atualizacao: 
      
    Dados referentes ao programa:
      
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina responsável por validar os serviços de integração CDC.
      
    Alteracoes: 
  ............................................................................. */
  
    -- Variáveis para tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Buscar usuário e senha da Ibratan
    CURSOR cr_cliente_cdc IS
      SELECT cli.idtoken
            ,cli.dstoken
       FROM tbgen_webservice_cliente cli
      WHERE cli.cdcliente = pr_cdcliente;
    rw_cliente_cdc cr_cliente_cdc%ROWTYPE;
  
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
  BEGIN
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;  
    
    -- Se está rodando o processo noturno
    IF rw_crapdat.inproces > 1 THEN
      -- Gerar crítica
      vr_cdcritic := 0;
      vr_dscritic := 'Sistema indisponível';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;
    
    -- Buscar usuário e senha
    OPEN cr_cliente_cdc;
    FETCH cr_cliente_cdc INTO rw_cliente_cdc;
  
    -- Se não encontrou 
    IF cr_cliente_cdc%NOTFOUND THEN
      -- Fechar cursor
      CLOSE cr_cliente_cdc;
      -- Gerar crítica
      vr_cdcritic := 0;
      vr_dscritic := 'Cliente não cadastrado';
      -- Levantar execeção
      RAISE vr_exc_erro;
    END IF;
    -- Fechar cursor
    CLOSE cr_cliente_cdc;
    
    -- Usuário diferente do parametrizado
    IF pr_dsusuari <> rw_cliente_cdc.idtoken THEN
      -- Gerar crítica
      vr_cdcritic := 0;
      vr_dscritic := 'Usuário ou senha inválidos';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;
    
    -- Senha diferente do parametrizado
    IF pr_dsdsenha <> rw_cliente_cdc.dstoken THEN
      -- Gerar crítica
      vr_cdcritic := 0;
      vr_dscritic := 'Usuário ou senha inválidos';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN    
      -- Atribuir críticas
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral do sistema ' || SQLERRM;
      
      -- Efetuar rollback
      ROLLBACK;                                        
  END pc_valida_dados_integracao;
  
    --> Rotina responsavel por reenviar os acionamentos com erro
    
  --> responsavel por processar o retorno da analise do motor de credito
  PROCEDURE pc_processa_analise(pr_cdorigem IN NUMBER                --> Origem da Requisição (9-Esteira ou 5-Ayllos)
                               ,pr_dsprotoc IN VARCHAR2              --> Protocolo da análise
                               ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa da proposta
                               ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da conta da proposta
                               ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero da proposta
                               ,pr_nrtransa IN NUMBER                --> Transacao do acionamento
                               ,pr_dsresana IN VARCHAR2              --> Resultado da análise automática; Contendo as seguintes opções: APROVAR, REPROVAR, DERIVAR ou ERRO
                               ,pr_indrisco IN VARCHAR2              --> Nível do risco calculado para a operação
                               ,pr_nrnotrat IN VARCHAR2              --> Valor do rating calculado para a operação
                               ,pr_nrinfcad IN VARCHAR2              --> Valor do item Informações Cadastrais calculado no Rating
                               ,pr_nrliquid IN VARCHAR2              --> Valor do item Liquidez calculado no Rating
                               ,pr_nrgarope IN VARCHAR2              --> Valor das Garantias calculada no Rating
                               ,pr_nrparlvr IN VARCHAR2              --> Valor do Patrimônio Pessoal Livre calculado no Rating
                               ,pr_nrperger IN VARCHAR2              --> Valor da Percepção Geral da Empresa calculada no Rating
                               ,pr_desscore IN VARCHAR2              --> Descrição do Score Boa Vista
                               ,pr_datscore IN VARCHAR2              --> Data do Score Boa Vista
                               ,pr_flgpreap IN NUMBER                --> Identificador de pre aprovado
                               ,pr_dsrequis IN VARCHAR2              --> Conteúdo da requisição oriunda da Análise Automática na Esteira
                               ,pr_namehost IN VARCHAR2              --> Nome do host oriundo da requisição da Análise Automática na Esteira
                               ,pr_idfluata IN BOOLEAN DEFAULT FALSE --> Indicador Segue Fluxo Atacado -- P637
                               ,pr_scorerat IN VARCHAR2 DEFAULT ''   --> Score Rating -- P450 - 29/07/2019 
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
  /* .............................................................................
   Programa: pc_processa_analise
   Sistema : Rotina integracao CDC
   Sigla   : WEBS
   Autor   : Lucas Reinert
   Data    : Janeiro/17.                    Ultima atualizacao:

   Dados referentes ao programa: 
   
   Frequencia: Sempre que for executado o servico de analise

   Objetivo  : Processar o retorno do motor de credito integracao cdc

   Observacao: 
     
   Alteracoes: 18/04/2019 - Incluido novo campo segueFluxoAtacado no retorno do motor de credito
			   P637 - Luciano Kienolt - Supero

               29/07/2019 - Adicionada a gravação do Rating após análise da proposta
                           no portal do lojista (Luiz Otávio Olinger Momm - AMCOM).

   ..............................................................................*/  
   DECLARE
     -- Tratamento de críticas
     vr_exc_saida EXCEPTION;
     vr_cdcritic PLS_INTEGER;
     vr_dscritic VARCHAR2(4000);
     vr_des_reto VARCHAR2(10);
      
     -- Variáveis auxiliares
     vr_msg_detalhe    VARCHAR2(10000);      --> Detalhe da mensagem    
     vr_status         PLS_INTEGER;          --> Status
     vr_des_reto_web   VARCHAR2(10);
     vr_nrtransacao    NUMBER(25) := 0;      --> Numero da transacao
     vr_inpessoa       PLS_INTEGER := 0;     --> 1 - PF/ 2 - PJ
     vr_nrcpfcnpj_base NUMBER(15) := 0;      --> CPF/CNPJ base
     vr_insitapr       crawepr.insitapr%TYPE; --> Situacao Aprovacao(0-Em estudo/1-Aprovado/2-Nao aprovado/3-Restricao/4-Refazer)
      
     -- Buscar a proposta de empréstimo vinculada ao protocolo
     CURSOR cr_crawepr(pr_cdcooper crawepr.cdcooper%TYPE
                      ,pr_nrdconta crawepr.nrdconta%TYPE
                      ,pr_nrctremp crawepr.nrctremp%TYPE) IS
        SELECT wpr.cdcooper
              ,wpr.nrdconta
              ,wpr.nrctremp
              ,wpr.cdagenci
              ,wpr.cdopeste
              ,wpr.insitest
              ,decode(wpr.insitapr, 0, 'EM ESTUDO', 1, 'APROVADO', 2, 'NAO APROVADO', 3, 'RESTRICAO', 4, 'REFAZER', 'SITUACAO DESCONHECIDA') dssitapr
              ,wpr.idfluata -- P637              
              ,wpr.rowid
          FROM crawepr wpr
         WHERE wpr.cdcooper = pr_cdcooper
           AND wpr.nrdconta = pr_nrdconta
           AND wpr.nrctremp = pr_nrctremp;  
      rw_crawepr cr_crawepr%ROWTYPE;
      
     -- Buscar o tipo de pessoa que contratou o empréstimo
     CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
     SELECT ass.inpessoa
           ,ass.nrcpfcnpj_base     -- P450 - 29/07/2019
       FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;
     rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
    -- Variaveis temp para ajuste valores recebidos nos indicadores
    vr_indrisco           VARCHAR2(100); --> Nível do risco calculado para a operação
    vr_nrnotrat           VARCHAR2(100); --> Valor do rating calculado para a operação
    vr_nrinfcad           VARCHAR2(100); --> Valor do item Informações Cadastrais calculado no Rating
    vr_nrliquid           VARCHAR2(100); --> Valor do item Liquidez calculado no Rating
    vr_nrgarope           VARCHAR2(100); --> Valor das Garantias calculada no Rating
    vr_nrparlvr           VARCHAR2(100); --> Valor do Patrimônio Pessoal Livre calculado no Rating
    vr_nrperger           VARCHAR2(100); --> Valor da Percepção Geral da Empresa calculada no Rating
    vr_desscore           VARCHAR2(100); --> Descricao do Score Boa Vista
    vr_datscore           VARCHAR2(100); --> Data do Score Boa Vista
    vr_idfluata           BOOLEAN;       --> Segue Fluxo Atacado -- P637
    vr_scorerat           VARCHAR2(100); --> Score Rating -- P450 - 29/07/2019
    vr_innivel_rating     NUMBER(5);     --> Score Rating -- P450 - 29/07/2019
    vr_desc_nivel_rating  VARCHAR2(100); --> Descrição do nível do Rating -- P450 - 29/07/2019
    vr_in_risco_rat       INTEGER;       --> Descrição do nível do Rating -- P450 - 29/07/2019

    -- Função para verificar se parâmetro passado é numérico
    FUNCTION fn_is_number(pr_vlparam IN VARCHAR2) RETURN BOOLEAN IS
      BEGIN
        IF TRIM(gene0002.fn_char_para_number(pr_vlparam)) IS NULL THEN
          RETURN FALSE;
        ELSE
          RETURN TRUE;
        END IF;  
      EXCEPTION
        WHEN OTHERS THEN
          RETURN FALSE;
    END fn_is_number;
      
    -- Função para verificar se parâmetro passado é Data
    FUNCTION fn_is_date(pr_vlparam IN VARCHAR2) RETURN BOOLEAN IS
      vr_data date;
      BEGIN
        vr_data := TO_DATE(pr_vlparam,'RRRRMMDD');
          IF vr_data IS NULL THEN 
            RETURN FALSE;
          ELSE
            RETURN TRUE;  
          END IF;  
      EXCEPTION
        WHEN OTHERS THEN
          RETURN FALSE;
    END fn_is_date;
      
    -- Função para trocar o litereal "null" por null
    FUNCTION fn_converte_null(pr_dsvaltxt IN VARCHAR2) RETURN VARCHAR2 IS
      BEGIN
        IF pr_dsvaltxt = 'null' THEN
          RETURN NULL;
        ELSE
          RETURN pr_dsvaltxt;
         END IF;
      END;
                 
    BEGIN

    -- Se o acionamento já foi gravado na origem
    IF nvl(pr_nrtransa,0) > 0 THEN
      vr_nrtransacao := pr_nrtransa;
    END IF;  
    
    -- Buscar a proposta de empréstimo a partir do protocolo
    OPEN cr_crawepr(pr_cdcooper
                   ,pr_nrdconta
                   ,pr_nrctremp);

    FETCH cr_crawepr INTO rw_crawepr;
      
    -- Se não encontrou a proposta
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      -- Montar mensagem de critica
      vr_status      := 500;
      vr_cdcritic    := 978;
      vr_msg_detalhe := 'Retorno Analise Automatica nao foi atualizado, ocorreu erro interno no sistema(1)';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crawepr;

    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crawepr.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_status      := 500;
      vr_cdcritic    := 978;
      vr_msg_detalhe := 'Retorno Analise Automatica nao foi atualizado, ocorreu erro interno no sistema(2)';
      RAISE vr_exc_saida;
    END IF;
    
    -- Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;

    -- Condicao para verificar se o processo esta rodando
    IF NVL(rw_crapdat.inproces,0) <> 1 THEN
      -- Montar mensagem de critica
      vr_status      := 400;
      vr_cdcritic    := 138;
      vr_msg_detalhe := 'Retorno Analise Automatica nao foi atualizado, o processo batch AIMARO esta em execucao.';
      RAISE vr_exc_saida;
    END IF;  
      
      
    -- Se algum dos parâmetros abaixo não foram informados
			IF nvl(pr_cdorigem, 0) = 0 OR
				 TRIM(pr_dsprotoc) IS NULL OR
				 TRIM(pr_dsresana) IS NULL THEN
        -- Montar mensagem de critica
        vr_status      := 500;
        vr_cdcritic    := 978;
        vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu '
                       || 'erro interno no sistema(4)';
        RAISE vr_exc_saida;
		  END IF;

    -- Se os parâmetros abaixo possuirem algum valor diferente do verificado
    IF NOT pr_cdorigem IN(5,9) OR NOT lower(pr_dsresana) IN('aprovar', 'aprovar_auto', 'reprovar', 'derivar', 'erro') THEN
      -- Montar mensagem de critica
      vr_status      := 500;
      vr_cdcritic    := 978;
      vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(5)';
      RAISE vr_exc_saida;
    END IF;
      
    -- Copia dos valores dos parâmetros para variaveis já corrigindo
    -- possiveis problemas com a vinda de parâmetros "null"
    vr_indrisco := fn_converte_null(pr_indrisco);
    vr_nrnotrat := fn_converte_null(pr_nrnotrat);
    vr_nrinfcad := fn_converte_null(pr_nrinfcad);
    vr_nrliquid := fn_converte_null(pr_nrliquid);
    vr_nrgarope := fn_converte_null(pr_nrgarope);
    vr_nrparlvr := fn_converte_null(pr_nrparlvr);
    vr_nrperger := fn_converte_null(pr_nrperger);
    vr_desscore := fn_converte_null(pr_desscore);
    vr_datscore := fn_converte_null(pr_datscore);
    vr_scorerat := fn_converte_null(pr_scorerat); -- P450 - 29/07/2019
      
    -- Buscar o tipo de pessoa
    OPEN cr_crapass(pr_cdcooper => rw_crawepr.cdcooper
                   ,pr_nrdconta => rw_crawepr.nrdconta);
    FETCH cr_crapass INTO vr_inpessoa, vr_nrcpfcnpj_base;
    CLOSE cr_crapass;
      
    IF lower(pr_dsresana) IN ('aprovar', 'reprovar', 'derivar') THEN
      -- Neste caso testes retornos obrigatórios
      IF (TRIM(vr_indrisco) IS NULL OR
          TRIM(vr_nrnotrat) IS NULL OR
          TRIM(vr_nrinfcad) IS NULL OR
          TRIM(vr_nrliquid) IS NULL OR
          TRIM(vr_nrgarope) IS NULL OR
          TRIM(vr_nrparlvr) IS NULL OR
          (TRIM(vr_nrperger) IS NULL AND vr_inpessoa = 2)) THEN
          -- Montar mensagem de critica
          vr_status      := 500;
          vr_cdcritic    := 978;
          vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(6)';
          RAISE vr_exc_saida;
      END IF;

      -- Se risco não for um dos verificados abaixo
      IF NOT pr_indrisco IN('AA','A','B','C','D','E','F','G','H') THEN
        -- Montar mensagem de critica
        vr_status      := 500;
        vr_cdcritic    := 978;
        vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(7)';
        RAISE vr_exc_saida;
      END IF;
        
      -- Se algum dos parâmetros abaixo não forem números
      IF NOT fn_is_number(vr_nrnotrat) OR
         NOT fn_is_number(vr_nrinfcad) OR
         NOT fn_is_number(vr_nrliquid) OR
         NOT fn_is_number(vr_nrgarope) OR
         NOT fn_is_number(vr_nrparlvr) OR
         (NOT fn_is_number(vr_nrperger) AND vr_inpessoa = 2 ) THEN

        -- Montar mensagem de critica
        vr_status      := 500;
        vr_cdcritic    := 978;
        vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(8)';
        RAISE vr_exc_saida;
      END IF;
        
      -- Se nao for uma data valida
      IF vr_datscore IS NOT NULL AND NOT fn_is_date(vr_datscore) THEN
        -- Montar mensagem de critica
        vr_status      := 500;
        vr_cdcritic    := 978;
        vr_msg_detalhe := 'Retorno Analise Automatica nao foi processado, ocorreu erro interno no sistema(9)';
        RAISE vr_exc_saida;
      END IF;

    END IF;

    -- Tratar status
    IF lower(pr_dsresana) = 'aprovar' THEN
      vr_insitapr := 1; -- Aprovado
    ELSIF lower(pr_dsresana) = 'reprovar' THEN
      vr_insitapr := 2; -- Reprovado
    ELSIF lower(pr_dsresana) = 'derivar' THEN
      vr_insitapr := 5; -- Derivada
    ELSE
      vr_insitapr := 6; -- Erro
    END IF;

    -- Atualizar proposta de empréstimo
    WEBS0001.pc_atualiza_prop_srv_emprestim(pr_cdcooper    => rw_crawepr.cdcooper --> Codigo da cooperativa
                                           ,pr_nrdconta    => rw_crawepr.nrdconta --> Numero da conta
                                           ,pr_nrctremp    => rw_crawepr.nrctremp --> Numero do contrato
                                           ,pr_tpretest    => 'M'            --> Retorno Motor  
                                           ,pr_rw_crapdat  => rw_crapdat     --> Cursor da crapdat
                                           ,pr_insitapr    => vr_insitapr    --> Situação da Aprovação
                                           ,pr_indrisco    => vr_indrisco    --> Nível do Risco calculado na Analise 
                                           ,pr_nrnotrat    => gene0002.fn_char_para_number(vr_nrnotrat)    --> Calculo do Rating na Analise 
                                           ,pr_nrinfcad    => gene0002.fn_char_para_number(vr_nrinfcad)    --> Informação Cadastral da Analise 
                                           ,pr_nrliquid    => gene0002.fn_char_para_number(vr_nrliquid)    --> Liquidez da Analise 
                                           ,pr_nrgarope    => gene0002.fn_char_para_number(vr_nrgarope)    --> Garantia da Analise 
                                           ,pr_nrparlvr    => gene0002.fn_char_para_number(vr_nrparlvr)    --> Patrimônio Pessoal Livre da Analise 
                                           ,pr_nrperger    => gene0002.fn_char_para_number(vr_nrperger)    --> Percepção Geral Empresa na Analise 
                                           ,pr_dsdscore    => vr_desscore    --> Descrição Score Boa Vista
                                           ,pr_dtdscore    => to_date(vr_datscore,'RRRRMMDD')    --> Data Score Boa Vista
                                           ,pr_flgpreap    => pr_flgpreap    --> Indicador de Pré Aprovado
                                           ,pr_idfluata    => pr_idfluata    --> Indicador Segue Fluxo Atacado -- P637                                          
                                           ,pr_status      => vr_status      --> Status
                                           ,pr_cdcritic    => vr_cdcritic    --> Codigo da critica
                                           ,pr_dscritic    => vr_dscritic    --> Descricao da critica
                                           ,pr_msg_detalhe => vr_msg_detalhe --> Detalhe da mensagem
                                           ,pr_des_reto    => vr_des_reto_web);  --> Erros do processo

    -- Caso somente foi passado como parametro o codigo da critica, vamos buscar a descricao da critica
    IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levantar exceção
      RAISE vr_exc_saida;
    END IF;

    -- Caso possua protocolo
    IF TRIM(pr_dsprotoc) IS NOT NULL THEN

      BEGIN
				UPDATE crawepr wpr
					 SET wpr.dsprotoc = pr_dsprotoc
				 WHERE wpr.rowid = rw_crawepr.rowid;
			EXCEPTION    
				WHEN OTHERS THEN
					-- Adicionar ao LOG e continuar o processo
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                     pr_ind_tipo_log => 2,
                                     pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                     || ' - EMPR0012 --> Erro ao atualizar protocolo '
                                                     || 'Proposta de emprestimo: '||pr_dsprotoc
                                                     || ', erro: '||vr_cdcritic||'-'||vr_dscritic,
                                     pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
			END; 

      -- Se resultado da análise não retornou erro
      IF lower(pr_dsresana) != 'erro' THEN

        -- P450 gravar operacao - 29/07/2019 --
        
        -- Nível Rating --
        vr_desc_nivel_rating := UPPER(ltrim(rtrim(vr_scorerat,'"'),'"'));
        -- Classificacao do Nivel de Risco do Rating (1-Baixo/2-Medio/3-Alto)
        vr_innivel_rating := NULL;
        IF vr_desc_nivel_rating = 'BAIXO' THEN
          vr_innivel_rating := 1;
        ELSIF vr_desc_nivel_rating = 'MEDIO' THEN
          vr_innivel_rating := 2;
        ELSIF vr_desc_nivel_rating = 'ALTO' THEN
          vr_innivel_rating := 3;
        END IF;
        -- Nível Rating --
        
        vr_in_risco_rat  := risc0004.fn_traduz_nivel_risco(vr_indrisco);

        RATI0003.pc_grava_rating_operacao(pr_cdcooper => rw_crawepr.cdcooper
                                         ,pr_nrdconta => rw_crawepr.nrdconta
                                         ,pr_nrctrato => rw_crawepr.nrctremp
                                         ,pr_tpctrato => 90
                                         ,pr_ntrating => NULL
                                         ,pr_ntrataut => vr_in_risco_rat
                                         ,pr_dtrating => rw_crapdat.dtmvtolt
                                         ,pr_strating => 2
                                         ,pr_orrating => 1
                                         ,pr_cdoprrat => 'AUTOCDC'
                                         ,pr_dtrataut => rw_crapdat.dtmvtolt
                                         ,pr_innivel_rating     => vr_innivel_rating
                                         ,pr_nrcpfcnpj_base     => vr_nrcpfcnpj_base
                                         ,pr_inpontos_rating    => gene0002.fn_char_para_number(vr_nrnotrat) --> Pontuacao do Rating retornada do Motor
                                         ,pr_insegmento_rating  => NULL --> Informacao de qual Garantia foi utilizada para calculo Rating do Motor
                                         ,pr_inrisco_rat_inc    => NULL --> Nivel de Rating da Inclusao da Proposta
                                         ,pr_innivel_rat_inc    => NULL --> Classificacao do Nivel de Risco do Rating Inclusao (1-Baixo/2-Medio/3-Alto)
                                         ,pr_inpontos_rat_inc   => vr_nrnotrat --> Pontuacao do Rating retornada do Motor no momento da Inclusao
                                         ,pr_insegmento_rat_inc => NULL --> Informacao de qual Garantia foi utilizada para calculo Rating na Inclusao
                                         --Variáveis para gravar o histórico
                                         ,pr_cdoperad           => NULL  --> Operador que gerou historico de rating
                                         ,pr_dtmvtolt           => rw_crapdat.dtmvtolt  --> Data/Hora do historico de rating
                                         ,pr_valor              => NULL  --> Valor Contratado/Operaca
                                         ,pr_rating_sugerido    => NULL  --> Nivel de Risco Rating Novo apos alteracao manual/automatica
                                         ,pr_justificativa      => NULL  --> Justificativa do operador para alteracao do Rating
                                         ,pr_tpoperacao_rating  => NULL  --> Tipo de Operacao que gerou historico de rating (Dominio: tbgen_dominio_campo)
                                         ,pr_cdcritic           => vr_cdcritic
                                         ,pr_dscritic           => vr_dscritic);
        -- P450 gravar operacao - 29/07/2019 --
      
        -- Acionar rotina para processamento consultas automatizadas
        SSPC0001.pc_retorna_conaut_esteira(rw_crawepr.cdcooper
                                          ,rw_crawepr.nrdconta
                                          ,rw_crawepr.nrctremp
                                          ,pr_dsprotoc
                                          ,vr_cdcritic
                                          ,vr_dscritic);
      
        -- Em caso de erro 
        IF vr_dscritic IS NOT NULL THEN 
          -- Adicionar ao LOG e continuar o processo
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                     pr_ind_tipo_log => 2,
                                     pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                     || ' - EMPR0012 --> Erro ao solicitor retorno nas '
                                                     || 'Consulta Automaticas do Protocolo: '||pr_dsprotoc
                                                     || ', erro: '||vr_cdcritic||'-'||vr_dscritic,
                                     pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        END IF;
      END IF; -- erro

    END IF; -- pr_dsprotoc

    -- se for derivar a proposta volta para o status de analise
    IF vr_insitapr = 5 THEN
	    BEGIN
				UPDATE crawepr wpr 
					 SET wpr.insitest = 2 -->  2 – Enviada para Analise manual
              ,wpr.insitapr = 0
              ,wpr.cdopeapr = NULL
              ,wpr.dtaprova = NULL
              ,wpr.hraprova = 0
              ,wpr.dsprotoc = pr_dsprotoc
				 WHERE wpr.rowid = rw_crawepr.rowid;      
			EXCEPTION    
				WHEN OTHERS THEN
					vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da Analise Automatica de Credito: '||SQLERRM;
					RAISE vr_exc_saida;
			END;
    END IF;

    -- se for derivar a proposta volta para o status de analise
    IF vr_insitapr = 6 THEN
	    BEGIN
				UPDATE crawepr wpr 
					 SET wpr.insitest = 1 -->  2 – Enviada para Analise Automatica
              ,wpr.insitapr = 0
              ,wpr.cdopeapr = NULL
              ,wpr.dtaprova = NULL
              ,wpr.hraprova = 0
              ,wpr.dsprotoc = pr_dsprotoc
				 WHERE wpr.rowid = rw_crawepr.rowid;      
			EXCEPTION    
				WHEN OTHERS THEN
					vr_dscritic := 'Nao foi possivel atualizar proposta apos envio da Analise Automatica de Credito: '||SQLERRM;
					RAISE vr_exc_saida;
			END;
    END IF;

    -- Retornar XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');      
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_des_reto);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'status', pr_tag_cont => vr_status, pr_des_erro => vr_des_reto);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrtransacao', pr_tag_cont => LPAD(vr_nrtransacao,20,'0'), pr_des_erro => vr_des_reto);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdcritic', pr_tag_cont => nvl(vr_cdcritic,0), pr_des_erro => vr_des_reto);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dscritic', pr_tag_cont => nvl(vr_dscritic,' '), pr_des_erro => vr_des_reto);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'msg_detalhe', pr_tag_cont => vr_msg_detalhe, pr_des_erro => vr_des_reto);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'retorno_proc', pr_tag_cont => vr_des_reto_web, pr_des_erro => vr_des_reto);

    -- Gravar
    COMMIT;                                 

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Caso somente foi passado como parametro o codigo da critica, vamos buscar a descricao da critica
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
          -- Buscar crítica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;            
        
        -- Retornar XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');      
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_des_reto);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'status', pr_tag_cont => vr_status, pr_des_erro => vr_des_reto);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrtransacao', pr_tag_cont => LPAD(vr_nrtransacao,20,'0'), pr_des_erro => vr_des_reto);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdcritic', pr_tag_cont => nvl(vr_cdcritic,0), pr_des_erro => vr_des_reto);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dscritic', pr_tag_cont => nvl(vr_dscritic,' '), pr_des_erro => vr_des_reto);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'msg_detalhe', pr_tag_cont => vr_msg_detalhe, pr_des_erro => vr_des_reto);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'retorno_proc', pr_tag_cont => nvl(vr_des_reto_web, 'NOK'), pr_des_erro => vr_des_reto);
        
      WHEN OTHERS THEN
        -- Montar retorno de erro
        vr_status      := 500;
        vr_cdcritic    := 0; 
        vr_dscritic    := 'Erro geral do sistema: ' || SQLERRM;
        vr_msg_detalhe := 'Ocorreu um erro interno no sistema.';

        -- Retornar XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');      
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_des_reto);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'status', pr_tag_cont => vr_status, pr_des_erro => vr_des_reto);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrtransacao', pr_tag_cont => LPAD(vr_nrtransacao,20,'0'), pr_des_erro => vr_des_reto);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdcritic', pr_tag_cont => nvl(vr_cdcritic,0), pr_des_erro => vr_des_reto);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dscritic', pr_tag_cont => nvl(vr_dscritic,' '), pr_des_erro => vr_des_reto);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'msg_detalhe', pr_tag_cont => vr_msg_detalhe, pr_des_erro => vr_des_reto);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'retorno_proc', pr_tag_cont => nvl(vr_des_reto_web, 'NOK'), pr_des_erro => vr_des_reto);
    END; 
  END pc_processa_analise;                                                         

  --> Rotina responsavel por validar se cooperativa está em contingência
  PROCEDURE pc_verifica_contingencia_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE
                                        ,pr_incdccon OUT tbepr_cdc_parametro.inintegra_cont%TYPE
                                        ,pr_cdcritic OUT NUMBER
                                        ,pr_dscritic OUT VARCHAR2) IS
  BEGIN                                        
    /* ..........................................................................
      Programa : pc_verifica_contingencia_cdc
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Lucas Reinert
      Data     : Fevereiro/2018.                   Ultima atualizacao: 

      Dados referentes ao programa:

      Frequencia: Sempre que for chamada
      Objetivo  : Verificar se cooperativa está em contingencia
          
      Alteração : 
    ..........................................................................*/
    DECLARE
      -- Variáveis para tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Buscar parâmetro do cdc
      CURSOR cr_param_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT par.inintegra_cont
          FROM tbepr_cdc_parametro par
         WHERE par.cdcooper = pr_cdcooper;    
      rw_param_cdc cr_param_cdc%ROWTYPE;

    BEGIN
      
      -- Buscar parâmetros CDC da cooperativa
      OPEN cr_param_cdc(pr_cdcooper => pr_cdcooper);
      FETCH cr_param_cdc INTO rw_param_cdc;
    
      -- Se não encontrou parâmetros de integração CDC
      IF cr_param_cdc%NOTFOUND THEN
        -- Fechar cursor
        CLOSE cr_param_cdc;
        -- Gerar crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Parametros de CDC nao cadastrado.';
        -- Levantar exceção
        RAISE vr_exc_erro;
      END IF;
      -- Fechar cursor
      CLOSE cr_param_cdc;  
      
      -- Retornar se cooperativa está em contingencia
      pr_incdccon := rw_param_cdc.inintegra_cont;
      
    EXCEPTION
      WHEN vr_exc_erro THEN    
        -- Atribuir críticas
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN      
        -- Erro
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral do sistema ' || SQLERRM;
    END;
  END pc_verifica_contingencia_cdc;
  
  --> Rotina para retorno dos dados do municipio das cooperativas
  PROCEDURE pc_busca_cooperativa_area(pr_dscidade IN VARCHAR2      --> Descricao da cidade
                                     ,pr_retxml   OUT xmltype      --> XML de retorno
                                     ,pr_dscritic OUT VARCHAR2) IS --> Retorno de Erro
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    -- Variáveis
    vr_contador      NUMBER := 0;

    -- Cursor para buscar os municipios das cooperativas
    CURSOR cr_municipios IS  
      SELECT m.cdcidade
            ,m.cdestado
            ,m.dscidade
            ,c.cdcooper
            ,c.nmrescop
       FROM crapmun m
           ,tbgen_cid_atuacao_coop a 
           ,crapcop c 
        where m.cdcidade=a.cdcidade
          and a.cdcooper=c.cdcooper
          and c.flintcdc=1
          and upper(m.dscidade) like '%' || trim(upper(pr_dscidade)) || '%'
      order by c.nmrescop;

  BEGIN

    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Municipios/>');

    -- Loop sobre a tabela de pessoas
    FOR rw_municipio IN cr_municipios LOOP
      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Municipios'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Municipio'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic); 

      -- Insere os detalhes - Municipio/Cooperativa
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Municipio'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdcidade'
                            ,pr_tag_cont => rw_municipio.cdcidade
                            ,pr_des_erro => pr_dscritic); 
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Municipio'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdestado'
                            ,pr_tag_cont => rw_municipio.cdestado
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Municipio'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dscidade'
                            ,pr_tag_cont => rw_municipio.dscidade
                            ,pr_des_erro => pr_dscritic); 
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Municipio'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdcooper'
                            ,pr_tag_cont => rw_municipio.cdcooper
                            ,pr_des_erro => pr_dscritic); 
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Municipio'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nmrescop'
                            ,pr_tag_cont => rw_municipio.nmrescop
                            ,pr_des_erro => pr_dscritic); 

      vr_contador := vr_contador +1;
    END LOOP;
    
    -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Municipio Nao Possui Cooperativas';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    -- Retorno
    pr_retxml := vr_xml;

  EXCEPTION
      WHEN vr_exc_erro THEN          
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');  
      WHEN OTHERS THEN
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na pc_busca_cooperativa_area: ' || SQLERRM;    
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_busca_cooperativa_area;
  
  
  --> Rotina para retorno dos segmentos (CDC)
  PROCEDURE pc_retorna_segmento(pr_cdsegmento   IN tbepr_cdc_segmento.cdsegmento%type   --> Codigo do segmento
                               ,pr_dssegmento   in tbepr_cdc_segmento.dssegmento%type   --> Descricao do segmento
                               ,pr_retorno  OUT xmltype          --> XML de retorno
                               ,pr_dscritic OUT VARCHAR2) IS     --> Retorno de Erro
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    vr_contador      NUMBER := 0;

    -- Cursor para buscar os segmentos cdc
    CURSOR cr_segmentos IS
      select s.cdsegmento
            ,s.dssegmento
            ,s.tpproduto
       from tbepr_cdc_segmento s
      where s.cdsegmento =decode(nvl(pr_cdsegmento,0),0,s.cdsegmento,pr_cdsegmento)
        and s.dssegmento like '%' || trim(pr_dssegmento) || '%'        
      order by s.cdsegmento; 

  BEGIN
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Segmentos/>');

    -- Loop sobre a tabela de segmentos
    FOR rw_segmentos IN cr_segmentos LOOP

      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Segmentos'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Segmento'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Segmento'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdsegmento'
                            ,pr_tag_cont => rw_segmentos.cdsegmento
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Segmento'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dssegmento'
                            ,pr_tag_cont => rw_segmentos.dssegmento
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Segmento'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'tpproduto'
                            ,pr_tag_cont => rw_segmentos.tpproduto
                            ,pr_des_erro => pr_dscritic);

      vr_contador := vr_contador + 1; 
    END LOOP;
    
    -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Segmento não cadastrado';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    pr_retorno := vr_xml;

  EXCEPTION
    
   WHEN vr_exc_erro THEN          
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
   WHEN OTHERS THEN
     -- Montar descrição de erro não tratado
     pr_dscritic := 'Erro não tratado na pc_retorna_segmento: ' || SQLERRM;
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_retorna_segmento;
    
  --> Rotina para retorno dos segmentos (CDC)
  PROCEDURE pc_retorna_subsegmento(pr_cdsubsegmento  IN tbepr_cdc_subsegmento.cdsubsegmento%type  -- Codigo do sub segmento
                                  ,pr_dssubsegmento  IN tbepr_cdc_subsegmento.dssubsegmento%type  -- descricao do sub segmento
                                  ,pr_cdsegmento     IN tbepr_cdc_segmento.cdsegmento%type        -- Codigo do segmento
                                  ,pr_dssegmento     IN tbepr_cdc_segmento.dssegmento%type        -- descricao do segmento
                                  ,pr_retorno  OUT xmltype            -- XML de retorno
                                  ,pr_dscritic OUT VARCHAR2)is        -- Retorno de Erro  
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    vr_contador      NUMBER := 0;

    -- Cursor para buscar os segmentos e subsegmentos cdc
    CURSOR cr_segmentos IS    
      select ss.cdsubsegmento
            ,ss.dssubsegmento
            ,s.cdsegmento
            ,s.dssegmento
        from tbepr_cdc_segmento s, 
             tbepr_cdc_subsegmento ss
       where s.cdsegmento = ss.cdsegmento
       and   s.cdsegmento =decode(pr_cdsegmento,0,s.cdsegmento,pr_cdsegmento)
       and   s.dssegmento like '%' || trim(pr_dssegmento) || '%' 
       and   ss.cdsubsegmento =decode(pr_cdsubsegmento,0,ss.cdsubsegmento,pr_cdsubsegmento) 
       and   ss.dssubsegmento like '%' || trim(pr_dssubsegmento) || '%';
 
  BEGIN
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Subsegmentos/>');

    -- Loop sobre a tabela de segmentos
    FOR rw_segmentos IN cr_segmentos LOOP

      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Subsegmentos'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Subsegmento'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdsubsegmento'
                            ,pr_tag_cont => rw_segmentos.cdsubsegmento
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dssubsegmento'
                            ,pr_tag_cont => rw_segmentos.dssubsegmento
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdsegmento'
                            ,pr_tag_cont => rw_segmentos.cdsegmento
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Subsegmento'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dssegmento'
                            ,pr_tag_cont => rw_segmentos.dssegmento
                            ,pr_des_erro => pr_dscritic);

      vr_contador := vr_contador + 1;
    END LOOP;
    
     -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Sub segmento não cadastrado';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    pr_retorno := vr_xml;

  EXCEPTION
    
    WHEN vr_exc_erro THEN          
      -- Carregar XML padrao para variavel de retorno
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');  
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_subsegmento: ' || SQLERRM;
      -- Carregar XML padrao para variavel de retorno
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_retorna_subsegmento;  
  
   --> Rotina para retorno dos dados do logista
  PROCEDURE pc_retorna_lojista(pr_cdcooper        IN crapcop.cdcooper%TYPE default 0                      --> Cooperativa
                              ,pr_idcooperado_cdc IN tbsite_cooperado_cdc.idcooperado_cdc%type default 0 --> Identificador do cooperado conveniado no cdc
                              ,pr_nmfantasia      IN tbsite_cooperado_cdc.nmfantasia%type default ' '      --> Nome fantasia
                              ,pr_dssubsegmento   IN TBEPR_CDC_SUBSEGMENTO.DSSUBSEGMENTO%type default ' '  -->Subsegmento do lojista
                              ,pr_pagina          IN pls_integer                                    -- número da página desejada 
                              ,pr_limite          IN pls_integer                                    -- limite de linhas desejadas
                              ,pr_retorno         OUT xmltype                                   --> XML de retorno
                              ,pr_dscritic        OUT VARCHAR2)is                               --> Retorno de Erro                             

    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    vr_contador      NUMBER := 0;
    vr_nrcontseg     NUMBER := 0;
    vr_nrcontsub     NUMBER := 0;

    -- Cursor para buscar os segmentos e subsegmentos cdc
    CURSOR cr_logista IS
      select DISTINCT 
             s.idcooperado_cdc
            ,s.cdcooper
            ,s.nrdconta
            ,s.idmatriz
            ,s.nmfantasia
            ,s.cdcnae
            ,s.dslogradouro
            ,s.dscomplemento
            ,s.idcidade
            ,s.nmbairro
            ,s.nrendereco
            ,s.nrcep
            ,replace(replace(replace(s.dstelefone,'(',0),')',''),' ','') dstelefone
            ,s.dsemail
            ,s.dslink_google_maps
            ,s.nrlatitude
            ,s.nrlongitude
            ,c.flgconve
            ,TO_CHAR(c.dtinicon, 'DD/MM/YYYY')  dtinicon
            ,c.cdoperad
            ,c.progress_recid
            ,TO_CHAR(c.dtcancon, 'DD/MM/YYYY')  dtcancon
            ,TO_CHAR(c.dtrencon, 'DD/MM/YYYY')  dtrencon
            ,TO_CHAR(c.dttercon, 'DD/MM/YYYY')  dttercon
            ,c.inmotcan
            ,c.dsmotcan
            ,s.idcomissao
            ,decode(a.inpessoa,1,lpad(a.nrcpfcgc,11,'0'),lpad(a.nrcpfcgc,14,'0')) nrcpfcgc
            ,TO_CHAR(c.dtacectr, 'DD/MM/YYYY') dtacectr
            ,m.cdestado
            ,gene0002.fn_mask(cop.cdbcoctl,'999') cdbcoctl
            ,gene0002.fn_mask(cop.cdagectl,'9999') cdagectl
            ,a.cdagenci
       from tbsite_cooperado_cdc s
           ,crapcdr c
           ,crapass a
           ,crapcop cop
           ,crapmun m
           ,tbepr_cdc_subsegmento      sub     
           ,tbepr_cdc_subsegmento_coop suc
           ,tbepr_cdc_lojista_subseg   sul
      where s.cdcooper = c.cdcooper
        and s.nrdconta = c.nrdconta
        and s.idmatriz is null
        and s.cdcooper = a.cdcooper
        and s.nrdconta = a.nrdconta
        and c.cdcooper = a.cdcooper
        and c.nrdconta = a.nrdconta
        and a.cdcooper = cop.cdcooper
        and upper(sub.dssubsegmento) like '%' || trim(upper(pr_dssubsegmento)) || '%' 
        and sub.cdsubsegmento = suc.cdsubsegmento
        and suc.cdcooper = s.cdcooper 
        and sul.idsubsegmento_coop = suc.idsubsegmento_coop
        and sul.idcooperado_cdc = s.idcooperado_cdc 
        and s.idcooperado_cdc = decode(nvl(pr_idcooperado_cdc,0),0,s.idcooperado_cdc,pr_idcooperado_cdc)
        and s.cdcooper = decode(nvl(pr_cdcooper,0),0,s.cdcooper,pr_cdcooper)
        and upper(s.nmfantasia) like '%' || trim(upper(pr_nmfantasia)) || '%'
        and m.idcidade (+) = s.idcidade
      order by s.nmfantasia;

    CURSOR cr_segmento (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_idcooperado_cdc IN tbepr_cdc_lojista_subseg.idsubsegmento_coop%TYPE) IS
      select seg.cdsegmento
            ,seg.dssegmento
            ,seg.tpproduto
       from tbepr_cdc_segmento seg
           ,tbepr_cdc_subsegmento sub     
           ,tbepr_cdc_subsegmento_coop suc
           ,tbepr_cdc_lojista_subseg   sul
      where seg.cdsegmento = sub.cdsegmento
        and sub.cdsubsegmento = suc.cdsubsegmento
        and suc.cdcooper = decode(nvl(pr_cdcooper,0),0,suc.cdcooper,pr_cdcooper) 
        and sul.idsubsegmento_coop = suc.idsubsegmento_coop
        and sul.idcooperado_cdc = decode(nvl(pr_idcooperado_cdc,0),0,sul.idcooperado_cdc,pr_idcooperado_cdc) 
      order by seg.cdsegmento;

    CURSOR cr_subsegmento (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_cdsegmento IN tbepr_cdc_segmento.cdsegmento%TYPE
                          ,pr_idcooperado_cdc IN tbepr_cdc_lojista_subseg.idsubsegmento_coop%TYPE) IS
      select sub.cdsubsegmento
            ,sub.dssubsegmento
            ,suc.NRMAX_PARCELA    nrmax_parcela
            ,suc.VLMAX_FINANC     vlmax_financ
            ,suc.nrcarencia
            ,suc.idsubsegmento_coop
            ,sul.idcooperado_cdc
            ,seg.tpproduto
        from tbepr_cdc_segmento         seg
            ,tbepr_cdc_subsegmento      sub     
            ,tbepr_cdc_subsegmento_coop suc
            ,tbepr_cdc_lojista_subseg   sul
       where seg.cdsegmento = decode(nvl(pr_cdsegmento,0),0,seg.cdsegmento,pr_cdsegmento)  
         and seg.cdsegmento = sub.cdsegmento
         and sub.cdsubsegmento = suc.cdsubsegmento
         and suc.cdcooper = decode(nvl(pr_cdcooper,0),0,suc.cdcooper,pr_cdcooper) 
         and sul.idsubsegmento_coop = suc.idsubsegmento_coop
         and sul.idcooperado_cdc = decode(nvl(pr_idcooperado_cdc,0),0,sul.idcooperado_cdc,pr_idcooperado_cdc)  
       order by sub.cdsubsegmento;
      
  BEGIN
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Lojistas/>');

    -- Loop sobre a tabela de lojistas
    FOR rw_logista IN cr_logista LOOP

      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojistas'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Lojista'
                            ,pr_tag_cont => NULL  
							              ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idcooperado_cdc'
                            ,pr_tag_cont => rw_logista.idcooperado_cdc
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdcooper'
                            ,pr_tag_cont => rw_logista.cdcooper
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nrdconta'
                            ,pr_tag_cont => rw_logista.nrdconta
                            ,pr_des_erro => pr_dscritic);  
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idmatriz'
                            ,pr_tag_cont => rw_logista.idmatriz
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nmfantasia'
                            ,pr_tag_cont => rw_logista.nmfantasia
                            ,pr_des_erro => pr_dscritic); 
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdcnae'
                            ,pr_tag_cont => rw_logista.cdcnae
                            ,pr_des_erro => pr_dscritic); 
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dslogradouro'
                            ,pr_tag_cont => rw_logista.dslogradouro
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dscomplemento'
                            ,pr_tag_cont => rw_logista.dscomplemento
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nmbairro'
                            ,pr_tag_cont => rw_logista.nmbairro
                            ,pr_des_erro => pr_dscritic);   
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nrendereco'
                            ,pr_tag_cont => rw_logista.nrendereco
                            ,pr_des_erro => pr_dscritic);  
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idcidade'
                            ,pr_tag_cont => rw_logista.idcidade
                            ,pr_des_erro => pr_dscritic);     
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cduf'
                            ,pr_tag_cont => rw_logista.cdestado
                            ,pr_des_erro => pr_dscritic);  
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nrcep'
                            ,pr_tag_cont => rw_logista.nrcep
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dstelefone'
                            ,pr_tag_cont => rw_logista.dstelefone
                            ,pr_des_erro => pr_dscritic);     
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dsemail'
                            ,pr_tag_cont => rw_logista.dsemail
                            ,pr_des_erro => pr_dscritic);  
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dslink_google_maps'
                            ,pr_tag_cont => rw_logista.dslink_google_maps
                            ,pr_des_erro => pr_dscritic);  
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nrlatitude'
                            ,pr_tag_cont => rw_logista.nrlatitude
                            ,pr_des_erro => pr_dscritic); 
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nrlongitude'
                            ,pr_tag_cont => rw_logista.nrlongitude
                            ,pr_des_erro => pr_dscritic);                              
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'flgconve'
                            ,pr_tag_cont => rw_logista.flgconve
                            ,pr_des_erro => pr_dscritic); 
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dtinicon'
                            ,pr_tag_cont => rw_logista.dtinicon
                            ,pr_des_erro => pr_dscritic); 
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdoperad'
                            ,pr_tag_cont => rw_logista.cdoperad
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'progress_recid'
                            ,pr_tag_cont => rw_logista.progress_recid
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dtcancon'
                            ,pr_tag_cont => rw_logista.dtcancon
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dtrencon'
                            ,pr_tag_cont => rw_logista.dtrencon
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dttercon'
                            ,pr_tag_cont => rw_logista.dttercon
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'inmotcan'
                            ,pr_tag_cont => rw_logista.inmotcan
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dsmotcan'
                            ,pr_tag_cont => rw_logista.dsmotcan
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idcomissao'
                            ,pr_tag_cont => rw_logista.idcomissao
                            ,pr_des_erro => pr_dscritic);
                            
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nrcpfcgc'
                            ,pr_tag_cont => rw_logista.nrcpfcgc
                            ,pr_des_erro => pr_dscritic);                            
                            
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dtacectr'
                            ,pr_tag_cont => rw_logista.dtacectr
                            ,pr_des_erro => pr_dscritic);                         
      
      -- Insere  os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdbcoctl'
                            ,pr_tag_cont => rw_logista.cdbcoctl
                            ,pr_des_erro => pr_dscritic);

      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdagectl'
                            ,pr_tag_cont => rw_logista.cdagectl
                            ,pr_des_erro => pr_dscritic); 

      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdagenci'
                            ,pr_tag_cont => rw_logista.cdagenci
                            ,pr_des_erro => pr_dscritic); 

      -- Insere  os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Lojista'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'Segmentos'
                            ,pr_tag_cont => NULL  
							              ,pr_des_erro => pr_dscritic);

      -- Inicializa sequencia de segmentos


      -- Loop sobre a tabela de segmentos
      FOR rw_segmento IN cr_segmento (rw_logista.cdcooper
                                     ,rw_logista.idcooperado_cdc) LOOP

        -- Insere os detalhes
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'Segmentos'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'Segmento'
                              ,pr_tag_cont => NULL  
                              ,pr_des_erro => pr_dscritic);
                            
        -- Insere os detalhes
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'Segmento'
                              ,pr_posicao  => vr_nrcontseg
                              ,pr_tag_nova => 'cdsegmento'
                              ,pr_tag_cont => rw_segmento.cdsegmento
                              ,pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'Segmento'
                              ,pr_posicao  => vr_nrcontseg
                              ,pr_tag_nova => 'dssegmento'
                              ,pr_tag_cont => rw_segmento.dssegmento
                              ,pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'Segmento'
                              ,pr_posicao  => vr_nrcontseg
                              ,pr_tag_nova => 'tpproduto'
                              ,pr_tag_cont => rw_segmento.tpproduto
                              ,pr_des_erro => pr_dscritic);

        -- Insere os detalhes
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'Segmento'
                              ,pr_posicao  =>  vr_nrcontseg
                              ,pr_tag_nova => 'Subsegmentos'
                              ,pr_tag_cont => NULL  
                              ,pr_des_erro => pr_dscritic);

        -- Loop sobre a tabela de subsegmentos
        FOR rw_subsegmento IN cr_subsegmento (rw_logista.cdcooper
                                             ,rw_segmento.cdsegmento
                                             ,rw_logista.idcooperado_cdc) LOOP

          -- Insere  os detalhes
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Subsegmentos'
                                ,pr_posicao  =>  vr_nrcontseg
                                ,pr_tag_nova => 'Subsegmento'
                                ,pr_tag_cont => NULL  
                                ,pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Subsegmento'
                                ,pr_posicao  => vr_nrcontsub
                                ,pr_tag_nova => 'cdsubsegmento'
                                ,pr_tag_cont => rw_subsegmento.cdsubsegmento
                                ,pr_des_erro => pr_dscritic);
                              
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Subsegmento'
                                ,pr_posicao  => vr_nrcontsub
                                ,pr_tag_nova => 'dssubsegmento'
                                ,pr_tag_cont => rw_subsegmento.dssubsegmento
                                ,pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Subsegmento'
                                ,pr_posicao  => vr_nrcontsub
                                ,pr_tag_nova => 'nrmax_parcela'
                                ,pr_tag_cont => rw_subsegmento.nrmax_parcela
                                ,pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Subsegmento'
                                ,pr_posicao  => vr_nrcontsub
                                ,pr_tag_nova => 'vlmax_financ'
                                ,pr_tag_cont => rw_subsegmento.vlmax_financ
                                ,pr_des_erro => pr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'Subsegmento'
                                ,pr_posicao  => vr_nrcontsub
                                ,pr_tag_nova => 'nrcarencia'
                                ,pr_tag_cont => rw_subsegmento.nrcarencia
                                ,pr_des_erro => pr_dscritic);
          vr_nrcontsub := vr_nrcontsub + 1; 
      END LOOP;

        -- Próxima sequencia segmentos
        vr_nrcontseg := vr_nrcontseg + 1;                    
      END LOOP;

      -- Próxima sequencia lojista
      vr_contador := vr_contador + 1;  
    END LOOP;

     -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Lojista não cadastrado';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    pr_retorno := vr_xml;

  EXCEPTION

    WHEN vr_exc_erro THEN          
      -- Carregar XML padrao para variavel de retorno
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_lojista: ' || SQLERRM;
  END pc_retorna_lojista;  

  --> Rotina referente a alteração logistas CDC
  PROCEDURE pc_atualiza_lojista(pr_idcooperado_cdc in tbsite_cooperado_cdc.idcooperado_cdc%type --> identificação do lojista
                               ,pr_nmfantasia      in tbsite_cooperado_cdc.nmfantasia%type      --> nome fantasia
                               ,pr_nrcep           in tbsite_cooperado_cdc.nrcep%type           --> cep
                               ,pr_dslogradouro    in tbsite_cooperado_cdc.dslogradouro%type    --> descrição do logradouro
                               ,pr_nrendereco      in tbsite_cooperado_cdc.nrendereco%type      --> numero do endereço
                               ,pr_dscomplemento   in tbsite_cooperado_cdc.dscomplemento%type   --> descrição do complemento
                               ,pr_nmbairro        in tbsite_cooperado_cdc.nmbairro%type        --> nome do bairro
                               ,pr_idcidade        in tbsite_cooperado_cdc.idcidade%type        --> código da cidade
                               ,pr_dsemail         in tbsite_cooperado_cdc.dsemail%type         --> descrição do e-mail
                               ,pr_dstelefone      in tbsite_cooperado_cdc.dstelefone%type      --> descrição do telefone
                               ,pr_dtacectr        in crapcdr.dtacectr%type                     --> Data de aceite do novo contrato
                               ,pr_retorno         OUT xmltype                                  --> XML de retorno
                               ,pr_dscritic        OUT VARCHAR2)IS                              --> Retorno de Erro

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_atualiza_lojista
    Sistema : Reestruturacao do CDC
    Sigla   : CRED
    Autor   : 
    Data    : 03/04/2018                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: 
    Objetivo  : Rotina referente a alteração de logistas CDC

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*/
  -- Verificar existência

   -- Exceções
    vr_exc_erro EXCEPTION;
    -- Tratamento de erros
    vr_dscritic crapcri.dscritic%TYPE;

    CURSOR cr_tbsite_cooperado_cdc IS
      SELECT t.idcooperado_cdc
            ,c.dtacectr
            ,c.rowid
        FROM tbsite_cooperado_cdc t
            ,crapcdr c 
       where t.nrdconta = c.nrdconta
         and t.cdcooper = c.cdcooper
         and t.idcooperado_cdc = pr_idcooperado_cdc;
     rw_tbsite_cooperado_cdc cr_tbsite_cooperado_cdc%ROWTYPE;    

     --> Buscar id da cidade
     CURSOR cr_crapmun (pr_cdcidade IN crapmun.cdcidade%TYPE)IS
       SELECT mun.idcidade
         FROM crapmun mun
        WHERE mun.cdcidade = pr_cdcidade; 
     rw_crapmun cr_crapmun%ROWTYPE;   

  BEGIN
    
    -- verifica existência da conta
    OPEN cr_tbsite_cooperado_cdc;
    FETCH cr_tbsite_cooperado_cdc INTO rw_tbsite_cooperado_cdc;

    -- Se não encontrou a conta
    IF cr_tbsite_cooperado_cdc%NOTFOUND THEN
      -- Fechar cursor
      CLOSE cr_tbsite_cooperado_cdc;
      -- Gerar crítica
      vr_dscritic := 'Lojista não cadastrado';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    -- Fechar cursor
    CLOSE cr_tbsite_cooperado_cdc;

    --> Buscar id da cidade
    OPEN cr_crapmun (pr_cdcidade => pr_idcidade);
    FETCH cr_crapmun INTO rw_crapmun;       
    IF cr_crapmun%NOTFOUND THEN
      CLOSE cr_crapmun;
      vr_dscritic := 'Codigo de municipio não cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapmun;
    END IF;
        

    BEGIN
      --Alterar Logista Cadastrados
      update tbsite_cooperado_cdc 
         SET nmfantasia           = pr_nmfantasia    
            ,nrcep                = pr_nrcep         
            ,dslogradouro         = pr_dslogradouro  
            ,nrendereco           = pr_nrendereco    
            ,dscomplemento        = pr_dscomplemento 
            ,nmbairro             = pr_nmbairro      
            ,idcidade             = rw_crapmun.idcidade      
            ,dsemail              = pr_dsemail       
            ,dstelefone           = pr_dstelefone    
       where idcooperado_cdc = pr_idcooperado_cdc;   
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar tbsite_cooperado_cdc: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    -- gravar log
    --NMOPERACAO = ACEITE CONTRATO
    --DSOPERACAO = ACEITE DO NOVO CONTRATO DO LOJISTA CDC
    if pr_dtacectr is not null then
      
      BEGIN
        --Alterar Logista Cadastrados
        update crapcdr c 
           SET c.dtacectr = pr_dtacectr
         where c.rowid = rw_tbsite_cooperado_cdc.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crapcdr: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

      cecred.empr0012.pc_grava_log(pr_idlog => 0
                                  ,pr_dtoperacao => sysdate
                                  ,pr_hroperacao => sysdate
                                  ,pr_nmoperacao => 'ACEITE CONTRATO'
                                  ,pr_dsoperacao => 'ACEITE DO NOVO CONTRATO DO LOJISTA CDC'
                                  ,pr_dsorigem => 'pc_atualiza_lojista'
                                  ,pr_idcooperado_cdc => pr_idcooperado_cdc
                                  ,pr_idusuario => null
                                  ,pr_dscritic => pr_dscritic);
    end if;  
    --Retorno
    pr_dscritic := '';  
    pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><ok>' || pr_dscritic || '</ok></Root>');      
    EXCEPTION
      WHEN vr_exc_erro THEN          
        -- Carregar XML padrao para variavel de retorno
         pr_dscritic := vr_dscritic;
         pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><NOK>' || pr_dscritic || '</NOK></Root>');    
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_dscritic := 'NOK - '|| SQLERRM;
        pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_atualiza_lojista;

  --> Cadastra Usuario
  PROCEDURE pc_cadastra_usuario(pr_idusuario        IN tbepr_cdc_usuario.idusuario%type     --> Identificacao do usuario
                               ,pr_dslogin          IN tbepr_cdc_usuario.dslogin%type       --> Login do usuario
                               ,pr_dssenha          IN tbepr_cdc_usuario.dssenha%type       --> Senha do usuario
                               ,pr_dtinsori         IN tbepr_cdc_usuario.dtinsori%type      --> Data de criacao do registro
                               ,pr_flgativo         IN tbepr_cdc_usuario.flgativo%type      --> Flag de controle de ativacao (0-Inativo, 1-Ativo)
					  		               ,pr_fladmin          IN tbepr_cdc_usuario.flgadmin%type      --> Flag de controle de usuario ADM (0-Nao, 1-Sim)
                               ,pr_idcooperado_cdc  IN tbepr_cdc_usuario_vinculo.idcooperado_cdc%type --> Identificacao do lojista
                               ,pr_nmvendedor       IN tbepr_cdc_vendedor.nmvendedor%type    --> Nome do vendedor
                               ,pr_nrcpf            IN tbepr_cdc_vendedor.nrcpf%type         --> Numero do CPF
                               ,pr_dsemail          IN tbepr_cdc_vendedor.dsemail%type       --> Descricao do email
                               ,pr_idcomissao       IN tbepr_cdc_vendedor.idcomissao%type    --> Comissao
                               ,pr_dscritic         OUT VARCHAR2) IS      
                               
    
  /* .............................................................................
    Programa: pc_cadastra_usuario
    Sistema : Integração CDC x Autorizador
    Sigla   : CRED
    Autor   : 
    Data    :                             Ultima atualizacao: 15/06/2018 
      
    Dados referentes ao programa:
      
    Frequencia: Sempre que for chamado
    Objetivo  : Cadastra Usuario
      
    Alteracoes: 15/06/2018 - Incluir novas validações.
                             PRJ439 (Odirlei-AMcom)
    
  ............................................................................. */
  
    ---->> CURSORES <<----    
    -- Verificar login existente
    CURSOR cr_usuario_login(pr_dslogin         IN tbepr_cdc_usuario.dslogin%type,
                            pr_idcooperado_cdc IN tbepr_cdc_usuario_vinculo.idcooperado_cdc%TYPE) IS      
      SELECT 1 
        FROM tbepr_cdc_usuario u,
             tbepr_cdc_usuario_vinculo v
       WHERE u.idusuario = v.idusuario 
         AND u.dslogin   = pr_dslogin
         AND v.idcooperado_cdc = pr_idcooperado_cdc;    
    rw_usuario_login cr_usuario_login%ROWTYPE;
    
    -- Verificar login antivo existente
    CURSOR cr_usuario_ativo (pr_dslogin         IN tbepr_cdc_usuario.dslogin%type,
                                   pr_idcooperado_cdc IN tbepr_cdc_usuario_vinculo.idcooperado_cdc%TYPE) IS      
      SELECT v.idcooperado_cdc,
             c.nmfantasia
        FROM tbepr_cdc_usuario u,
             tbepr_cdc_usuario_vinculo v,
             tbsite_cooperado_cdc c
       WHERE u.idusuario = v.idusuario 
         AND v.idcooperado_cdc = c.idcooperado_cdc
         AND u.dslogin         = pr_dslogin         
         AND u.flgativo        = 1
         AND v.idcooperado_cdc <> pr_idcooperado_cdc; 
    rw_usuario_ativo cr_usuario_ativo%ROWTYPE;
    
    
    -- cursor para obter os dados originais.
    CURSOR cr_usuario(pr_idusuario in tbepr_cdc_usuario.idusuario%TYPE) IS
      SELECT u.* 
        FROM tbepr_cdc_usuario u 
       WHERE u.idusuario = pr_idusuario;
    rw_usuario cr_usuario%ROWTYPE;       
      
    -- cursor para obter os dados do vinculo.
    CURSOR cr_vinculo(pr_idcooperado_cdc in tbepr_cdc_usuario_vinculo.idcooperado_cdc%type
                      ,pr_idusuario in tbepr_cdc_usuario_vinculo.idusuario%type ) IS
      SELECT v.*
        from tbepr_cdc_usuario_vinculo v
        where v.idcooperado_cdc = pr_idcooperado_cdc
          and v.idusuario = pr_idusuario;
     rw_vinculo cr_vinculo%ROWTYPE;            
    
     -- cursor para obter dados da comissão
     CURSOR cr_tbepr_cdc_parm_comissao(pr_idcomissao in tbepr_cdc_parm_comissao.idcomissao%type ) IS
      SELECT nmcomissao 
        FROM tbepr_cdc_parm_comissao
       where idcomissao = pr_idcomissao;
      rw_tbepr_cdc_parm_comissao cr_tbepr_cdc_parm_comissao%ROWTYPE;       
    
    
    ---->> VARIAVEIS <<----
    -- Tratamento de erros
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_erro EXCEPTION;
      
    vr_idusuario    tbepr_cdc_usuario.idusuario%TYPE;  
    vr_idvendedor   tbepr_cdc_vendedor.idvendedor%TYPE;
    
    --> Rotina para validar login
    PROCEDURE pc_validar_login (pr_dslogin         IN tbepr_cdc_usuario.dslogin%type,
                                pr_idcooperado_cdc IN tbepr_cdc_usuario_vinculo.idcooperado_cdc%TYPE,
                                pr_dscritic       OUT VARCHAR2)IS
    BEGIN
      -- Verificar login existente
      OPEN cr_usuario_login(pr_dslogin         => pr_dslogin,
                            pr_idcooperado_cdc => pr_idcooperado_cdc);        
      FETCH cr_usuario_login INTO rw_usuario_login;
      
      -- Se se encontrou o login
      IF cr_usuario_login%FOUND THEN
        CLOSE cr_usuario_login;
        -- Gerar crítica
        vr_dscritic := 'Login já cadastrado para este lojista.';       
        RAISE vr_exc_erro;
      END IF;      
      CLOSE cr_usuario_login;
      
      -- Verificar login ativo existente, deve permitir apenas 1 ativo
      OPEN cr_usuario_ativo( pr_dslogin         => pr_dslogin,
                             pr_idcooperado_cdc => pr_idcooperado_cdc);          
      FETCH cr_usuario_ativo INTO rw_usuario_ativo;
      
      -- Se se encontrou o login
      IF cr_usuario_ativo%FOUND THEN
        CLOSE cr_usuario_ativo;
        -- Gerar crítica
        vr_dscritic := 'Login já associado ao lojista '||
                          rw_usuario_ativo.idcooperado_cdc||' - '|| rw_usuario_ativo.nmfantasia;       
        RAISE vr_exc_erro;
      END IF;      
      CLOSE cr_usuario_ativo;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Nao foi possivel validar login: '|| SQLERRM; 
    END pc_validar_login;
           

  BEGIN
  
  
    vr_idusuario := pr_idusuario;
  
    --Se idusuario > 0 alteração.
    IF (nvl(pr_idcooperado_cdc,0) = 0) then
      vr_dscritic := 'Informar Cooperado';
      RAISE vr_exc_erro;
    END IF;
    
    --valida o login
    IF TRIM(pr_dslogin) is null THEN 
      -- Gerar crítica
      vr_dscritic := 'Login inválido, deve ser informado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- verifica se possui comissão cadastrada
    IF nvl(pr_idcomissao,0) > 0 THEN
    
      -- verifica se possui comissão cadastrada
      OPEN cr_tbepr_cdc_parm_comissao(pr_idcomissao);
      FETCH cr_tbepr_cdc_parm_comissao INTO rw_tbepr_cdc_parm_comissao;
      -- Se se encontrou o login
      IF cr_tbepr_cdc_parm_comissao%NOTFOUND THEN
        -- Fechar cursor
        CLOSE cr_tbepr_cdc_parm_comissao;
        -- Gerar crítica
        vr_dscritic := 'Comissao não cadastrada.';
        RAISE vr_exc_erro;
      END IF;              
      CLOSE cr_tbepr_cdc_parm_comissao;
    END IF;
    
    
    --->> INCLUSAO <<---
    IF nvl(vr_idusuario,0) = 0 then -- inclusão de usuario
    
      --validar nome do vendedor
      IF nvl(trim(pr_nmvendedor),' ') = ' ' THEN 
        -- Gerar crítica
        vr_dscritic := 'Nome do vendedor inválido, deve ser informado.';
        -- Levantar exceção
        RAISE vr_exc_erro;
      END IF;
      
      --> Validar login existente
      pc_validar_login( pr_dslogin         => pr_dslogin,
                        pr_idcooperado_cdc => pr_idcooperado_cdc,
                        pr_dscritic        => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;      
      END IF;
      
      -- cadastra usuário
      BEGIN
        INSERT INTO tbepr_cdc_usuario 
                   (dslogin
                   ,dssenha
                   ,dtinsori
                   ,flgativo
                   ,FLGADMIN)
            VALUES
                  (pr_dslogin
                  ,pr_dssenha
                  ,sysdate
                  ,pr_flgativo
                  ,pr_fladmin)
           RETURNING idusuario INTO vr_idusuario; 
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir tbepr_cdc_usuario: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      --> Inlcuir Vendedor
      pc_manter_vendedor  (pr_idvendedor       => vr_idvendedor        --> Identificacao do vendedor
                          ,pr_nmvendedor       => pr_nmvendedor        --> Nome do vendedor
                          ,pr_nrcpf            => pr_nrcpf             --> Numero do CPF
                          ,pr_dsemail          => pr_dsemail           --> Descricao do email
                          ,pr_idcomissao       => pr_idcomissao        --> Comissão
                          ,pr_idcooperado_cdc  => pr_idcooperado_cdc   --> Identificacao do lojista
                          ,pr_dscritic         => vr_dscritic);        --> Retorno de Erro 
    
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- cadastra vínculo
      BEGIN
       INSERT INTO tbepr_cdc_usuario_vinculo
             (idusuario
             ,idcooperado_cdc
             ,idvendedor)
       VALUES
             (vr_idusuario
             ,pr_idcooperado_cdc 
             ,vr_idvendedor) ;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir tbepr_cdc_usuario_vinculo. (Usuario) ' ||SQLERRM;
        RAISE vr_exc_erro;
      END;
      
    --->> ALTERACAO <<---  
    ELSE
    
      --> Validar se usuario existe
      OPEN cr_usuario(vr_idusuario);
      FETCH cr_usuario INTO rw_usuario;
      IF cr_usuario%NOTFOUND THEN
        CLOSE cr_usuario;
        -- Gerar crítica
        vr_dscritic := 'Usuário não cadastrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_usuario;
      
      --Valida o login
      IF pr_dslogin <> rw_usuario.dslogin OR 
        (pr_flgativo = 1 AND pr_fladmin <> rw_usuario.flgadmin)  THEN
      
        --> Validar login existente
        pc_validar_login( pr_dslogin         => pr_dslogin,
                          pr_idcooperado_cdc => pr_idcooperado_cdc,
                          pr_dscritic        => vr_dscritic);
        
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;      
        END IF;
        
      END IF;        
        
      --Atualiza usuario
      BEGIN
        UPDATE tbepr_cdc_usuario 
           SET dssenha   = coalesce(pr_dssenha, dssenha)
              ,dslogin   = pr_dslogin  
              ,flgativo  = pr_flgativo
              ,flgadmin  = pr_fladmin
             WHERE idusuario  =  vr_idusuario;
      EXCEPTION
        WHEN OTHERS THEN
           vr_dscritic := 'Erro ao atualizar tbepr_cdc_vendedor: '||SQLERRM;
           RAISE vr_exc_erro;
      END;
      
      -- obter o idvendedor através da tabela de vinculo
      OPEN cr_vinculo(pr_idcooperado_cdc => pr_idcooperado_cdc,
                      pr_idusuario       => vr_idusuario);
      FETCH cr_vinculo INTO rw_vinculo;
      -- Se se encontrou o vinculo 
      IF cr_vinculo%Found THEN
        vr_idvendedor := nvl(rw_vinculo.idvendedor,0);
        CLOSE cr_vinculo;
      ELSE
        vr_dscritic := 'Vinculo entre Usuario e vendedor não encontrado.';
        RAISE vr_exc_erro;
      END IF;
      
      --> Atualizar Vendedor
      pc_manter_vendedor  (pr_idvendedor       => vr_idvendedor        --> Identificacao do vendedor
                          ,pr_nmvendedor       => pr_nmvendedor        --> Nome do vendedor
                          ,pr_nrcpf            => pr_nrcpf             --> Numero do CPF
                          ,pr_dsemail          => pr_dsemail           --> Descricao do email
                          ,pr_idcomissao       => pr_idcomissao        --> Comissão
                          ,pr_idcooperado_cdc  => pr_idcooperado_cdc   --> Identificacao do lojista
                          ,pr_dscritic         => vr_dscritic);        --> Retorno de Erro 
    
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    END IF; 
    
    --Atualização dados
    COMMIT;
    
    --Retorno com sucesso
    pr_dscritic := null;
   EXCEPTION   
     WHEN vr_exc_erro THEN          
      --Desfaz atualizações
      rollback;          
      --Retorna mensagem de critica
       pr_dscritic := vr_dscritic;
  END pc_cadastra_usuario;

  --> Rotina para retorno das comissões (CDC)
  PROCEDURE pc_retorna_comissao(pr_cdcooper          IN crapepr.cdcooper%type                     --> Codigo que identifica a Cooperativa.
                               ,pr_idcoooperado_cdc  IN tbepr_cdc_emprestimo.idcooperado_cdc%type --> Identificacao do lojista
                               ,pr_idvendedor        IN tbepr_cdc_vendedor.idvendedor%type        --> Identificacao do vendedor
                               ,pr_mes_efetivacao    IN crapepr.dtmvtolt%type                     --> Data do movimento atual.
                               ,pr_tipo_comissao     IN integer                                   --> Tipo de comissao 1-Logista 2-Vendedor
                               ,pr_retorno           OUT xmltype                                  --> XML de retorno
                               ,pr_dscritic          OUT VARCHAR2) IS                             --> Retorno de Erro  
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Variaveis gerais
    vr_xml        xmltype; -- XML que sera enviado
    vr_contador   NUMBER := 0;
    vr_dtinicio   date;
    vr_dtfinal    date;
 
    -- Cursor para buscar as comissões lojistas.
    CURSOR cr_comissao IS
      select pr_tipo_comissao as indicador
            ,tce.idcooperado_cdc
            ,ass.nmprimtl   as nmcomprador
            ,decode(ass.inpessoa,1,lpad(ass.nrcpfcgc,11,'0'),lpad(ass.nrcpfcgc,14,'0'))   as nrdoccomprador
            ,tcc.nmfantasia as nmlojista
            ,tcv.idvendedor
            ,tcv.nmvendedor
            ,epr.vlemprst
            ,tce.vlrepasse  
            ,TO_CHAR(epr.dtmvtolt, 'DD/MM/YYYY')  data_efetivacao
            ,TO_CHAR(wpr.dtmvtolt, 'DD/MM/YYYY')  data_proposta
            ,tcc.idcomissao
            ,TO_CHAR(epr.dtmvtolt, 'DD/MM/YYYY')  dtmvtolt
            ,fn_retorna_comissao_emp(pr_cdcooper => wpr.cdcooper
                                    ,pr_nrdconta => wpr.nrdconta
                                    ,pr_nrctremp => wpr.nrctremp) vlcomissao
        from crapepr epr
            ,crawepr wpr 
            ,crapass ass 
            ,tbepr_cdc_emprestimo tce 
            ,tbepr_cdc_vendedor   tcv
            ,tbsite_cooperado_cdc tcc 
            ,tbepr_cdc_usuario_vinculo tcuv --novo
            ,tbepr_cdc_usuario tcu -- novo
            ,tbepr_cdc_parm_comissao tcpc 
      where epr.cdcooper = pr_cdcooper
        and epr.dtmvtolt>= vr_dtinicio
        and epr.dtmvtolt<= vr_dtfinal
        and (wpr.cdcooper=epr.cdcooper and wpr.nrdconta=epr.nrdconta and wpr.nrctremp=epr.nrctremp)
        and (ass.cdcooper=epr.cdcooper and ass.nrdconta=epr.nrdconta)
        and (tce.cdcooper=wpr.cdcooper and tce.nrdconta=epr.nrdconta and tce.nrctremp=epr.nrctremp)
        and (tcc.idcooperado_cdc=tce.idcooperado_cdc)
        and  tcc.idcooperado_cdc=coalesce(pr_idcoooperado_cdc, tcc.idcooperado_cdc)
        and (tcv.idvendedor=coalesce(pr_idvendedor, tce.idvendedor))
        and (tcuv.idcooperado_cdc=tcc.idcooperado_cdc and tcuv.idvendedor=tcv.idvendedor)
        and (tcu.idusuario=tcuv.idusuario and tcu.flgativo=1)
        and ((tcpc.idcomissao=tcc.idcomissao and pr_tipo_comissao=1) OR (tcpc.idcomissao=tcv.idcomissao and pr_tipo_comissao=2));
     
  BEGIN

    vr_dtinicio := trunc(nvl(pr_mes_efetivacao,sysdate),'MM');      -- primeiro dia do mes
    vr_dtfinal  := trunc(last_day(nvl(pr_mes_efetivacao,sysdate))); -- ultimo dia do mes

    if nvl(pr_cdcooper,0) = 0 then 
      -- Gerar crítica
      pr_dscritic := 'Cooperativa não informada'; 
      -- Levantar exceção
      RAISE vr_exc_erro;  
    end if;

    if nvl(pr_idvendedor,0) = 0 and nvl(pr_idcoooperado_cdc,0) = 0 then
      -- Gerar crítica
      pr_dscritic := 'Logista/Vendedor não informado'; 
      -- Levantar exceção
      RAISE vr_exc_erro;  
    end if;

    if nvl(pr_tipo_comissao,0) not in (1,2) then 
      -- Gerar crítica
      pr_dscritic := 'Tipo de Comissão para Logista/Vendedor não informado'; 
      -- Levantar exceção
      RAISE vr_exc_erro;  
    end if;

    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Comissoes/>');
    -- Loop sobre a tabela de segmentos
    FOR rw_comissao IN cr_comissao LOOP
      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissoes'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Comissao'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idcooperado_cdc'
                            ,pr_tag_cont => rw_comissao.idcooperado_cdc
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nmcomprador'
                            ,pr_tag_cont => rw_comissao.nmcomprador
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nrdoccomprador'
                            ,pr_tag_cont => rw_comissao.nrdoccomprador
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nmlojista'
                            ,pr_tag_cont => rw_comissao.nmlojista
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idvendedor'
                            ,pr_tag_cont => rw_comissao.idvendedor
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nmvendedor'
                            ,pr_tag_cont => rw_comissao.nmvendedor
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'vlemprst'
                            ,pr_tag_cont => rw_comissao.vlemprst
                            ,pr_des_erro => pr_dscritic);                            
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'vlrepasse'
                            ,pr_tag_cont => rw_comissao.vlrepasse
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'data_efetivacao'
                            ,pr_tag_cont => rw_comissao.data_efetivacao
                            ,pr_des_erro => pr_dscritic);    
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'data_proposta'
                            ,pr_tag_cont => rw_comissao.data_proposta
                            ,pr_des_erro => pr_dscritic);    
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idcomissao'
                            ,pr_tag_cont => rw_comissao.idcomissao
                            ,pr_des_erro => pr_dscritic);    
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dtmvtolt'
                            ,pr_tag_cont => rw_comissao.dtmvtolt
                            ,pr_des_erro => pr_dscritic);    
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'vlcomissao'
                            ,pr_tag_cont => rw_comissao.vlcomissao
                            ,pr_des_erro => pr_dscritic);    
                            
      vr_contador := vr_contador + 1;

    END LOOP;

     -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Comissão não cadastrada';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    pr_retorno := vr_xml;

  EXCEPTION
   WHEN vr_exc_erro THEN          
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_lojista: ' ||SQLERRM;
      -- Carregar XML padrao para variavel de retorno
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_retorna_comissao;
  
  --> Rotina para retorno dos produtos credito (CDC)
  PROCEDURE pc_lista_produto_credito(pr_cdcooper       IN tbepr_cdc_subsegmento_coop.cdcooper%type  --> Código da cooperativa
                                    ,pr_cdsegmento     IN tbepr_cdc_subsegmento.cdsegmento%type     --> Código do segmento
                                    ,pr_cdsubsegmento  IN tbepr_cdc_subsegmento.cdsubsegmento%type  --> Código do subsegmento
                                    --,pr_dssegmento     IN tbepr_cdc_segmento.dssegmento%type        --> Descricao de segmento
                                    --,pr_dssubsegmento  IN tbepr_cdc_subsegmento.dssubsegmento%type  --> Descricao do subsegmento
                                    ,pr_retorno        OUT xmltype                                  --> XML de retorno
                                    ,pr_dscritic       OUT VARCHAR2)IS                              --> Retorno de Erro  
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    vr_contador      NUMBER := 0;

    -- Cursor para buscar produtos
    CURSOR cr_comissao IS
    SELECT tcsc.cdcooper
          ,tcs.tpproduto
          ,tcs.cdsegmento
          ,tcs.dssegmento
          ,tcss.cdsubsegmento
          ,tcss.dssubsegmento
          ,tcsc.NRMAX_PARCELA          nrmax_parcela
          ,tcsc.VLMAX_FINANC   vlmax_financ
          ,tcsc.nrcarencia
      FROM tbepr_cdc_subsegmento_coop tcsc
      JOIN tbepr_cdc_subsegmento tcss on (tcss.cdsubsegmento=tcsc.cdsubsegmento)
      JOIN tbepr_cdc_segmento tcs on (tcs.cdsegmento=tcss.cdsegmento)
     WHERE tcsc.cdcooper=pr_cdcooper -- obrigatorio
       AND tcs.cdsegmento=DECODE(NVL(pr_cdsegmento,0),0,tcs.cdsegmento,pr_cdsegmento) -- opcional
       AND tcss.cdsubsegmento=DECODE(NVL(pr_cdsubsegmento,0),0,tcss.cdsubsegmento,pr_cdsubsegmento); -- opcional

  BEGIN
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Comissoes/>');

    -- Loop sobre a tabela de segmentos
    FOR rw_comissao IN cr_comissao LOOP
      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissoes'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Comissao'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdcooper'
                            ,pr_tag_cont => rw_comissao.cdcooper
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'tpproduto'
                            ,pr_tag_cont => rw_comissao.tpproduto
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdsegmento'
                            ,pr_tag_cont => rw_comissao.cdsegmento
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dssegmento'
                            ,pr_tag_cont => rw_comissao.dssegmento
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdsubsegmento'
                            ,pr_tag_cont => rw_comissao.cdsubsegmento
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dssubsegmento'
                            ,pr_tag_cont => rw_comissao.dssubsegmento
                            ,pr_des_erro => pr_dscritic);    
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nrparcela'
                            ,pr_tag_cont => rw_comissao.nrmax_parcela
                            ,pr_des_erro => pr_dscritic);   
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'vlmaximoproposta'
                            ,pr_tag_cont => rw_comissao.vlmax_financ
                            ,pr_des_erro => pr_dscritic); 
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nrcarencia'
                            ,pr_tag_cont => rw_comissao.nrcarencia
                            ,pr_des_erro => pr_dscritic); 

      vr_contador := vr_contador + 1;
    END LOOP;

     -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Comissão não informada';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    pr_retorno := vr_xml;

  EXCEPTION
   WHEN vr_exc_erro THEN   
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
   WHEN OTHERS THEN
     -- Montar descrição de erro não tratado
     pr_dscritic := 'Erro não tratado na pc_retorna_lojista: ' ||SQLERRM;
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END;  
  
  
  --> Cadastra Vendedor
  PROCEDURE pc_manter_vendedor  (pr_idvendedor       IN OUT tbepr_cdc_vendedor.idvendedor%type      --> Identificacao do vendedor
                                ,pr_nmvendedor       IN tbepr_cdc_vendedor.nmvendedor%type      --> Nome do vendedor
                                ,pr_nrcpf            IN tbepr_cdc_vendedor.nrcpf%type           --> Numero do CPF
                                ,pr_dsemail          IN tbepr_cdc_vendedor.dsemail%type         --> Descricao do email
                                ,pr_idcomissao       IN tbepr_cdc_vendedor.idcomissao%type      --> Comissão
                                ,pr_idcooperado_cdc  IN tbepr_cdc_vendedor.idcooperado_cdc%type --> Identificacao do lojista
                                ,pr_dscritic         OUT VARCHAR2) IS                           --> Retorno de Erro 
                                
    -- cursor para verificar cpf existente
    CURSOR cr_tbepr_cdc_vendedor_cpf(pr_nrcpf in tbepr_cdc_vendedor.nrcpf%type) IS
      select v.nrcpf
        from tbepr_cdc_vendedor v,
             tbepr_cdc_usuario_vinculo i,
             tbepr_cdc_usuario u
       WHERE v.idvendedor = i.idvendedor
         AND i.idusuario  = u.idusuario  
         AND u.flgativo   = 1
         AND v.nrcpf      = pr_nrcpf;
    rw_tbepr_cdc_vendedor_cpf cr_tbepr_cdc_vendedor_cpf%ROWTYPE;  
    
    -- cursor para buscar vendedor
    CURSOR cr_tbepr_cdc_vendedor(pr_idvendedor in tbepr_cdc_vendedor.idvendedor%type) IS
      select v.*
      from tbepr_cdc_vendedor v
       where v.idvendedor = pr_idvendedor;
      rw_tbepr_cdc_vendedor cr_tbepr_cdc_vendedor%ROWTYPE;
       
    
    -- Tratamento de erros
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_erro EXCEPTION;

  BEGIN
  
    --validar nome do vendedor
    IF nvl(TRIM(pr_nmvendedor),' ') = ' ' THEN
      -- Gerar crítica
      vr_dscritic := 'Nome do vendedor inválido, deve ser informado.';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;
    
    -- verifica se pr_idvendedor é informado
    IF nvl(pr_idvendedor,0) = 0 THEN
    
      -- verifica se cpf já esta em uso.
      OPEN cr_tbepr_cdc_vendedor_cpf(pr_nrcpf);
      FETCH cr_tbepr_cdc_vendedor_cpf INTO rw_tbepr_cdc_vendedor_cpf;
      -- Se se encontrou o cpf
      IF cr_tbepr_cdc_vendedor_cpf%Found THEN
        -- Gerar crítica
        vr_dscritic := 'Já existe usuario ativo para este CPF.';
        -- Levantar exceção
        RAISE vr_exc_erro;
        CLOSE cr_tbepr_cdc_vendedor_cpf;
      END IF;
      CLOSE cr_tbepr_cdc_vendedor_cpf;
    
    BEGIN
      INSERT INTO tbepr_cdc_vendedor
                   (nmvendedor
                 ,nrcpf
                 ,dsemail
                 ,idcomissao
                 ,idcooperado_cdc)
          VALUES (replace(pr_nmvendedor,'&', 'E')
                 ,pr_nrcpf          
                 ,pr_dsemail        
                 ,pr_idcomissao
                   ,pr_idcooperado_cdc)
          RETURNING idvendedor INTO pr_idvendedor;
    EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao criar vendendor: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    
    ELSE -- insere
    
      -- verifica se vendedor já esta em uso.
      OPEN cr_tbepr_cdc_vendedor(pr_idvendedor => pr_idvendedor);
      FETCH cr_tbepr_cdc_vendedor INTO rw_tbepr_cdc_vendedor;
      -- Se se encontrou o vendedor
      IF cr_tbepr_cdc_vendedor%notfound THEN
        -- Gerar crítica
        vr_dscritic := 'Vendedor não encontrado.';
        -- Levantar exceção
        RAISE vr_exc_erro;
        CLOSE cr_tbepr_cdc_vendedor;
      END IF;
      CLOSE cr_tbepr_cdc_vendedor;
      
      IF rw_tbepr_cdc_vendedor.nrcpf <> pr_nrcpf then
        -- verifica se cpf já esta em uso.
        OPEN cr_tbepr_cdc_vendedor_cpf(pr_nrcpf);
        FETCH cr_tbepr_cdc_vendedor_cpf INTO rw_tbepr_cdc_vendedor_cpf;
        -- Se se encontrou o cpf
        IF cr_tbepr_cdc_vendedor_cpf%Found THEN
          -- Gerar crítica
          vr_dscritic := 'CPF já utilizado para outro vendedor.';
          -- Levantar exceção
          RAISE vr_exc_erro;
          CLOSE cr_tbepr_cdc_vendedor_cpf;
        END IF;
        CLOSE cr_tbepr_cdc_vendedor_cpf;
      END IF;
    

        BEGIN
          UPDATE tbepr_cdc_vendedor 
             SET nmvendedor      = REPLACE(pr_nmvendedor, '&', 'E')
                ,nrcpf           = pr_nrcpf          
                ,dsemail         = pr_dsemail        
                ,idcooperado_cdc = pr_idcooperado_cdc
				,idcomissao      = pr_idcomissao 
          WHERE idvendedor  =  pr_idvendedor;    
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tbepr_cdc_vendedor: '||SQLERRM;
          RAISE vr_exc_erro;
        END;
     
    END IF;

      
  EXCEPTION
    WHEN vr_exc_erro THEN
    pr_dscritic := vr_dscritic;  
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao manter vendedor: '||SQLERRM;        
  END pc_manter_vendedor; 
  
  --> Cadastra Vendedor
  PROCEDURE pc_cadastra_vendedor(pr_idvendedor       IN tbepr_cdc_vendedor.idvendedor%type      --> Identificacao do vendedor
                                ,pr_nmvendedor       IN tbepr_cdc_vendedor.nmvendedor%type      --> Nome do vendedor
                                ,pr_nrcpf            IN tbepr_cdc_vendedor.nrcpf%type           --> Numero do CPF
                                ,pr_dsemail          IN tbepr_cdc_vendedor.dsemail%type         --> Descricao do email
                                ,pr_idcomissao       IN tbepr_cdc_vendedor.idcomissao%type      --> Comissão
                                ,pr_idcooperado_cdc  IN tbepr_cdc_vendedor.idcooperado_cdc%type --> Identificacao do lojista
                                ,pr_dscritic         OUT VARCHAR2) IS                           --> Retorno de Erro          
  
    -- Tratamento de erros
    vr_idvendedor tbepr_cdc_vendedor.idvendedor%TYPE;

  BEGIN
    
    vr_idvendedor := pr_idvendedor;
    
    --> Cadastra Vendedor
    pc_manter_vendedor  (pr_idvendedor       => vr_idvendedor        --> Identificacao do vendedor
                        ,pr_nmvendedor       => pr_nmvendedor        --> Nome do vendedor
                        ,pr_nrcpf            => pr_nrcpf             --> Numero do CPF
                        ,pr_dsemail          => pr_dsemail           --> Descricao do email
                        ,pr_idcomissao       => pr_idcomissao        --> Comissão
                        ,pr_idcooperado_cdc  => pr_idcooperado_cdc   --> Identificacao do lojista
                        ,pr_dscritic         => pr_dscritic);        --> Retorno de Erro 
          
  END pc_cadastra_vendedor;   

  --> Gravar Vendedor do emprestimo
  PROCEDURE pc_manter_empr_cdc_prog (pr_cdcooper         IN tbepr_cdc_emprestimo.cdcooper%type  --> Codigo da cooperativa
                                    ,pr_nrdconta         IN tbepr_cdc_emprestimo.nrdconta%type  --> Numero da conta
                                    ,pr_nrctremp         IN tbepr_cdc_emprestimo.nrctremp%type  --> Numero da proposta
                                    ,pr_cdcoploj         IN tbepr_cdc_emprestimo.cdcooper%type  --> Codigo da cooperativa
                                    ,pr_nrctaloj         IN tbepr_cdc_emprestimo.nrdconta%type  --> Numero da conta                                      
                                    ,pr_dsvendedor       IN varchar2 --> descricao do vendedor
                                    ,pr_vlrepasse        IN tbepr_cdc_emprestimo.vlrepasse%type --> valor de repasse lojista
                                    ,pr_dscritic         OUT VARCHAR2) IS                              --> Retorno de OK/NOK 

  /* .............................................................................
    Programa: pc_manter_empr_cdc_prog
    Sistema : Integração CDC x Autorizador
    Sigla   : CRED
    Autor   : 
    Data    :                             Ultima atualizacao: 15/06/2018 
      
    Dados referentes ao programa:
      
    Frequencia: Sempre que for chamado
    Objetivo  : Gravar Vendedor do emprestimo
      
    Alteracoes: 
  ............................................................................. */
    ------>> CURSORES <<------
    CURSOR cr_tbsite_cooperado_cdc (pr_nrdconta tbsite_cooperado_cdc.nrdconta%TYPE,
                                    pr_cdcooper tbsite_cooperado_cdc.cdcooper%TYPE)IS
      SELECT t.idcooperado_cdc
        FROM tbsite_cooperado_cdc t
            ,crapcdr c
       WHERE c.cdcooper = t.cdcooper
         AND c.nrdconta = t.nrdconta
         AND c.flgconve = 1 -- convenio ativo
         AND t.nrdconta = pr_nrdconta
         AND t.cdcooper = pr_cdcooper
         AND t.idmatriz IS NULL;

     rw_tbsite_cooperado_cdc cr_tbsite_cooperado_cdc%ROWTYPE;   

    CURSOR cr_tbsite_cooperado_cdc_2 (pr_nrdconta tbsite_cooperado_cdc.nrdconta%TYPE,
                                      pr_cdcooper tbsite_cooperado_cdc.cdcooper%TYPE)IS
     SELECT cdc.idcooperado_cdc
       FROM crapass              ass,
            crapcdr              crd,
            tbsite_cooperado_cdc cdc,
            crapass              as2
      WHERE ass.nrcpfcgc = as2.nrcpfcgc
        AND ass.cdcooper <> as2.cdcooper
        AND crd.cdcooper = ass.cdcooper
        AND crd.nrdconta = ass.nrdconta
        AND crd.flgconve = 1
        AND cdc.cdcooper = ass.cdcooper
        AND cdc.nrdconta = ass.nrdconta
        AND cdc.idmatriz IS NULL
        AND as2.cdcooper = pr_cdcooper
        AND as2.nrdconta = pr_nrdconta
        AND EXISTS (SELECT 1
               FROM tbepr_cdc_vendedor
              WHERE idcooperado_cdc = cdc.idcooperado_cdc);
 
   

    -- Buscar os vendedores cdc
    CURSOR cr_vendedor ( pr_idcooperado_cdc tbepr_cdc_vendedor.idcooperado_cdc%TYPE,
                         pr_idvendedor      tbepr_cdc_vendedor.idvendedor%TYPE) IS
      SELECT idvendedor
        FROM tbepr_cdc_vendedor
       WHERE idcooperado_cdc = pr_idcooperado_cdc
         AND idvendedor      = pr_idvendedor     ;
    rw_vendedor cr_vendedor%ROWTYPE;

    -- Tratamento de erros
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_erro EXCEPTION;
    
    vr_idvendedor INTEGER;

  BEGIN
    
    -- verifica existência da conta
    OPEN cr_tbsite_cooperado_cdc(pr_nrdconta => pr_nrctaloj,
                                 pr_cdcooper => pr_cdcoploj);
    FETCH cr_tbsite_cooperado_cdc INTO rw_tbsite_cooperado_cdc;

    -- Se não encontrou a conta
    IF cr_tbsite_cooperado_cdc%NOTFOUND THEN
      -- Fechar cursor
      CLOSE cr_tbsite_cooperado_cdc;
      
      -- verifica existência de convenio ativo para o cnpj da conta recebida
      OPEN cr_tbsite_cooperado_cdc_2(pr_nrdconta => pr_nrctaloj,
                                     pr_cdcooper => pr_cdcoploj);
      FETCH cr_tbsite_cooperado_cdc_2 INTO rw_tbsite_cooperado_cdc;
      
      IF cr_tbsite_cooperado_cdc_2%NOTFOUND THEN
        -- Fechar cursor
        CLOSE cr_tbsite_cooperado_cdc_2;
        
        -- Gerar crítica
        vr_dscritic := 'Lojista não cadastrado';
        
        -- Levantar exceção
        RAISE vr_exc_erro;
      ELSE
        -- Fechar cursor
        CLOSE cr_tbsite_cooperado_cdc_2;
      END IF;
    ELSE
    -- Fechar cursor
    CLOSE cr_tbsite_cooperado_cdc;
    END IF;
 
    
    IF TRIM(vr_idvendedor) IS NULL THEN
    BEGIN
      vr_idvendedor := TO_NUMBER(TRIM( gene0002.fn_busca_entrada(pr_postext => 1,
                                                       pr_dstext => pr_dsvendedor,
                                                       pr_delimitador => '-')),'999999999999999');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel identificar vendedor.'||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Buscar os vendedores cdc
    OPEN cr_vendedor ( pr_idcooperado_cdc => rw_tbsite_cooperado_cdc.idcooperado_cdc,
                       pr_idvendedor      => vr_idvendedor);
    FETCH cr_vendedor INTO rw_vendedor;
    IF cr_vendedor%NOTFOUND THEN
      CLOSE cr_vendedor;
      vr_dscritic := 'Vendedor nao encontrado ou não vinculado a este lojista.';
      RAISE vr_exc_erro;   
    ELSE
      CLOSE cr_vendedor;
    END IF;
    END IF;
    
    pc_manter_emprestimo_cdc(pr_cdcooper         => pr_cdcooper   --> Codigo da cooperativa
                            ,pr_nrdconta         => pr_nrdconta   --> Numero da conta
                            ,pr_nrctremp         => pr_nrctremp   --> Numero da proposta
                            ,pr_idvendedor       => vr_idvendedor --> identificacao do vendedor
                            ,pr_idcooperado_cdc  => rw_tbsite_cooperado_cdc.idcooperado_cdc --> Identificacao do lojista
                            ,pr_vlrepasse        => pr_vlrepasse --> valor do repasse lojista
                            ,pr_cdcooper_cred    => pr_cdcoploj   --> Codigo da cooperativa
                            ,pr_nrdconta_cred    => pr_nrctaloj   --> Numero da conta
                            ,pr_dscritic         => vr_dscritic); --> Retorno de OK/NOK 

    IF vr_dscritic IS NOT NULL THEN
     RAISE vr_exc_erro;    
    END IF;                   
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := gene0007.fn_caract_acento(vr_dscritic);
    WHEN OTHERS THEN
      pr_dscritic := gene0007.fn_caract_acento('Nao foi possivel gravar vendedor do emprestimo: '||SQLERRM);
  END pc_manter_empr_cdc_prog;   

  --> Inclui Vendedor
  PROCEDURE pc_manter_emprestimo_cdc(pr_cdcooper         IN tbepr_cdc_emprestimo.cdcooper%type  --> Codigo da cooperativa
                                    ,pr_nrdconta         IN tbepr_cdc_emprestimo.nrdconta%type  --> Numero da conta
                                    ,pr_nrctremp         IN tbepr_cdc_emprestimo.nrctremp%type  --> Numero da proposta
                                    ,pr_idvendedor       IN tbepr_cdc_emprestimo.idvendedor%type --> identificacao do vendedor
                                    ,pr_idcooperado_cdc  IN tbepr_cdc_emprestimo.idcooperado_cdc%type  --> Identificacao do lojista
                                    ,pr_vlrepasse        IN tbepr_cdc_emprestimo.vlrepasse%type        --> Valor repasse lojista
                                    ,pr_cdcooper_cred    IN tbepr_cdc_emprestimo.cdcooper_cred%type  --> Codigo da cooperativa de credito
                                    ,pr_nrdconta_cred    IN tbepr_cdc_emprestimo.nrdconta_cred%type  --> Numero da conta de credito
                                    ,pr_dscritic         OUT VARCHAR2) IS                              --> Retorno de OK/NOK 

    -- Tratamento de erros
    vr_dscritic crapcri.dscritic%TYPE;

  BEGIN
    
    BEGIN
      insert into tbepr_cdc_emprestimo
                 (cdcooper
                 ,nrdconta
                 ,nrctremp
                 ,idvendedor
                 ,idcooperado_cdc
                 ,vlrepasse
                 ,cdcooper_cred
                 ,nrdconta_cred)
           values(pr_cdcooper
                 ,pr_nrdconta
                 ,pr_nrctremp
                 ,decode(pr_idvendedor,0,null,pr_idvendedor)
                 ,pr_idcooperado_cdc
                 ,pr_vlrepasse
                 ,pr_cdcooper_cred
                 ,pr_nrdconta_cred);
    EXCEPTION
      WHEN dup_val_on_index THEN
        BEGIN
          UPDATE tbepr_cdc_emprestimo 
             SET idcooperado_cdc  = pr_idcooperado_cdc
                --,idvendedor = decode(pr_idvendedor,0,null,pr_idvendedor) --> Vendedor não deve ser alterado
                ,vlrepasse  = pr_vlrepasse
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctremp = pr_nrctremp;      
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tbepr_cdc_emprestimo: '||SQLERRM;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir tbepr_cdc_emprestimo: '||SQLERRM;
    END;

    pr_dscritic := vr_dscritic;

  END pc_manter_emprestimo_cdc;   

  --> Rotina para listar do vendedor
  PROCEDURE pc_lista_vendedor(pr_idcooperado_cdc   IN tbepr_cdc_vendedor.idcooperado_cdc%type --> Identificacao do lojista
                             ,pr_idvendedor        IN tbepr_cdc_vendedor.idvendedor%type      --> Identificacao do vendedor
                             ,pr_retorno           OUT xmltype                                --> XML de retorno
                             ,pr_dscritic          OUT VARCHAR2) IS
    -- Exceções
    vr_exc_erro EXCEPTION;
    vr_xml xmltype; -- XML que sera enviado
    vr_contador      NUMBER := 0;

    -- Cursor para buscar os vendedores cdc
    CURSOR cr_vendedor IS
      select idvendedor
            ,nmvendedor
            ,nrcpf
            ,dsemail
            ,idcomissao
            ,idcooperado_cdc
        from tbepr_cdc_vendedor
       where idcooperado_cdc = decode(nvl(pr_idcooperado_cdc,0),0,idcooperado_cdc,pr_idcooperado_cdc)
       and   idvendedor      = decode(nvl(pr_idvendedor,0),0,idvendedor,pr_idvendedor);
  BEGIN
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Vendedores/>');

    -- Loop sobre a tabela de segmentos
    FOR rw_vendedor IN cr_vendedor LOOP

      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Vendedores'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Vendedor'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);

      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Vendedor'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idvendedor'
                            ,pr_tag_cont => rw_vendedor.idvendedor
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Vendedor'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nmvendedor'
                            ,pr_tag_cont => rw_vendedor.nmvendedor
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Vendedor'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nrcpf'
                            ,pr_tag_cont => rw_vendedor.nrcpf
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Vendedor'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dsemail'
                            ,pr_tag_cont => rw_vendedor.dsemail
                            ,pr_des_erro => pr_dscritic); 
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Vendedor'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idcomissao'
                            ,pr_tag_cont => rw_vendedor.idcomissao
                            ,pr_des_erro => pr_dscritic);                                                                                                                
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Vendedor'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idcooperado_cdc'
                            ,pr_tag_cont => rw_vendedor.idcooperado_cdc
                            ,pr_des_erro => pr_dscritic);                                
      vr_contador := vr_contador + 1; 
    END LOOP;

    -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Vendedor não cadastrado.';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    pr_retorno := vr_xml;

  EXCEPTION
   WHEN vr_exc_erro THEN   
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
   WHEN OTHERS THEN
     -- Montar descrição de erro não tratado
     pr_dscritic := 'Erro não tratado na pc_lista_vendedor: ' ||SQLERRM;
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_lista_vendedor;
 
  --> Rotina para listar estado
  PROCEDURE pc_retorna_estado_atua(pr_retorno    OUT xmltype        --> XML de retorno
                                  ,pr_dscritic   OUT VARCHAR2) IS   --> Retorno de Erro  
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Tratamento de erros
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
     vr_contador      NUMBER := 0;

    -- Cursor para buscar produtos
    CURSOR cr_uf IS
      select tuf.cduf
            ,tuf.nmuf
        from tbcadast_uf tuf
        join crapmun mun on (mun.cdestado=tuf.cduf)
        join tbgen_cid_atuacao_coop tcac on (mun.cdcidade=tcac.cdcidade)
       group by tuf.cduf
               ,tuf.nmuf
       order by tuf.cduf;  

  BEGIN

    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Estados/>');

    -- Loop sobre a tabela de pessoas
    FOR rw_uf IN cr_uf LOOP
      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Estados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Estado'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic); 

      -- Insere os detalhes - Municipio/Cooperativa
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Estado'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cduf'
                            ,pr_tag_cont => rw_uf.cduf
                            ,pr_des_erro => pr_dscritic); 
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Estado'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nmuf'
                            ,pr_tag_cont => rw_uf.nmuf
                            ,pr_des_erro => pr_dscritic); 

      vr_contador := vr_contador +1;
    END LOOP;

    -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Estados não encontrados.';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    -- Retorno
    pr_retorno := vr_xml;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || vr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na tbepr_cdc_vendedor: ' ||SQLERRM;  
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_retorna_estado_atua; 
 
  --> Retorna Municipio
  PROCEDURE pc_retorna_munic_atua(pr_cdestado   IN crapmun.cdestado%type  --> Codigo do estado 
                                 ,pr_retorno    OUT xmltype               --> XML de retorno
                                 ,pr_dscritic   OUT VARCHAR2) IS          --> Retorno de Erro  
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Tratamento de erros
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis gerais
    vr_xml xmltype;  -- XML que sera enviado
    vr_contador      NUMBER := 0;

    -- Cursor para buscar produtos
    CURSOR cr_municipio IS
      select mun.cdcidade
            ,mun.dscidade
            ,mun.cdcidbge
        from crapmun mun
        join tbgen_cid_atuacao_coop tcac on (mun.cdcidade=tcac.cdcidade)
       where upper(mun.cdestado) = upper(pr_cdestado)
       group by mun.cdcidade
               ,mun.dscidade
               ,mun.cdcidbge; 

  BEGIN

    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Municipios/>');

    -- Loop sobre a tabela de pessoas
    FOR rw_municipio IN cr_municipio LOOP
      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Municipios'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Municipio'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic); 

      -- Insere os detalhes - Municipio/Cooperativa
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Municipio'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdcidade'
                            ,pr_tag_cont => rw_municipio.cdcidade
                            ,pr_des_erro => pr_dscritic); 
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Municipio'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dscidade'
                            ,pr_tag_cont => rw_municipio.dscidade
                            ,pr_des_erro => pr_dscritic); 
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Municipio'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'cdcidbge'
                            ,pr_tag_cont => rw_municipio.cdcidbge
                            ,pr_des_erro => pr_dscritic); 

      vr_contador := vr_contador +1;
    END LOOP;

    -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Municipio não encontrado.';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    -- Retorno
    pr_retorno := vr_xml;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || vr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na tbepr_cdc_vendedor: ' ||SQLERRM;  
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>'); 
  END pc_retorna_munic_atua;

  --> Login do Logista
  PROCEDURE pc_login_lojista(pr_dslogin   in tbepr_cdc_usuario.dslogin%type  --> Login do usuario
                            ,pr_dssenha   in tbepr_cdc_usuario.dssenha%type  --> Senha do usuario
                            ,pr_dstoken   in tbepr_cdc_usuario.dstoken_ios%type --> Token 
                            ,pr_retorno   OUT xmltype                        --> XML de retorno
                            ,pr_dscritic  OUT VARCHAR2)IS                    --> Retorno de Erro
    
  /* .............................................................................
    Programa: pc_login_lojista
    Sistema : Integração CDC x Autorizador
    Sigla   : CRED
    Autor   : 
    Data    :                             Ultima atualizacao: 15/06/2018 
      
    Dados referentes ao programa:
      
    Frequencia: Sempre que for chamado
    Objetivo  : Login do Logista
      
    Alteracoes: 15/06/2018 - Verificar usuario ativo.
                             PRJ439 (Odirlei-AMcom)
    
  ............................................................................. */
  
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    vr_contador      NUMBER := 0;

    token   tbepr_cdc_usuario.dstoken_ios%type := pr_dstoken;
    ios     tbepr_cdc_usuario.dstoken_ios%type := '';
    android tbepr_cdc_usuario.dstoken_android%type := '';
    web     tbepr_cdc_usuario.dstoken_web%type := '';
    
    valortoken varchar2(1000);

    -- Cursor para buscar os segmentos cdc
    CURSOR cr_login IS
      SELECT tcu.idusuario  
            ,tcu.dslogin
            ,tcu.dssenha
            ,TO_CHAR(tcu.dtinsori, 'DD/MM/YYYY')  dtinsori
            ,TO_CHAR(tcu.DTREFATU, 'DD/MM/YYYY')  dtrefatu
            ,tcu.flgativo
            ,tcu.flgadmin
            ,tcuv.idcooperado_cdc
            ,tcuv.idvendedor
            ,0  primeiro_login
            ,tcu.dstoken_ios
            ,tcu.dstoken_android
            ,tcu.dstoken_web
       FROM tbepr_cdc_usuario tcu
       JOIN tbepr_cdc_usuario_vinculo tcuv on (tcuv.idusuario=tcu.idusuario)
      WHERE upper(tcu.dslogin)= upper(pr_dslogin)
        AND upper(tcu.dssenha)= upper(pr_dssenha)
        AND tcu.flgativo = 1;
   
  BEGIN

    valortoken := substr(token,1,instr(token,':')-1);
    token :=substr(token,instr(token,':')+1,length(token));
    
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Usuarios/>');

    -- Loop sobre a tabela de login
    FOR rw_login IN cr_login LOOP

    -- update do token
      if lower(valortoken) = 'dstoken_ios' then
        update tbepr_cdc_usuario u set u.dstoken_ios = token where u.dslogin = rw_login.dslogin and u.dssenha = rw_login.dssenha;
        ios := token;
      end if;
      if lower(valortoken) = 'dstoken_android' then
        update tbepr_cdc_usuario u set u.dstoken_android = token where u.dslogin = rw_login.dslogin and u.dssenha = rw_login.dssenha;
        android := token;
      end if;
      if lower(valortoken) = 'dstoken_web' then
        update tbepr_cdc_usuario u set u.dstoken_web = token where u.dslogin = rw_login.dslogin and u.dssenha = rw_login.dssenha;   
        web := token;
      end if;

      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuarios'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Usuario'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idusuario'
                            ,pr_tag_cont => rw_login.idusuario
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dslogin'
                            ,pr_tag_cont => rw_login.dslogin
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dssenha'
                            ,pr_tag_cont => rw_login.dssenha
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dtinsori'
                            ,pr_tag_cont => rw_login.dtinsori
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dtrefaut'
                            ,pr_tag_cont => rw_login.dtrefatu
                            ,pr_des_erro => pr_dscritic);                                                                                                                
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'flgativo'
                            ,pr_tag_cont => rw_login.flgativo
                            ,pr_des_erro => pr_dscritic);    
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'flgadmin'
                            ,pr_tag_cont => rw_login.flgadmin
                            ,pr_des_erro => pr_dscritic);           
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idcooperado_cdc'
                            ,pr_tag_cont => rw_login.idcooperado_cdc
                            ,pr_des_erro => pr_dscritic);    
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idvendedor'
                            ,pr_tag_cont => rw_login.idvendedor
                            ,pr_des_erro => pr_dscritic);    
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'primeiro_login'
                            ,pr_tag_cont => rw_login.primeiro_login
                            ,pr_des_erro => pr_dscritic);                                                                                                             
                            
      if lower(valortoken) = 'dstoken_ios' then
         gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'Usuario'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dstoken_ios'
                              ,pr_tag_cont => ios
                              ,pr_des_erro => pr_dscritic);   
       else
         gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'Usuario'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dstoken_ios'
                              ,pr_tag_cont => rw_login.dstoken_ios
                              ,pr_des_erro => pr_dscritic);   
       
       end if;  
      if lower(valortoken) = 'dstoken_android' then
         gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'Usuario'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dstoken_android'
                              ,pr_tag_cont => android
                              ,pr_des_erro => pr_dscritic); 
       else
         gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'Usuario'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dstoken_android'
                              ,pr_tag_cont => rw_login.dstoken_android
                              ,pr_des_erro => pr_dscritic);          
       end if;  
      if lower(valortoken) = 'dstoken_web' then
         gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'Usuario'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dstoken_web'
                              ,pr_tag_cont => web
                              ,pr_des_erro => pr_dscritic);
       else
         gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'Usuario'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dstoken_web'
                              ,pr_tag_cont => rw_login.dstoken_web
                              ,pr_des_erro => pr_dscritic);         
       end if;                                                                                                                                                                                                     

      -- Log de acesso bem sucedido
      cecred.empr0012.pc_grava_log(pr_idlog => 0,
                               pr_dtoperacao => sysdate,
                               pr_hroperacao => sysdate,
                               pr_nmoperacao => 'LOGIN USUARIO',
                               pr_dsoperacao => 'ENTRADA NO SISTEMA, LOGIN='||upper(pr_dslogin),
                               pr_dsorigem => replace(lower(valortoken),'dstoken_',''),
                               pr_idcooperado_cdc => rw_login.idcooperado_cdc,
                               pr_idusuario => rw_login.idusuario,
                               pr_dscritic => pr_dscritic);

      vr_contador := vr_contador + 1; 
      
    END LOOP;

    -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN

      -- Log de acesso indevido
      cecred.empr0012.pc_grava_log(pr_idlog => 0,
                               pr_dtoperacao => sysdate,
                               pr_hroperacao => sysdate,
                               pr_nmoperacao => 'LOGIN USUARIO',
                               pr_dsoperacao => 'ACESSO INDEVIDO, LOGIN='||upper(pr_dslogin),
                               pr_dsorigem => replace(lower(valortoken),'dstoken_',''),
                               pr_idcooperado_cdc => null,
                               pr_idusuario => null,
                               pr_dscritic => pr_dscritic);

      -- Atualiza base de dados
      Commit;
      
      -- Gerar crítica
      pr_dscritic    := 'Usuário não cadastrado.';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    -- Atualiza base de dados
    Commit;

    -- Retorna xml
    pr_retorno := vr_xml;

  EXCEPTION
   WHEN vr_exc_erro THEN   
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
   WHEN OTHERS THEN
     -- Montar descrição de erro não tratado
     pr_dscritic := 'Erro não tratado na pc_login_lojista: ' ||SQLERRM;
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_login_lojista;


  --> Rotina para listar do usuario
  PROCEDURE pc_lista_usuario(pr_idusuario         IN tbepr_cdc_usuario.idusuario%type        --> Identificacao do usuario
                            ,pr_idcooperado_cdc  IN tbepr_cdc_vendedor.idcooperado_cdc%type --> Identificacao do lojista
                            ,pr_retorno          OUT xmltype                                --> XML de retorno
                            ,pr_dscritic         OUT VARCHAR2) IS                           --> Retorno de Erro
  /* .............................................................................
    Programa: pc_lista_usuario
    Sistema : Integração CDC x Autorizador
    Sigla   : CRED
    Autor   : 
    Data    :                             Ultima atualizacao: 15/06/2018 
      
    Dados referentes ao programa:
      
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para listar do usuario
      
    Alteracoes: 15/06/2018 - Alterado cursor cr_usuario.
                             PRJ439 (Odirlei-AMcom)
    
  ............................................................................. */
  
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Tratamento de erros
    --vr_cdcritic crapcri.cdcritic%TYPE;
    --vr_dscritic crapcri.dscritic%TYPE;
    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    vr_contador      NUMBER := 0;

    -- Cursor para buscar os segmentos cdc
    CURSOR cr_usuario IS
      SELECT d.nmvendedor nmusuario
            ,d.dsemail    dsemail
            ,u.dslogin 
            ,u.dssenha
            ,TO_CHAR(u.dtinsori, 'DD/MM/YYYY')  dtinsori
            ,u.flgadmin tpusuario
            ,u.idusuario     idusuario
            ,v.idvendedor    idvendedor
            ,v.idcooperado_cdc
            ,u.flgativo
            ,u.DSTOKEN_IOS
            ,u.DSTOKEN_ANDROID
            ,u.DSTOKEN_WEB
       from tbepr_cdc_usuario u
       join tbepr_cdc_usuario_vinculo v on (u.idusuario=v.idusuario)
       join tbepr_cdc_vendedor d on (d.idvendedor=v.idvendedor)
       left join tbsite_cooperado_cdc s on (s.idcooperado_cdc=v.idcooperado_cdc)
      where v.idcooperado_cdc = decode(pr_idcooperado_cdc,0,v.idcooperado_cdc,pr_idcooperado_cdc)
        and v.idusuario       = decode(pr_idusuario,0,v.idusuario,pr_idusuario)
      order by 1,2,3;
      
  BEGIN
    
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Usuarios/>');

    -- Loop sobre a tabela de segmentos
    FOR rw_usuario IN cr_usuario LOOP

      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuarios'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Usuario'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);

      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nmusuario'
                            ,pr_tag_cont => rw_usuario.nmusuario
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'email'
                            ,pr_tag_cont => rw_usuario.dsemail
                            ,pr_des_erro => pr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dslogin'
                            ,pr_tag_cont => rw_usuario.dslogin
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dssenha'
                            ,pr_tag_cont => rw_usuario.dssenha
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dtinsori'
                            ,pr_tag_cont => rw_usuario.dtinsori
                            ,pr_des_erro => pr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'flgativo'
                            ,pr_tag_cont => rw_usuario.flgativo
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idcooperado_cdc'
                            ,pr_tag_cont => rw_usuario.idcooperado_cdc
                            ,pr_des_erro => pr_dscritic);                                                                                                                

      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'tpUsuario'
                            ,pr_tag_cont => rw_usuario.tpusuario
                            ,pr_des_erro => pr_dscritic);    
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idUsuario'
                            ,pr_tag_cont => rw_usuario.idusuario
                            ,pr_des_erro => pr_dscritic);    
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idVendedor'
                            ,pr_tag_cont => rw_usuario.idvendedor
                            ,pr_des_erro => pr_dscritic);    
                            
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'DSTOKEN_IOS'
                            ,pr_tag_cont => rw_usuario.DSTOKEN_IOS
                            ,pr_des_erro => pr_dscritic);    
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'DSTOKEN_ANDROID'
                            ,pr_tag_cont => rw_usuario.DSTOKEN_ANDROID
                            ,pr_des_erro => pr_dscritic);    
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'DSTOKEN_WEB'
                            ,pr_tag_cont => rw_usuario.DSTOKEN_WEB
                            ,pr_des_erro => pr_dscritic);    
                            
      vr_contador := vr_contador + 1; 
    END LOOP;

    -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Usuário não cadastrado.';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    pr_retorno := vr_xml;

  EXCEPTION
   WHEN vr_exc_erro THEN   
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
   WHEN OTHERS THEN
     -- Montar descrição de erro não tratado
     pr_dscritic := 'Erro não tratado na pc_lista_usuario: ' ||SQLERRM;
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_lista_usuario;

  --> Rotina referente a finalizacao de documento CDC
  PROCEDURE pc_atualiza_doc_digital(pr_dadosxml      in XMLType                --> xml de pendencias 
                                   ,pr_dscritic      OUT VARCHAR2)IS            --> Retorno de Erro                                                                     

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_atualiza_doc_digital
    Sistema : Reestruturacao do CDC
    Sigla   : CRED
    Autor   : José Carvalho
    Data    : 11/05/2018                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: 
    Objetivo  : Criar serviço que será acionado pela a Selbetti para informar que o fluxo de documentos foi finalizado.

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*/
  -- Verificar existência

   -- Exceções
   vr_exc_erro EXCEPTION;
   vr_exc_saida EXCEPTION;
   -- Tratamento de erros
   vr_dscritic crapcri.dscritic%TYPE;
   vr_cdcritic crapcri.cdcritic%TYPE;
   -- Variaveis gerais
   vr_cdcooper         VARCHAR2(100);
   vr_nrdconta         VARCHAR2(100);
   vr_nrctremp         VARCHAR2(100);
   vr_flgdocdg         VARCHAR2(100);
   vr_rowid            ROWID;

   CURSOR cr_crawepr IS
     select epr.rowid
           ,epr.cdcooper
           ,epr.nrdconta
           ,epr.nrctremp
       from crawepr epr
      where epr.cdcooper=to_number(vr_cdcooper)
        and epr.nrdconta=to_number(vr_nrdconta)
        and epr.nrctremp=to_number(vr_nrctremp);
     rw_crawepr cr_crawepr%ROWTYPE;

   --> Cursor de Emprestimos
   CURSOR cr_crapepr IS
     SELECT 1              
       FROM crapepr
      WHERE crapepr.cdcooper = to_number(vr_cdcooper)
        AND crapepr.nrdconta = to_number(vr_nrdconta)
        AND crapepr.nrctremp = to_number(vr_nrctremp);
    rw_crapepr cr_crapepr%ROWTYPE;

  BEGIN

    -- obtem dados da chave da tbepr_cdc_empr_doc do xml.
    BEGIN 
      SELECT ExtractValue(pr_dadosxml, '/pendencias/cdcooper/text()')
            ,ExtractValue(pr_dadosxml, '/pendencias/nrdconta/text()')
            ,ExtractValue(pr_dadosxml, '/pendencias/nrctremp/text()')
            ,ExtractValue(pr_dadosxml, '/pendencias/flgdocdg/text()')
        INTO vr_cdcooper
            ,vr_nrdconta
            ,vr_nrctremp
            ,vr_flgdocdg
        FROM (SELECT pr_dadosxml  FROM DUAL);
    EXCEPTION
      WHEN OTHERS THEN
       vr_dscritic := 'XML invalido'||SQLERRM;
       RAISE vr_exc_erro;
    END;

    vr_nrdconta := to_number(REPLACE(vr_nrdconta,'.',''));
    vr_nrctremp := to_number(REPLACE(vr_nrctremp,'.',''));

    IF nvl(vr_cdcooper, 0) = 0 or nvl(vr_nrdconta, 0) = 0 or nvl(vr_nrctremp, 0) = 0 THEN
      vr_dscritic := 'Dados de entrada invalidos.';
      RAISE vr_exc_erro;
    END IF;

    GENE0001.pc_gera_log(pr_cdcooper => to_number(vr_cdcooper)
                        ,pr_cdoperad => 'AUTOCDC'
                        ,pr_dscritic => 'Contrato: ' || vr_nrctremp || ' Retorno: ' || vr_flgdocdg
                        ,pr_dsorigem => 'INT_CDC'
                        ,pr_dstransa => 'Integracao Smart Share - CDC'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 -- TRUE
                        ,pr_hrtransa => GENE0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'AUTOCDC'
                        ,pr_nrdconta => to_number(vr_nrdconta)
                        ,pr_nrdrowid => vr_rowid); 

    -- verifica existência da conta
    OPEN cr_crawepr;
    FETCH cr_crawepr INTO rw_crawepr;

    -- Se não encontrou a conta
    IF cr_crawepr%NOTFOUND THEN
      -- Fechar cursor
      CLOSE cr_crawepr;
      -- Gerar crítica
      vr_dscritic := 'Proposta nao encontrada.';
      -- Levantar exceção
      RAISE vr_exc_saida;
    END IF;

    -- Busca dos detalhes do empréstimo
    OPEN cr_crapepr;
    FETCH cr_crapepr INTO rw_crapepr;
    -- Se encontrar informações
    IF cr_crapepr%FOUND THEN
      CLOSE cr_crapepr;
      -- Gerar critica 
      vr_cdcritic := 970; --> 970 - Proposta ja efetivada.
      vr_dscritic := 'Proposta ja efetivada';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapepr;
    END IF;

    -- se o fluxo foi aprovado e finalizado com sucesso
    IF nvl(vr_flgdocdg, 0) = 1 THEN 

        BEGIN
          --Finaliza o documento
          update crawepr e set e.flgdocdg = 1 where rowid=rw_crawepr.rowid;

          -- limpa as pendencias
          delete 
            from tbepr_cdc_empr_doc d
           where d.cdcooper=rw_crawepr.cdcooper
             and d.nrdconta=rw_crawepr.nrdconta
             and d.nrctremp=rw_crawepr.nrctremp;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar crawepr: '||SQLERRM;
            RAISE vr_exc_erro;
        END;

    ELSE -- se for zero ou nulo

      -- limpa as pendencias
      delete tbepr_cdc_empr_doc d
       where d.cdcooper=rw_crawepr.cdcooper
         and d.nrdconta=rw_crawepr.nrdconta
         and d.nrctremp=rw_crawepr.nrctremp;  

      FOR rw_ocorrencia IN (SELECT ExtractValue(Value(pendencia),'doc/nrdoc/text()') as nrdoc
                                  ,ExtractValue(Value(pendencia),'doc/dstipo_doc/text()') as dstipo_doc
                                  ,ExtractValue(Value(pendencia),'doc/dsreprovacao/text()') as dsreprovacao
                                  ,ExtractValue(Value(pendencia),'doc/dsobservacao/text()') as dsobservacao
                              FROM TABLE(XMLSequence(Extract(pr_dadosxml,'/pendencias/listaDocumento/doc'))) pendencia) LOOP

        -- insere registros na lista de pendencias para a proposta
        pc_grava_pedencia_emprestimo (pr_cdcooper => rw_crawepr.cdcooper
                                     ,pr_nrdconta => rw_crawepr.nrdconta
                                     ,pr_nrctremp => rw_crawepr.nrctremp
                                     ,pr_dstipo_doc => rw_ocorrencia.dstipo_doc
                                     ,pr_dsreprovacao => rw_ocorrencia.dsreprovacao
                                     ,pr_dsobservacao => rw_ocorrencia.dsobservacao
                                     -->> SAIDA
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);

          
        -- Tratamento de erro de retorno
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          raise vr_exc_erro;
        END IF;

      END LOOP;

      pc_retorna_situacao_ibracred (pr_cdcooper  => rw_crawepr.cdcooper      --> Coodigo Cooperativa
                                   ,pr_nrdconta  => rw_crawepr.nrdconta      --> Numero da Conta do Associado
                                   ,pr_nrctremp  => rw_crawepr.nrctremp      --> Numero do contrato
                                   ,pr_cdoperad  => 1                --> Codigo do operador
                                   ,pr_cdsitprp  => 25               --> Situação da proposta na IBRACRED (Pagamento negado)
                                   -->> SAIDA <<--
                                   ,pr_cdcritic  => vr_cdcritic      --> Código da crítica
                                   ,pr_dscritic  => vr_dscritic);    --> Descrição da crítica

      -- Tratamento de erro de retorno
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        raise vr_exc_erro;
      END IF;

    END IF;

    -- Fechar cursor
    CLOSE cr_crawepr;

    -- Atualiza base de dados
    COMMIT;

    --Retorno OK
    pr_dscritic := null;  

    EXCEPTION
      WHEN vr_exc_saida THEN
        GENE0001.pc_gera_log(pr_cdcooper => to_number(vr_cdcooper)
                            ,pr_cdoperad => 'AUTOCDC'
                            ,pr_dscritic => 'Contrato: ' || vr_nrctremp || ' Retorno: ' || vr_flgdocdg || ' ' || vr_dscritic
                            ,pr_dsorigem => 'INT_CDC'
                            ,pr_dstransa => 'Integracao Smart Share - CDC'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 -- TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'AUTOCDC'
                            ,pr_nrdconta => to_number(vr_nrdconta)
                            ,pr_nrdrowid => vr_rowid); 
        
        pr_dscritic := vr_dscritic;
        commit;
      WHEN vr_exc_erro THEN          
        -- Carregar XML padrao para variavel de retorno
        pr_dscritic := vr_dscritic;
        -- Descaz a atualização
        rollback;
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_dscritic := 'NOK - '|| SQLERRM;
        rollback;
  END pc_atualiza_doc_digital;
  
  
  --> Inclui Log
  PROCEDURE pc_grava_log(pr_idlog           IN tbepr_cdc_log.idlog%type      --> Identificacao do log
                        ,pr_dtoperacao      IN tbepr_cdc_log.dtoperacao%type --> Data da operacao
                        ,pr_hroperacao      IN tbepr_cdc_log.hroperacao%type --> Hora da operacao
                        ,pr_nmoperacao      IN tbepr_cdc_log.nmoperacao%type --> Nome da operacao
                        ,pr_dsoperacao      IN tbepr_cdc_log.dsoperacao%type --> Descricao da operacao
                        ,pr_dsorigem        IN tbepr_cdc_log.dsorigem%type   --> Descricao da origem
                        ,pr_idcooperado_cdc IN tbepr_cdc_log.idcooperado_cdc%type --> Identificacao do cooperado
                        ,pr_idusuario       IN tbepr_cdc_log.idusuario%type  --> Identificacao do usuario
                        ,pr_dscritic        OUT VARCHAR2)IS                  --> Retorno de Erro
            
    -- Tratamento de erros
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_erro EXCEPTION;

  BEGIN
    -- Insere a tabela de log
    BEGIN
      insert into tbepr_cdc_log
                 (dtoperacao
                 ,hroperacao
                 ,nmoperacao
                 ,dsoperacao
                 ,dsorigem
                 ,idcooperado_cdc
                 ,idusuario)
           values(pr_dtoperacao
                 ,pr_hroperacao
                 ,pr_nmoperacao
                 ,pr_dsoperacao
                 ,pr_dsorigem
                 ,pr_idcooperado_cdc
                 ,pr_idusuario);

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir tbepr_cdc_log '||SQLERRM;
            RAISE vr_exc_erro;
    END;

  EXCEPTION
    WHEN vr_exc_erro THEN          
      -- Carregar XML padrao para variavel de retorno
      pr_dscritic := vr_dscritic;
         
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_dscritic := 'Erro na execucao do programa grava log - '|| SQLERRM;
        
  END pc_grava_log;   
  
  
  --> Rotina para retorno dos dados da comissao
  PROCEDURE pc_lista_comissao(pr_idcomissao  IN tbepr_cdc_parm_comissao.idcomissao%type  --> Identificacao da comissao
                             ,pr_retorno     OUT xmltype                                 --> XML de retorno
                             ,pr_dscritic    OUT VARCHAR2)IS                             --> Retorno de Erro
                         
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    vr_contador      NUMBER := 0;

    -- Cursor para buscar as comissoes cdc
    CURSOR cr_comissao IS
      select tcpc.idcomissao
            ,tcpc.nmcomissao
            ,tcpc.tpcomissao
        from tbepr_cdc_parm_comissao tcpc
     --where tcpc.idcomissao = coalesce(pr_idcomissao, tcpc.idcomissao);
       where tcpc.idcomissao = decode(nvl(pr_idcomissao,0),0,tcpc.idcomissao,pr_idcomissao);

  
    -- Cursor para buscar os detalhes das comissoes cdc
    CURSOR cr_detalhe(pr_idcomissao IN tbepr_cdc_parm_comissao.idcomissao%type) IS
   	  select tcpcr.vlinicial
		        ,tcpcr.vlfinal
            ,tcpcr.vlcomissao
	      from tbepr_cdc_parm_comissao_regra tcpcr
	     where tcpcr.idcomissao=pr_idcomissao;

  BEGIN
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Comissoes/>');

    -- Loop sobre a tabela de comissoes
    FOR rw_comissao IN cr_comissao LOOP

      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissoes'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Comissao'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);
      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idcomissao'
                            ,pr_tag_cont => rw_comissao.idcomissao
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nmComissao'
                            ,pr_tag_cont => rw_comissao.nmComissao
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'tpcomissao'
                            ,pr_tag_cont => rw_comissao.tpcomissao
                            ,pr_des_erro => pr_dscritic);
      -- monta regra de comissao            
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Comissao'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'regraComissao'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);

      -- Loop sobre a tabela de comissoes
      FOR rw_detalhe IN cr_detalhe(rw_comissao.idcomissao) LOOP

        -- Insere os detalhes
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'regraComissao'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlInicial'
                              ,pr_tag_cont => rw_detalhe.vlInicial
                              ,pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'regraComissao'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlFinal'
                              ,pr_tag_cont => rw_detalhe.vlFinal
                              ,pr_des_erro => pr_dscritic);   
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'regraComissao'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlComissao'
                              ,pr_tag_cont => rw_detalhe.vlComissao
                              ,pr_des_erro => pr_dscritic);                                                            
                                    
      end loop;
    
      vr_contador := vr_contador + 1; 
    END LOOP;
    
    -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'comissão não cadastrado';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    pr_retorno := vr_xml;

  EXCEPTION
    WHEN vr_exc_erro THEN          
      -- Carregar XML padrao para variavel de retorno
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
   WHEN OTHERS THEN
     -- Montar descrição de erro não tratado
     pr_dscritic := 'Erro não tratado na pc_retorna_segmento: ' || SQLERRM;
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END;

  --> Recuperar senha do usuario
  PROCEDURE pc_recuperar_senha_usuario(pr_dslogin   IN tbepr_cdc_usuario.dslogin%type  --> Login usuario
                                      ,pr_retorno   OUT xmltype                        --> XML de retorno
                                      ,pr_dscritic  OUT VARCHAR2) IS                   --> Retorno de Erro                                                            --> Retorno de Erro
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Tratamento de erros
    --vr_cdcritic crapcri.cdcritic%TYPE;
    --vr_dscritic crapcri.dscritic%TYPE;
    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    vr_contador      NUMBER := 0;

    -- Cursor para buscar usuarios cdc
    CURSOR cr_usuario IS
    select u.idusuario, ve.nmvendedor as  nmusuario, ve.dsemail  
      from tbepr_cdc_usuario u
          ,tbepr_cdc_usuario_vinculo v
          ,tbepr_cdc_vendedor ve 
      where u.flgadmin = 0 
        and u.idusuario = v.idusuario
        and v.idvendedor = ve.idvendedor
        and upper(u.dslogin) = upper(pr_dslogin)
       
    union

    select u.idusuario, lj.nmfantasia as nmusuario, lj.dsemail  
     from tbepr_cdc_usuario u
         ,tbepr_cdc_usuario_vinculo vi
         ,tbsite_cooperado_cdc lj
     where u.flgadmin = 1
       and u.idusuario = vi.idusuario
       and vi.idcooperado_cdc = lj.idcooperado_cdc  
        and upper(u.dslogin) = upper(pr_dslogin);

  BEGIN
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Usuarios/>');

    -- Loop sobre a tabela de segmentos
    FOR rw_usuario IN cr_usuario LOOP

      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuarios'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Usuario'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);

      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idusuario'
                            ,pr_tag_cont => rw_usuario.idusuario
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'nmusuario'
                            ,pr_tag_cont => rw_usuario.nmusuario
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Usuario'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dsemail'
                            ,pr_tag_cont => rw_usuario.dsemail
                            ,pr_des_erro => pr_dscritic);
                
      vr_contador := vr_contador + 1; 
    END LOOP;

    -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Usuario não cadastrado.';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    pr_retorno := vr_xml;

  EXCEPTION
    WHEN vr_exc_erro THEN   
      -- Carregar XML padrao para variavel de retorno
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_lista_vendedor: ' ||SQLERRM;
      -- Carregar XML padrao para variavel de retorno
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_recuperar_senha_usuario;
  
  
  --> Mudar senha do usuario
  PROCEDURE pc_mudar_senha_usuario(pr_idusuario   in tbepr_cdc_usuario.idusuario%type --> identificador do usuario
                                  ,pr_dssenha     in tbepr_cdc_usuario.dssenha%type   --> senha
                                  ,pr_dscritic    OUT VARCHAR2)is                     --> Retorno de Erro                                   

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_mudar_senha_usuario
    Sistema : Reestruturacao do CDC
    Sigla   : CRED
    Autor   : 
    Data    : 24/04/2018                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: 
    Objetivo  : 1.	Este serviço deve apenas atualizar a tabela de usuário para com o novo valor da senha que será enviada via parâmetro de entrada da procedure;

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*/
  -- Verificar existência

   -- Exceções
    vr_exc_erro EXCEPTION;
    -- Tratamento de erros
    --vr_cdcritic crapcri.cdcritic%TYPE;
    --vr_dscritic crapcri.dscritic%TYPE;
    vr_critica crapcri.dscritic%TYPE;
    -- Variaveis gerais

    CURSOR cr_usuario IS
      select u.idusuario
            ,v.idcooperado_cdc
            ,u.dslogin 
            ,u.dssenha
        from tbepr_cdc_usuario u
            ,tbepr_cdc_usuario_vinculo v
       where u.idusuario = v.idusuario
       and   u.idusuario = pr_idusuario
     --and   v.idcooperado_cdc = pr_idcooperado_cdc
     --and   u.dslogin = pr_dslogin;
     --and   u.dssenha = pr_dssenha;
     and rownum <= 1;
 
     rw_usuario cr_usuario%ROWTYPE;    
    
  BEGIN
    
    -- verifica existência da conta
    OPEN cr_usuario;
    FETCH cr_usuario INTO rw_usuario;

    -- Se não encontrou a conta
    IF cr_usuario%NOTFOUND THEN
      -- Fechar cursor
      CLOSE cr_usuario;
      -- Gerar crítica
      vr_critica := 'Usuário não encontrado.';
      -- Levantar exceção
      RAISE vr_exc_erro;
    ELSE
    
      BEGIN
        --altera a senha
      /*
        update(
                 select u.idusuario,v.idcooperado_cdc,u.dslogin ,u.dssenha
                  from tbepr_cdc_usuario u
                         ,tbepr_cdc_usuario_vinculo v
                  where u.idusuario = v.idusuario
                  and   u.idusuario = pr_idusuario
                  and   v.idcooperado_cdc = pr_idcooperado_cdc
                  and   u.dslogin = pr_dslogin) senha
                  --and   u.dssenha = pr_dssenha) senha
                set senha.dssenha = pr_dssenha;
        */
        update tbepr_cdc_usuario u
           set u.dssenha   = pr_dssenha
         where u.idusuario = pr_idusuario;
      EXCEPTION
        WHEN OTHERS THEN
           -- Gerar crítica
           vr_critica := 'Erro ao atualizar tbepr_cdc_usuario: '||SQLERRM;
           RAISE vr_exc_erro;
      END;
    
    END IF;

    -- Fechar cursor
    CLOSE cr_usuario;
    --Retorno
    pr_dscritic := '';  
         
    EXCEPTION
      WHEN vr_exc_erro THEN          
        -- Carregar XML padrao para variavel de retorno
         pr_dscritic := vr_critica;
         
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_dscritic := 'NOK - '|| SQLERRM;
        
  END pc_mudar_senha_usuario;

  --> Criar Lote
  PROCEDURE pc_cria_lote (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do Movimento
                         ,pr_nrdolote IN craplot.nrdolote%TYPE  --> Numero do Lote
                         ,pr_des_reto OUT VARCHAR2         --> Descrição da crítica do lote
                         ,pr_dscritic OUT VARCHAR) IS      --> Descrição da crítica
  BEGIN
    DECLARE
      -- Busca Lote
      CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                       ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                       ,pr_cdagenci IN craplot.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT lot.dtmvtolt
              ,lot.cdagenci
              ,lot.cdbccxlt
              ,lot.nrdolote
              ,NVL(lot.nrseqdig,0) nrseqdig
              ,lot.cdcooper
              ,lot.tplotmov
              ,lot.vlinfodb
              ,lot.vlcompdb
              ,lot.qtinfoln
              ,lot.qtcompln
              ,lot.cdoperad
              ,lot.tpdmoeda
              ,lot.rowid
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtolt
           AND lot.cdagenci = pr_cdagenci
           AND lot.cdbccxlt = pr_cdbccxlt
           AND lot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;
      --                        
      vr_exc_erro EXCEPTION;
      vr_dscritic VARCHAR2(4000);
    BEGIN
      --Controle para verificar se ja inseriu o lote
      IF pr_nrdolote = 650005 THEN
        
        --Verifica existencia do LOTE
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 650005);
        FETCH cr_craplot INTO rw_craplot;
          
        -- Se não encontrou capa do lote
        IF cr_craplot%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_craplot;
            
          BEGIN
            --Inserir a capa do lote retornando informacoes para uso posterior
            INSERT INTO craplot 
                       (dtmvtolt
                       ,cdagenci
                       ,cdbccxlt
                       ,nrdolote
                       ,tplotmov
                       ,cdcooper
                       ,nrseqdig)
                 VALUES  
                       (pr_dtmvtolt
                       ,1
                       ,100
                       ,650005
                       ,1
                       ,pr_cdcooper
                       ,0);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir na tabela craplot (650005). '||SQLERRM;
              --Sair do programa
              RAISE vr_exc_erro;
          END;
        ELSE
          -- Apenas Fecha Cursor
          CLOSE cr_craplot;
        END IF;
      END IF;

      pr_des_reto:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        pr_des_reto:= 'NOK';
        pr_dscritic:= 'Erro ao criar lotes. '||sqlerrm;
    END;                         
  END pc_cria_lote;    


  --> Rotina referente a finalizacao de documento CDC
  PROCEDURE pc_efetuar_repasse_cdc (pr_cdcooper  in crawepr.cdcooper%type  --> cooperativa
                                   ,pr_nrdconta  in crawepr.nrdconta%type  --> numero da conta
                                   ,pr_nrctremp  in crawepr.nrctremp%type  --> numero do contrato
                                   ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2) IS          --> Descrição da crítica

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Cursor Genérico de Calendário
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    -- Busca Emprestimos
    CURSOR cr_rapassecdc (pr_cdcooper  IN crapepr.cdcooper%TYPE     --> cooperativa
                         ,pr_nrdconta  IN crapepr.nrdconta%type     --> numero da conta
                         ,pr_nrctremp  IN crapepr.nrctremp%type     --> numero do contrato
                         ,pr_dtinicial IN crapdat.dtmvtolt%TYPE     -->
                         ,pr_dtfinal   IN crapdat.dtmvtolt%TYPE) IS -->
      select tce.cdcooper_cred  cdcooper_lojista
            ,tce.nrdconta_cred  nrdconta_lojista
            ,tce.vlrepasse
            ,tce.rowid as tbemp_rowid
            ,epr.*
        from crapepr epr
        join crapfin fin on (fin.cdcooper=epr.cdcooper and fin.cdfinemp=epr.cdfinemp and fin.flgstfin = 1 and fin.tpfinali=3)
        join tbepr_cdc_emprestimo tce on (tce.cdcooper=epr.cdcooper and tce.nrdconta=epr.nrdconta and tce.nrctremp=epr.nrctremp and tce.flgrepasse=0)
        join tbsite_cooperado_cdc tcc on (tcc.idcooperado_cdc=tce.idcooperado_cdc)
        join crapcdr cdr on (cdr.cdcooper=tcc.cdcooper and cdr.nrdconta=tcc.nrdconta)  
       where epr.cdcooper=coalesce(pr_cdcooper, epr.cdcooper)
         and epr.nrdconta=coalesce(pr_nrdconta, epr.nrdconta)
         and epr.nrctremp=coalesce(pr_nrctremp, epr.nrctremp)
         and epr.dtmvtolt between pr_dtinicial and pr_dtfinal;

    -- Busca Lote
    CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                     ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                     ,pr_cdagenci IN craplot.cdagenci%TYPE
                     ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                     ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT lot.dtmvtolt
            ,lot.cdagenci
            ,lot.cdbccxlt
            ,lot.nrdolote
            ,NVL(lot.nrseqdig,0) nrseqdig
            ,lot.cdcooper
            ,lot.tplotmov
            ,lot.vlinfodb
            ,lot.vlcompdb
            ,lot.qtinfoln
            ,lot.qtcompln
            ,lot.cdoperad
            ,lot.tpdmoeda
            ,lot.rowid
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtolt
         AND lot.cdagenci = pr_cdagenci
         AND lot.cdbccxlt = pr_cdbccxlt
         AND lot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

    -- Busca Associado
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa,
             ass.nrdconta,
             ass.cdsecext,
             ass.cdagenci,
             ass.cdtipsfx
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Exceções
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;

    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_des_erro VARCHAR2(4000);
    --vr_des_reto VARCHAR2(3);

    -- Variaveis gerais
    vr_cdprogra     crapprg.cdprogra%TYPE := 'ERPRO_CDC';
    vr_rowid        ROWID;

  BEGIN
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => NULL);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
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
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
  
    --Ler Emprestimos
    FOR rw_rapassecdc IN cr_rapassecdc(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => pr_nrctremp
                                      ,pr_dtinicial => rw_crapdat.dtmvtolt-15
                                      ,pr_dtfinal   => rw_crapdat.dtmvtolt) LOOP
    
      --Selecionar Associado
      OPEN cr_crapass (pr_cdcooper => rw_rapassecdc.cdcooper_lojista
                      ,pr_nrdconta => rw_rapassecdc.nrdconta_lojista);

      FETCH cr_crapass INTO rw_crapass;
      
    
      -- Nao encontrou cooperado
      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic:= 9; -- 009 - Associado nao cadastrado.
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic) || ' - ' ||
                      gene0002.fn_mask(pr_nrdconta,'zzzz.zzz.9');
      
        -- Gera Log
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => 'AUTOCDC'
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => 'APP_COOP'
                            ,pr_dstransa => 'Repassse lojista CDC.'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 -- TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'AUTOCDC'
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_rowid
                            );      
      
        -- Finaliza Execução do Programa
        CLOSE cr_crapass;
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapass;

      --Criar os Lotes usados pelo Programa
      pc_cria_lote (pr_cdcooper => rw_rapassecdc.cdcooper_lojista
                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                   ,pr_nrdolote => 650005
                   ,pr_des_reto => vr_des_erro
                   ,pr_dscritic => vr_dscritic);

      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        -- Finaliza Execução do Programa
        RAISE vr_exc_saida;
      END IF;

      OPEN cr_craplot(pr_cdcooper => rw_rapassecdc.cdcooper_lojista
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                     ,pr_cdagenci => 1
                     ,pr_cdbccxlt => 100
                     ,pr_nrdolote => 650005);

      FETCH cr_craplot INTO rw_craplot;

      -- Apenas Fecha Cursor
      CLOSE cr_craplot;
        
      --Inserir Lancamento
      BEGIN
        INSERT INTO craplcm
                   (cdcooper
                   ,dtmvtolt
                   ,cdagenci
                   ,cdbccxlt
                   ,nrdolote
                   ,nrdconta
                   ,nrdctabb
                   ,nrdctitg
                   ,nrdocmto
                   ,cdhistor
                   ,nrseqdig
                   ,cdpesqbb
                   ,vllanmto)
             VALUES  
                   (rw_rapassecdc.cdcooper_lojista
                   ,rw_craplot.dtmvtolt
                   ,rw_craplot.cdagenci
                   ,rw_craplot.cdbccxlt
                   ,rw_craplot.nrdolote
                   ,rw_rapassecdc.nrdconta_lojista
                   ,rw_rapassecdc.nrdconta_lojista
                   ,GENE0002.fn_mask(rw_rapassecdc.nrdconta_lojista,'99999999')
                   ,rw_rapassecdc.nrctremp
                   ,2469 -- CR.EMPRESTIMO
                   ,nvl(rw_craplot.nrseqdig,0) + 1
                   ,GENE0002.fn_mask(rw_rapassecdc.nrctremp,'99999999')
                   ,rw_rapassecdc.vlrepasse);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tabela craplcm (CDC) . ' || SQLERRM;
          --Sair do programa
          RAISE vr_exc_saida;
      END;
          
      --Atualizar capa do Lote
      BEGIN
        UPDATE craplot SET craplot.vlinfocr = nvl(craplot.vlinfocr,0) + rw_rapassecdc.vlrepasse
                          ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + rw_rapassecdc.vlrepasse
                          ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                          ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                          ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
        WHERE craplot.ROWID = rw_craplot.ROWID;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar tabela craplot(CDC). ' || SQLERRM;
          --Sair do programa
          RAISE vr_exc_saida;
      END;

      --Atualizar capa do Lote
      BEGIN
        UPDATE tbepr_cdc_emprestimo e
           SET e.flgrepasse=1
         WHERE e.rowid=rw_rapassecdc.tbemp_rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar tabela tbepr_cdc_emprestimo(CDC). ' || SQLERRM;
          --Sair do programa
          RAISE vr_exc_saida;
      END;

  END LOOP;
      
  --Atualiza o movimento
  COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
      
      -- Envia e-mail com o erro
      empr0012.pc_gera_email(pr_cdcooper        => pr_cdcooper    --> Codigo que identifica a Cooperativa.
                            ,pr_nmdatela        => vr_cdprogra    --> Nome da tela
                            ,pr_dsassunto       => 'Inconsistencia EMPR0012.Repasse CDC.' --> Descricao do Assunto
                            ,pr_dsconteudo_mail => vr_dscritic    --> Descricao do E-mail
                            ,pr_cdcritic        => vr_cdcritic    --> Codigo da critica
                            ,pr_dscritic        => vr_dscritic);  --> Descricao da critica
      
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;

      -- Envia e-mail com o erro
      empr0012.pc_gera_email(pr_cdcooper        => pr_cdcooper    --> Codigo que identifica a Cooperativa.
                            ,pr_nmdatela        => vr_cdprogra    --> Nome da tela
                            ,pr_dsassunto       => 'Inconsistencia EMPR0012.Repasse CDC.' --> Descricao do Assunto
                            ,pr_dsconteudo_mail => vr_dscritic    --> Descricao do E-mail
                            ,pr_cdcritic        => vr_cdcritic    --> Codigo da critica
                            ,pr_dscritic        => vr_dscritic);  --> Descricao da critica

      -- Efetuar rollback
      ROLLBACK;
  END pc_efetuar_repasse_cdc;
  
  --> Gera e-mail
  PROCEDURE pc_gera_email(pr_cdcooper         IN crapepr.cdcooper%type  --> Codigo que identifica a Cooperativa.
                         ,pr_nmdatela         IN VARCHAR2               --> Nome da tela
                         ,pr_dsassunto        IN VARCHAR2               --> Descricao do Assunto
                         ,pr_dsconteudo_mail  IN VARCHAR2               --> Descricao do E-mail
                         ,pr_cdcritic        OUT NUMBER          --> Codigo da critica
                         ,pr_dscritic        OUT VARCHAR2) IS    --> Descricao da critica

    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_exc_erro EXCEPTION;
 
    -- Variaveis
    vr_nmrescop           crapcop.nmrescop%TYPE;
    vr_emaildst           VARCHAR2(4000);
    vr_dsconteudo_mail    VARCHAR2(4000);
  
    -- Busca o nome
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapcop.nmrescop
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;

  BEGIN
    -- Caso algum campo foi alterado
    IF TRIM(pr_dsconteudo_mail) IS NOT NULL THEN
        
      -- Busca o nome
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO vr_nmrescop;
      CLOSE cr_crapcop;

      -- Destinatarios das alteracoes dos dados para o site
      vr_emaildst :=  GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_cdacesso => 'EMAIL_ALT_DADOS_SITE_CDC');

      -- Adiciona cooperativa e conta
      vr_dsconteudo_mail := '<b>' || vr_nmrescop ||'</b><br>' 
                           || '<br><br>' || pr_dsconteudo_mail;

      -- Faz a solicitacao do envio do email
      GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => pr_nmdatela
                                ,pr_des_destino     => vr_emaildst
                                ,pr_des_assunto     => pr_dsassunto
                                ,pr_des_corpo       => vr_dsconteudo_mail
                                ,pr_des_anexo       => NULL
                                ,pr_des_erro        => vr_dscritic);

      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF; -- TRIM(pr_dsconteudo_mail) IS NOT NULL

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
         vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela CVNCDC: ' || SQLERRM;
  END pc_gera_email;
 

  --> Rotina JOB para finalizacao de documento CDC
  PROCEDURE pc_job_efetivar_proposta_cdc(pr_cdcritic  OUT PLS_INTEGER     --> Código da crítica
                                        ,pr_dscritic  OUT VARCHAR2) IS    --> Descrição da crítica
  -- 
  -- JOB para efetivar propostas: JBEPR_CDC_EFETIVARPROPOSTA
  --
  -- Chama procedimento: 
  --       pc_job_efetivar_proposta_cdc (	pr_cdprogra => NULL,
  --                                  pr_dsjobnam => null)  
  --

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper <> 3   -- CECRED
         AND cop.flgativo = 1    -- Cooperativas Ativas
       order by cop.cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Cursor Genérico de Calendário
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    -- Exceções
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;

    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis gerais
    vr_cdprogra     crapprg.cdprogra%TYPE := 'EPPRO_CDC';

    vr_cdcooper     crapcop.cdcooper%type;
    vr_nomdojob     CONSTANT VARCHAR2(30)          := 'JBEPR_CDC_EFETIVA_PROPOSTA';
    vr_flgerlog     BOOLEAN;
    
    ------------------------- PROCEDIMENTOS INTERNOS -----------------------------   
    --> Controla log job, para apensa exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_job(pr_dstiplog IN VARCHAR2,
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
        
    END pc_controla_log_job;

  BEGIN
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => NULL);

    --> Controla log job, para apensa exibir qnd realmente processar informação
    pc_controla_log_job(pr_dstiplog => 'I');

    -- Verifica se a cooperativa esta cadastrada
    FOR rw_crapcop IN cr_crapcop LOOP

      -- Popula cdcooper
      vr_cdcooper := rw_crapcop.cdcooper;

      -- Leitura do calendário da cooperativa
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

       IF rw_crapdat.inproces != 1 -- processo bloqueado
       OR (to_char(sysdate,'D') IN (1,7)) --sabado e domingo
       OR FLXF0001.fn_verifica_feriado(rw_crapcop.cdcooper, trunc(sysdate)) THEN -- feriado
         CONTINUE;
       END IF;
  

      --> Rotina JOB para finalizacao de documento CDC
      pc_efetivar_proposta_cdc (pr_cdcooper => rw_crapcop.cdcooper     --> cooperativa
                               ,pr_nrdconta => NULL                    --> numero da conta
                               ,pr_nrctremp => NULL                    --> numero do contrato
                               ,pr_cdcritic => vr_cdcritic             --> Código da crítica
                               ,pr_dscritic => vr_dscritic);           --> Descrição da crítica

      -- Tratamento de erro de retorno
      if vr_dscritic is not null then
        raise vr_exc_saida;
      end if;

    END LOOP; --cr_crapcop

    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_job(pr_dstiplog => 'F');
      
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;

      -- Envia e-mail com o erro
      empr0012.pc_gera_email(pr_cdcooper        => vr_cdcooper    --> Codigo que identifica a Cooperativa.
                            ,pr_nmdatela        => vr_cdprogra    --> Nome da tela
                            ,pr_dsassunto       => 'Inconsistencia EMPR0012.' --> Descricao do Assunto
                            ,pr_dsconteudo_mail => vr_dscritic    --> Descricao do E-mail
                            ,pr_cdcritic        => vr_cdcritic    --> Codigo da critica
                            ,pr_dscritic        => vr_dscritic);  --> Descricao da critica
      
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      pc_controla_log_job(pr_dstiplog => 'E',
                            pr_dscritic => vr_dscritic);
                          
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- Envia e-mail com o erro
      empr0012.pc_gera_email(pr_cdcooper        => vr_cdcooper    --> Codigo que identifica a Cooperativa.
                            ,pr_nmdatela        => vr_cdprogra    --> Nome da tela
                            ,pr_dsassunto       => 'Inconsistencia EMPR0012.' --> Descricao do Assunto
                            ,pr_dsconteudo_mail => vr_dscritic    --> Descricao do E-mail
                            ,pr_cdcritic        => vr_cdcritic    --> Codigo da critica
                            ,pr_dscritic        => vr_dscritic);  --> Descricao da critica      
      
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      pc_controla_log_job(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);
                            
      -- Efetuar rollback
      ROLLBACK;
  END pc_job_efetivar_proposta_cdc;

  PROCEDURE pc_crps751 (pr_cdcooper IN crawepr.cdcooper%type
                       ,pr_nrdconta IN crawepr.nrdconta%type
                       ,pr_nrctremp IN crawepr.nrctremp%type
                       ,pr_cdagenci IN crawepr.cdagenci%type
                       ,pr_cdoperad IN crawepr.cdoperad%type
                       ,pr_dtmvtolt IN crawepr.dtmvtolt%type
                       ,pr_dtmvtopr IN crapdat.dtmvtopr%type
                       ,pr_cdcritic OUT crapcri.cdcritic%type
                       ,pr_dscritic OUT crapcri.dscritic%type) IS

    -- Execucao shell
    vr_lsdparam     VARCHAR2(4000);
    vr_dsscript     VARCHAR2(4000);
    vr_dscomand     VARCHAR2(2000);
    vr_typ_saida    VARCHAR2(4000); 
    --> Nome do arquivo de log temporario
    vr_nmlogtmp VARCHAR2(500) := 'CRPS751_'||to_char(SYSDATE,'RRRRMM')|| '.log';
    vr_nmdireto VARCHAR2(500);

    -- Exceções
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;

    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

  BEGIN

    -- parametros para execucao do shell
    vr_dsscript := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_cdacesso => 'SHELL_CRPS751');

    -- Define o diretório do arquivo
    vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/log') ;

    ----------------->> CHAMADA ROTINA PROGRESS <<----------------
    vr_lsdparam :=  pr_cdcooper ||';'|| --> 'par_cdcooper'
                    pr_cdagenci ||';'|| --> 'par_cdagenci'
                    '1' ||';'|| --> 'par_nrdcaixa' [ARRUMAR]
                    pr_cdoperad ||';'|| --> 'par_cdoperad'
                    'AUTOCDC' ||';'|| --> 'par_nmdatela' [ARRUMAR]
                    '7' ||';'|| --> 'par_idorigem' [ARRUMAR]
                    to_char(pr_dtmvtolt, 'DD/MM/RRRR') ||';'|| --> 'par_dtmvtolt'
                    to_char(pr_dtmvtopr, 'DD/MM/RRRR') ||';'|| --> 'par_dtmvtopr'
                    pr_nrdconta ||';'|| --> 'par_nrdconta'
                    '1' ||';'|| --> 'par_idseqttl' [ARRUMAR]
                    pr_nrctremp ||';'|| --> 'par_nrctremp'
                    vr_nmdireto || '/' || vr_nmlogtmp; --> 'par_nmarqlog'

    vr_dscomand := vr_dsscript || ' "'||vr_lsdparam||'"';

    -- Efetuar a execução do comando ls, para verificar se existe diretorio
    gene0001.pc_OScommand(pr_typ_comando  => 'SR'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);

  ----------------->> FIM CHAMADA ROTINA PROGRESS <<----------------  
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;

      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;     
      -- Efetuar rollback
      ROLLBACK;
  
  END pc_crps751;  

  --> Rotina JOB para finalizacao de documento CDC
  PROCEDURE pc_efetivar_proposta_cdc(pr_cdcooper  in crawepr.cdcooper%type  --> cooperativa
                                    ,pr_nrdconta  in crawepr.nrdconta%type  --> numero da conta
                                    ,pr_nrctremp  in crawepr.nrctremp%type  --> numero do contrato
                                    ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2) IS          --> Descrição da crítica

    -- Cursor Genérico de Calendário
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    -- Busca Emprestimos
    CURSOR cr_rapassecdc (pr_cdcooper  IN crawepr.cdcooper%TYPE     --> cooperativa
                         ,pr_nrdconta  IN crawepr.nrdconta%type     --> numero da conta
                         ,pr_nrctremp  IN crawepr.nrctremp%type     --> numero do contrato
                         ,pr_dtinicial IN crapdat.dtmvtolt%TYPE     --> Data inicial
                         ,pr_dtfinal   IN crapdat.dtmvtolt%TYPE) IS --> Data final
      select tce.vlrepasse
            ,epr.*
        from crawepr    epr
            ,crapfin    fin 
            ,tbepr_cdc_emprestimo tce 
       where epr.cdcooper=coalesce(pr_cdcooper, epr.cdcooper)
         and epr.nrdconta=coalesce(pr_nrdconta, epr.nrdconta)
         and epr.nrctremp=coalesce(pr_nrctremp, epr.nrctremp)
         and epr.dtmvtolt between pr_dtinicial and pr_dtfinal
         and epr.flgdocdg=1
         and (fin.cdcooper=epr.cdcooper and fin.cdfinemp=epr.cdfinemp and fin.flgstfin = 1 and fin.tpfinali=3) -- crapfin
         and (tce.cdcooper=epr.cdcooper and tce.nrdconta=epr.nrdconta and tce.nrctremp=epr.nrctremp) -- tbepr_cdc_emprestimo
         and not exists (select 1 
                           from crapepr eprx 
                          where eprx.cdcooper=epr.cdcooper 
                            and eprx.nrdconta=epr.nrdconta 
                            and eprx.nrctremp=epr.nrctremp);

    -- Exceções
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;

    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis gerais
    vr_cdprogra     crapprg.cdprogra%TYPE := 'EPPRO_CDC';
    vr_data_inicial crapdat.dtmvtolt%type;
    vr_prazo_efetiva NUMBER;
    vr_flaliena      INTEGER;
    vr_insitapr       NUMBER(1) := 5; -- situacao de pagamento efetuado
    vr_insitpgn       NUMBER(2) := 25; -- situacao pagamento negado

    vr_nmsistem VARCHAR2(4)  := 'CRED';
    vr_cdacesso VARCHAR2(20) := 'PRAZO_EFETIVA_CDC';
    vr_cdoperad VARCHAR2(10) := 'AUTOCDC';
    vr_dsorigem VARCHAR2(10) := 'EFT_CDC';

    vr_flgtrans NUMBER(1)    := 1; -- TRUE
    vr_idseqttl NUMBER(1)    := 1;
    vr_flgerlog NUMBER(1)    := 0;
    vr_nmdatela VARCHAR2(10) := 'AUTOCDC';

    vr_dstipo_doc   VARCHAR2(10) := 'EFETIVAR';
    vr_dsreprovacao VARCHAR2(1)  := 2;
    vr_dsobservacao VARCHAR2(25) := 'Contrato não efetivado';

    vr_tab_ratings  rati0001.typ_tab_ratings;
    vr_mensagem     VARCHAR2(4000);
    vr_habrat       VARCHAR2(1) := 'N';    -- P450 - Paramentro para Habilitar Novo Ratin (S/N)
    vr_strating     NUMBER;                -- P450
    vr_flgrating    NUMBER;                -- P450
    vr_vlendivid    craplim.vllimite%TYPE; -- P450 - Valor do Endividamento do Cooperado
    vr_vllimrating  craplim.vllimite%TYPE; -- P450 - Valor do Parametro Rating (Limite) TAB056
    -- P450 - Verifica Conta (Cadastro de associados)
    cursor cr_crapass (pr_cdcooper  IN crawepr.cdcooper%TYPE     --> cooperativa
                      ,pr_nrdconta  IN crawepr.nrdconta%TYPE) IS --> numero da conta
      select dtelimin
            ,cdsitdtl
            ,cdagenci
            ,inpessoa
            ,nrdconta
            ,nrcpfcnpj_base
       from  crapass
       where crapass.cdcooper = pr_cdcooper
         and crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;
    
    vr_rowid        ROWID;

  BEGIN
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => NULL);

    -- Leitura do calendário da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    vr_prazo_efetiva := gene0001.fn_param_sistema(pr_nmsistem => vr_nmsistem
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_cdacesso => vr_cdacesso);

    vr_data_inicial := rw_crapdat.dtmvtolt-vr_prazo_efetiva;

    --Ler Emprestimos
    FOR rw_rapassecdc IN cr_rapassecdc(pr_cdcooper => pr_cdcooper                 --> Codigo da cooperativa
                                      ,pr_nrdconta => pr_nrdconta                 --> Todas as contas
                                      ,pr_nrctremp => pr_nrctremp                 --> Todos os emprestivos
                                      ,pr_dtinicial => vr_data_inicial            --> Data inicial
                                      ,pr_dtfinal   => rw_crapdat.dtmvtolt) LOOP  --> Data final

      IF rw_crapdat.inproces != 1 -- processo bloqueado
      OR (to_char(sysdate,'D') IN (1,7)) --sabado e domingo
      OR FLXF0001.fn_verifica_feriado(rw_rapassecdc.cdcooper, trunc(sysdate)) THEN -- feriado
        CONTINUE;
      END IF;

      --> Validar gravames para Finalidade 59 - Veiculo e tipo finalidade 3 - CDC 
      pc_gravames_proposta_cdc (pr_cdcooper => rw_rapassecdc.cdcooper      -- Cód. cooperativa
                               ,pr_nrdconta => rw_rapassecdc.nrdconta      -- Nr. da conta
                               ,pr_nrctremp => rw_rapassecdc.nrctremp      -- Nr. contrato
                               ,pr_flaliena => vr_flaliena       -- Retorna se bem já esta alienado
                               ,pr_cdcritic => vr_cdcritic       -- Codigo de critica de sistema
                               ,pr_dscritic => vr_dscritic);     -- Descrição da critica de sistema

        -- Tratamento de erro de retorno
      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) is not null THEN 
        --raise vr_exc_saida;
        -- Gera Log
        GENE0001.pc_gera_log(pr_cdcooper => rw_rapassecdc.cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => 'Gravames proposta CDC.'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => vr_flgtrans -- TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => vr_idseqttl
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => rw_rapassecdc.nrdconta
                            ,pr_nrdrowid => vr_rowid
                            ); 
        continue;
      end if;

      IF rw_rapassecdc.cdfinemp = 58 or (rw_rapassecdc.cdfinemp = 59 and vr_flaliena = 1) THEN

          -- Chamar para atualizar a data
          IF rw_crapdat.dtmvtolt > rw_rapassecdc.dtlibera THEN

            -- ajustar a data do emprestimo para efetivar
            pc_crps751 (pr_cdcooper => rw_rapassecdc.cdcooper
                       ,pr_nrdconta => rw_rapassecdc.nrdconta
                       ,pr_nrctremp => rw_rapassecdc.nrctremp
                       ,pr_cdagenci => rw_rapassecdc.cdagenci
                       ,pr_cdoperad => rw_rapassecdc.cdoperad
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);

            -- Tratamento de erro de retorno
            if coalesce(vr_dscritic,'OK') != 'OK'  then
              --raise vr_exc_saida;
              -- Gera Log
              GENE0001.pc_gera_log(pr_cdcooper => rw_rapassecdc.cdcooper
                                  ,pr_cdoperad => vr_cdoperad
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_dsorigem => vr_dsorigem
                                  ,pr_dstransa => 'Recalculo de emprestimo.'
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => vr_flgtrans
                                  ,pr_hrtransa => GENE0002.fn_busca_time
                                  ,pr_idseqttl => vr_idseqttl
                                  ,pr_nmdatela => vr_nmdatela
                                  ,pr_nrdconta => rw_rapassecdc.nrdconta
                                  ,pr_nrdrowid => vr_rowid
                                  ); 
              continue;
            end if;
          END IF;  

          -- Efetivar a proposta
          empr0014.pc_grava_efetivacao_proposta (pr_cdcooper => rw_rapassecdc.cdcooper    --> Codigo Cooperativa
                                                ,pr_cdagenci => rw_rapassecdc.cdagenci    --> Codigo Agencia
                                                ,pr_nrdcaixa => null                      --> Numero do Caixa
                                                ,pr_cdoperad => rw_rapassecdc.CDOPERAD    --> Codigo Operador
                                                ,pr_nmdatela => vr_cdprogra               --> Nome da Tela
                                                ,pr_idorigem => rw_rapassecdc.cdorigem    --> Origem dos Dados
                                                ,pr_nrdconta => rw_rapassecdc.nrdconta    --> Numero da Conta do Associado
                                                ,pr_idseqttl => vr_idseqttl               --> Sequencial do Titular
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt       --> Data Movimento
                                                ,pr_flgerlog => vr_flgerlog               --> Imprimir log 0=FALSE 1=TRUE
                                                ,pr_nrctremp => rw_rapassecdc.nrctremp    --> Numero Contrato Emprestimo
                                                ,pr_dtdpagto => rw_rapassecdc.dtdpagto    --> Data pagamento
                                                ,pr_dtmvtopr => rw_crapdat.dtmvtopr       --> Data
                                                ,pr_inproces => rw_crapdat.inproces       --> Indicador do processo
                                                ,pr_nrcpfope => null                      --> CPF do operador
                                                --->> SAIDA
                                                ,pr_tab_ratings => vr_tab_ratings         --> retorna dados do rating
                                                ,pr_mensagem    => vr_mensagem            --> Retorna mensagem                                           
                                                ,pr_cdcritic => vr_cdcritic               --> Código da crítica
                                                ,pr_dscritic => vr_dscritic);             --> Descrição da crítica

        -- Tratamento de erro de retorno
        if coalesce(vr_dscritic,'OK') != 'OK'  then
          
          -- Gera Log
          GENE0001.pc_gera_log(pr_cdcooper => rw_rapassecdc.cdcooper
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => 'Efetivacao proposta CDC.'
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => vr_flgtrans
                              ,pr_hrtransa => GENE0002.fn_busca_time
                              ,pr_idseqttl => vr_idseqttl
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nrdconta => rw_rapassecdc.nrdconta
                              ,pr_nrdrowid => vr_rowid); 
          
          pc_grava_pedencia_emprestimo (pr_cdcooper => rw_rapassecdc.cdcooper
                                       ,pr_nrdconta => rw_rapassecdc.nrdconta
                                       ,pr_nrctremp => rw_rapassecdc.nrctremp
                                       ,pr_dstipo_doc   => vr_dstipo_doc
                                       ,pr_dsreprovacao => vr_dsreprovacao
                                       ,pr_dsobservacao => vr_dsobservacao
                                       ,pr_cdcritic => vr_cdcritic 
                                       ,pr_dscritic => vr_dscritic);

          pc_reinicia_fluxo_efetivacao (pr_cdcooper => rw_rapassecdc.cdcooper
                                       ,pr_nrdconta => rw_rapassecdc.nrdconta
                                       ,pr_nrctremp => rw_rapassecdc.nrctremp
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

          pc_retorna_situacao_ibracred (pr_cdcooper  => rw_rapassecdc.cdcooper      --> Coodigo Cooperativa
                                       ,pr_nrdconta  => rw_rapassecdc.nrdconta      --> Numero da Conta do Associado
                                       ,pr_nrctremp  => rw_rapassecdc.nrctremp      --> Numero do contrato
                                       ,pr_cdoperad  => vr_cdoperad      --> Codigo do operador
                                       ,pr_cdsitprp  => vr_insitpgn      --> Situação da proposta na IBRACRED
                                       ,pr_cdcritic  => vr_cdcritic      --> Código da crítica
                                       ,pr_dscritic  => vr_dscritic);   --> Descrição da crítica

          continue;
        end if;

        -- Após a efetivação com sucesso da proposta, deve ocorrer o repasse dos valores para o logista, 
        pc_efetuar_repasse_cdc (pr_cdcooper => rw_rapassecdc.cdcooper  --> cooperativa
                               ,pr_nrdconta => rw_rapassecdc.nrdconta  --> numero da conta
                               ,pr_nrctremp => rw_rapassecdc.nrctremp  --> numero do contrato
                               ,pr_cdcritic => vr_cdcritic             --> Código da crítica
                               ,pr_dscritic => vr_dscritic);           --> Descrição da crítica

        -- Tratamento de erro de retorno
        if vr_dscritic is not null then
          --raise vr_exc_saida;
          -- Gera Log
          GENE0001.pc_gera_log(pr_cdcooper => rw_rapassecdc.cdcooper
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => 'Efetuar repasse CDC.'
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => vr_flgtrans
                              ,pr_hrtransa => GENE0002.fn_busca_time
                              ,pr_idseqttl => vr_idseqttl
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nrdconta => rw_rapassecdc.nrdconta
                              ,pr_nrdrowid => vr_rowid
                              ); 
          continue;
        end if;

        -- P450 SPT13 - alteracao para habilitar rating novo
        vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                               pr_cdcooper => rw_rapassecdc.cdcooper,
                                               pr_cdacesso => 'HABILITA_RATING_NOVO');


        IF (rw_rapassecdc.cdcooper <> 3 OR vr_habrat = 'S') THEN
          
          --    Retorda dados da conta
          open  cr_crapass(pr_cdcooper => rw_rapassecdc.cdcooper    --> Codigo da cooperativa
                          ,pr_nrdconta => rw_rapassecdc.nrdconta);  --> Todas as contas
          fetch cr_crapass into rw_crapass;
          if    cr_crapass%notfound then
                close cr_crapass;
                vr_cdcritic := 9;
                raise vr_exc_saida;
          end   if;
          close cr_crapass;
          
          /* Validar Status rating */
          RATI0003.pc_busca_status_rating(pr_cdcooper  => rw_rapassecdc.cdcooper
                                         ,pr_nrdconta  => rw_rapassecdc.nrdconta
                                         ,pr_nrctrato  => rw_rapassecdc.nrctremp
                                         ,pr_tpctrato  => 90
                                         ,pr_strating  => vr_strating
                                         ,pr_flgrating => vr_flgrating
                                         ,pr_cdcritic  => vr_cdcritic
                                         ,pr_dscritic  => vr_dscritic);

          IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;
          -- Buscar Valor Endividamento e Valor Limite Rating (TAB056)
          RATI0003.pc_busca_endivid_param(pr_cdcooper => rw_rapassecdc.cdcooper
                                         ,pr_nrdconta => rw_rapassecdc.nrdconta
                                         ,pr_vlendivi => vr_vlendivid
                                         ,pr_vlrating => vr_vllimrating
                                         ,pr_dscritic => vr_dscritic);
          IF TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;

          -- Status do rating inválido
          IF vr_flgrating = 0 THEN
            vr_dscritic := 'Contrato não pode ser efetivado porque não há Rating válido.';
            RAISE vr_exc_saida;

          ELSE -- Status do rating válido

            -- Se Endividamento + Contrato atual > Parametro Rating (TAB056
            IF (vr_vlendivid  > vr_vllimrating) THEN

              -- Gravar o Rating da operação, efetivando-o
              rati0003.pc_grava_rating_operacao(pr_cdcooper          => rw_rapassecdc.cdcooper
                                               ,pr_nrdconta          => rw_rapassecdc.nrdconta
                                               ,pr_nrctrato          => rw_rapassecdc.nrctremp
                                               ,pr_tpctrato          => 90
                                               ,pr_dtrating          => rw_crapdat.dtmvtolt
                                               ,pr_strating          => 4
                                               ,pr_cdoprrat          => vr_cdoperad
                                               ,pr_nrcpfcnpj_base    => rw_crapass.nrcpfcnpj_base
                                               --Variáveis para gravar o histórico
                                               ,pr_cdoperad          => vr_cdoperad
                                               ,pr_dtmvtolt          => rw_crapdat.dtmvtolt
                                               ,pr_valor             => NULL
                                               ,pr_rating_sugerido   => NULL
                                               ,pr_justificativa     => NULL
                                               ,pr_tpoperacao_rating => NULL
                                               --Variáveis de crítica
                                               ,pr_cdcritic          => vr_cdcritic
                                               ,pr_dscritic          => vr_dscritic);

              IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;
            END IF;
          END IF;
        END IF;
        -- P450 SPT13 - alteracao para habilitar rating novo

        -- atualiar ibratan quanto a efetivacao da proposta
        este0001.pc_efetivar_proposta_est (pr_cdcooper => rw_rapassecdc.cdcooper --> Codigo da cooperativa
                                          ,pr_cdagenci => rw_rapassecdc.cdagenci --> Codigo da agencia                                          
                                          ,pr_cdoperad => rw_rapassecdc.cdoperad --> codigo do operador
                                          ,pr_cdorigem => rw_rapassecdc.cdorigem --> Origem da operacao
                                          ,pr_nrdconta => rw_rapassecdc.nrdconta --> Numero da conta do cooperado
                                          ,pr_nrctremp => rw_rapassecdc.nrctremp --> Numero da proposta de emprestimo atual/antigo                                      
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do movimento                                      
                                          ,pr_nmarquiv => NULL --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                          ---- OUT ----                           
                                          ,pr_cdcritic => vr_cdcritic  --> Codigo da critica
                                          ,pr_dscritic => vr_dscritic); --> Descricao da critica

         -- Tratamento de erro de retorno
        if vr_dscritic is not null then
          --raise vr_exc_saida;
          -- Gera Log
          GENE0001.pc_gera_log(pr_cdcooper => rw_rapassecdc.cdcooper
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => 'Efetuar repasse CDC.'
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => vr_flgtrans
                              ,pr_hrtransa => GENE0002.fn_busca_time
                              ,pr_idseqttl => vr_idseqttl
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nrdconta => rw_rapassecdc.nrdconta
                              ,pr_nrdrowid => vr_rowid
                              ); 
          continue;
        end if;

      END IF; -- efetivacao_proposta

      --Atualiza o movimento
      COMMIT;

    END LOOP; --cr_rapassecdc 

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;

      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;     
      -- Efetuar rollback
      ROLLBACK;
  END pc_efetivar_proposta_cdc;

  
  --> Manter Conficuracao Push
  PROCEDURE pc_manter_config_push(pr_idusuario         IN tbepr_cdc_usuario_notifica.idusuario%type         --Identificacao do usuario
                                 ,pr_flgnotifica       IN tbepr_cdc_usuario_notifica.flgnotifica%type       -- Flag de notificacao principal (0-Inativa, 1-Ativa) para todas as notificacao
                                 ,pr_flgprop_aprovada  IN tbepr_cdc_usuario_notifica.flgprop_aprovada%type  -- Flag de aprovacao da proposta (0-Inativa, 1-Ativa)
                                 ,pr_flgprop_negagada  IN tbepr_cdc_usuario_notifica.flgprop_negagada%type  --Flag de negacao da proposta (0-Inativa, 1-Ativa)
                                 ,pr_flgprop_cancelada IN tbepr_cdc_usuario_notifica.flgprop_cancelada%type --Flag de cancelamento da proposta (0-Inativa, 1-Ativa)
                                 ,pr_flgpgto_efetuado  IN tbepr_cdc_usuario_notifica.flgpgto_efetuado%type  --Flag de pagamento efetuado (0-Inativa, 1-Ativa)
                                 ,pr_flgpgto_analise   IN tbepr_cdc_usuario_notifica.flgpgto_analise%type   --Flag de pagamento em analise (0-Inativa, 1-Ativa)
                                 ,pr_flgpgto_negado    IN tbepr_cdc_usuario_notifica.flgpgto_negado%type    --Flag de pagamento negado (0-Inativa, 1-Ativa)
                                 ,pr_flgpgto_pendente  IN tbepr_cdc_usuario_notifica.flgpgto_pendente%type  --Flag pendente (0-Inativa, 1-Ativa)
                                 ,pr_dscritic          OUT VARCHAR2)IS                                   
    
    -- Tratamento de erros   
    vr_exc_erro EXCEPTION;
    vr_exc_saida EXCEPTION;
    vr_dscritic crapcri.dscritic%TYPE;

  BEGIN
    -- Insere a tabela principal de push
    if nvl(pr_idusuario,0) = 0 then
      vr_dscritic := 'Usuário não informado';
      RAISE vr_exc_saida;
    end if;
    
    BEGIN
      -- verifica se pr_idusuario é informado      
      insert into tbepr_cdc_usuario_notifica
                  (idusuario
                  ,flgnotifica
                  ,flgprop_aprovada
                  ,flgprop_negagada
                  ,flgprop_cancelada
                  ,flgpgto_efetuado
                  ,flgpgto_analise
                  ,flgpgto_negado
                  ,flgpgto_pendente)
           Values
                  (pr_idusuario        
                  ,pr_flgnotifica      
                  ,pr_flgprop_aprovada 
                  ,pr_flgprop_negagada 
                  ,pr_flgprop_cancelada
                  ,pr_flgpgto_efetuado 
                  ,pr_flgpgto_analise  
                  ,pr_flgpgto_negado   
                  ,pr_flgpgto_pendente );
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Atualiza o registro
        BEGIN
          update tbepr_cdc_usuario_notifica
             set flgnotifica       = pr_flgnotifica      
                ,flgprop_aprovada  = pr_flgprop_aprovada 
                ,flgprop_negagada  = pr_flgprop_negagada 
                ,flgprop_cancelada = pr_flgprop_cancelada
                ,flgpgto_efetuado  = pr_flgpgto_efetuado 
                ,flgpgto_analise   = pr_flgpgto_analise  
                ,flgpgto_negado    = pr_flgpgto_negado   
                ,flgpgto_pendente  = pr_flgpgto_pendente
           WHERE idusuario  =  pr_idusuario;    
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tbepr_cdc_usuario_notifica: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir tbepr_cdc_usuario_notifica: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

  EXCEPTION
    WHEN vr_exc_saida THEN          
      pr_dscritic := vr_dscritic;    
    WHEN vr_exc_erro THEN          
      pr_dscritic := vr_dscritic;    
    WHEN OTHERS THEN
      pr_dscritic := vr_dscritic;    
  END pc_manter_config_push;    

  --> Rotina para listar do configurações de push
  PROCEDURE pc_consulta_config_push(pr_idusuario IN tbepr_cdc_usuario_notifica.idusuario%type        --> Identificacao do usuario
                                   ,pr_idcooperado_cdc  IN tbepr_cdc_usuario_vinculo.idcooperado_cdc%type --> Identificacao do lojista
                                   ,pr_retorno          OUT xmltype                                --> XML de retorno
                                   ,pr_dscritic         OUT VARCHAR2)IS             
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    vr_contador      NUMBER := 0;

    -- Cursor para buscar as configurações de push
    CURSOR cr_configuracoes IS
      select tcun.idusuario
 	          ,tcun.flgnotifica
            ,tcun.flgprop_aprovada
            ,tcun.flgprop_negagada
            ,tcun.flgprop_cancelada
            ,tcun.flgpgto_efetuado
            ,tcun.flgpgto_analise
            ,tcun.flgpgto_negado
            ,tcun.flgpgto_pendente
        from tbepr_cdc_usuario_notifica tcun
        join tbepr_cdc_usuario tcu on (tcu.idusuario=tcun.idusuario)
        join tbepr_cdc_usuario_vinculo tcuv on (tcuv.idusuario=tcu.idusuario and tcuv.idcooperado_cdc=coalesce(pr_idcooperado_cdc, tcuv.idcooperado_cdc))
       where tcun.idusuario=coalesce(pr_idusuario, tcun.idusuario);

  BEGIN
    
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Configuracoes/>');

    -- Loop sobre a tabela de push
    FOR rw_configuracoes IN cr_configuracoes LOOP

      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Configuracoes'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Push'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);

      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Push'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idusuario'
                            ,pr_tag_cont => rw_configuracoes.idusuario
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Push'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'flgnotifica'
                            ,pr_tag_cont => rw_configuracoes.flgnotifica
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Push'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'flgprop_aprovada'
                            ,pr_tag_cont => rw_configuracoes.flgprop_aprovada
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Push'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'flgprop_negagada'
                            ,pr_tag_cont => rw_configuracoes.flgprop_negagada
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Push'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'flgprop_cancelada'
                            ,pr_tag_cont => rw_configuracoes.flgprop_cancelada
                            ,pr_des_erro => pr_dscritic);                                                                                                                
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Push'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'flgpgto_efetuado'
                            ,pr_tag_cont => rw_configuracoes.flgpgto_efetuado
                            ,pr_des_erro => pr_dscritic);    
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Push'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'flgpgto_analise'
                            ,pr_tag_cont => rw_configuracoes.flgpgto_analise
                            ,pr_des_erro => pr_dscritic);    
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Push'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'flgpgto_negado'
                            ,pr_tag_cont => rw_configuracoes.flgpgto_negado
                            ,pr_des_erro => pr_dscritic);    
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Push'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'flgpgto_pendente'
                            ,pr_tag_cont => rw_configuracoes.flgpgto_pendente
                            ,pr_des_erro => pr_dscritic);                                                                                        
                            
      vr_contador := vr_contador + 1; 
    END LOOP;

    -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Configurações Não Cadastradas';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    pr_retorno := vr_xml;

  EXCEPTION
   WHEN vr_exc_erro THEN   
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
   WHEN OTHERS THEN
     -- Montar descrição de erro não tratado
     pr_dscritic := 'Erro não tratado na pc_consulta_config_push: ' ||SQLERRM;
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_consulta_config_push;

  --> Consulta propostas pendentes 
  PROCEDURE pc_consulta_pend_proposta(pr_cdcooper in tbepr_cdc_empr_doc.cdcooper%type --> cooperativa
                                     ,pr_ndrconta in tbepr_cdc_empr_doc.nrdconta%type --> conta
                                     ,pr_nrctremp in tbepr_cdc_empr_doc.nrctremp%type --> contrato de emprestimo
                                     ,pr_retorno          OUT xmltype                 --> XML de retorno
                                     ,pr_dscritic         OUT VARCHAR2)IS             --> Retorno de Erro                                                                    

    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    vr_contador      NUMBER := 0;

    -- Cursor para buscar as pendencias
    CURSOR cr_pendencia IS
      select tpen.idempr_doc
            ,tpen.dstipo_doc
            ,decode(tpen.dsreprovacao,2,'Nao aprovado','Aprovado') dsreprovacao
            ,tpen.dsobservacao
            ,tpen.dtinsori
        from tbepr_cdc_empr_doc tpen
       where tpen.cdcooper = pr_cdcooper
         and tpen.nrdconta = pr_ndrconta
         and tpen.nrctremp = pr_nrctremp
         and tpen.dsreprovacao=2; -- somente nao aprovado

  BEGIN
    
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Pendencias/>');

    -- Loop sobre a tabela de pendencias
    FOR rw_pendencias IN cr_pendencia LOOP

      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Pendencias'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Pendencia'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);

      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Pendencia'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'idempr_doc'
                            ,pr_tag_cont => rw_pendencias.idempr_doc
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Pendencia'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dstipo_doc'
                            ,pr_tag_cont => rw_pendencias.dstipo_doc
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Pendencia'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dsreprovacao'
                            ,pr_tag_cont => rw_pendencias.dsreprovacao
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Pendencia'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dsobservacao'
                            ,pr_tag_cont => rw_pendencias.dsobservacao
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Pendencia'
                            ,pr_posicao  => vr_contador
                            ,pr_tag_nova => 'dtinsori'
                            ,pr_tag_cont => to_char(rw_pendencias.dtinsori,'DD/MM/RRRR HH24:MI:SS')
                            ,pr_des_erro => pr_dscritic);                                                                                                                
                            
      vr_contador := vr_contador + 1; 
    END LOOP;

    -- Se não encontrou nenhum registro
    IF vr_contador = 0 THEN
      -- Gerar crítica
      pr_dscritic    := 'Pendencias Não Cadastradas';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    pr_retorno := vr_xml;

  EXCEPTION
   WHEN vr_exc_erro THEN   
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
   WHEN OTHERS THEN
     -- Montar descrição de erro não tratado
     pr_dscritic := 'Erro não tratado na pc_consulta_config_push: ' ||SQLERRM;
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
  END pc_consulta_pend_proposta;

  PROCEDURE  pc_gravames_proposta_cdc (pr_cdcooper IN crapbpr.cdcooper%TYPE       -- Cód. cooperativa
                                      ,pr_nrdconta IN crapbpr.nrdconta%TYPE       -- Nr. da conta
                                      ,pr_nrctremp IN crapbpr.nrctrpro%TYPE       -- Nr. contrato                                        
                                      ,pr_flaliena OUT INTEGER                    -- Retorna se bem já esta alienado
                                      ,pr_cdcritic OUT INTEGER                    -- Codigo de critica de sistema
                                      ,pr_dscritic OUT VARCHAR2) IS               -- Descrição da critica de sistema

   /* ..........................................................................
    
      Programa :  pc_gravames_proposta_cdc

      Sistema  : CRED
      Sigla    : GRVM
      Autor    : Odirlei Busana - AMcom
      Data     : Julhi/2018.                   Ultima atualizacao: 24/10/2018
    
      Dados referentes ao programa:
    
       Objetivo  : Rotina para verificar situação do gravames da proposta CDC
    
       Alteracoes: 19/10/2018 - P442 - Troca de checagem fixa por funcão para garantir se bem é alienável (Marcos-Envolti)
    ............................................................................. */
       
    
    
    -->> CURSORES
    -- Busca Emprestimos
    CURSOR cr_crawepr (pr_cdcooper  IN crawepr.cdcooper%TYPE     --> cooperativa
                      ,pr_nrdconta  IN crawepr.nrdconta%type     --> numero da conta
                      ,pr_nrctremp  IN crawepr.nrctremp%type) IS --> numero do contrato

      SELECT epr.cdfinemp
            ,fin.tpfinali
            ,epr.cdoperad
            ,epr.rowid
            ,tve.nrcpf
        from crawepr    epr
            ,crapfin    fin 
            ,tbepr_cdc_emprestimo tce 
            ,tbepr_cdc_vendedor   tve
       where epr.cdcooper = pr_cdcooper
         and epr.nrdconta = pr_nrdconta
         and epr.nrctremp = pr_nrctremp
         and fin.cdcooper = epr.cdcooper 
         and fin.cdfinemp = epr.cdfinemp 
         and fin.flgstfin = 1
         and tce.cdcooper = epr.cdcooper 
         and tce.nrdconta = epr.nrdconta 
         and tce.nrctremp = epr.nrctremp
         AND tce.idvendedor = tve.idvendedor;
    rw_crawepr cr_crawepr%ROWTYPE;

    -- Busca gravames
    CURSOR cr_crapbpr (pr_cdcooper  IN crapbpr.cdcooper%TYPE     --> cooperativa
                      ,pr_nrdconta  IN crapbpr.nrdconta%type     --> numero da conta
                      ,pr_nrctrpro  IN crapbpr.nrctrpro%type) IS --> numero do contrato
      SELECT bpr.rowid
            ,bpr.idseqbem
        FROM crapbpr bpr
       WHERE bpr.cdcooper = pr_cdcooper
         AND bpr.nrdconta = pr_nrdconta
         AND bpr.nrctrpro = pr_nrctrpro
         AND bpr.tpctrpro = 90
         AND bpr.flgalien = 1 --Bem alienado a proposta
         AND grvm0001.fn_valida_categoria_alienavel(bpr.dscatbem) = 'S';

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_cdsitgrv INTEGER;
    vr_dscrigrv VARCHAR2(300); 
    
    vr_stprogra INTEGER;
    vr_infimsol INTEGER;

    -- XML para Alienação
    vr_dsxmlali XMLType;
    -- ID Evento SOA
    vr_idevento   tbgen_evento_soa.idevento%type;    

    -- Tratamento de erros
    vr_exc_erro  EXCEPTION; 

  BEGIN
  
    pr_flaliena := 0; --> Inicia como nao alienado
    
    -- Busca Emprestimos
    OPEN cr_crawepr (pr_cdcooper  => pr_cdcooper     --> cooperativa
                    ,pr_nrdconta  => pr_nrdconta     --> numero da conta
                    ,pr_nrctremp  => pr_nrctremp);  --> numero do contrato
    FETCH cr_crawepr INTO rw_crawepr; 
    CLOSE cr_crawepr;

    --Apenas validar para finalidade CDC Veiculo
    IF rw_crawepr.tpfinali = 3 AND  rw_crawepr.cdfinemp = 59 THEN

      --> Listar bens alienados 
      FOR rw_crapbpr IN cr_crapbpr (pr_cdcooper  => pr_cdcooper        
                                   ,pr_nrdconta  => pr_nrdconta        
                                   ,pr_nrctrpro  => pr_nrctremp ) LOOP 

        -- Validar a situação do Gravames
        vr_cdsitgrv := NULL;
        vr_dscrigrv := NULL;
        GRVM0001.pc_valida_situacao_gravames (pr_cdcooper => pr_cdcooper           -- Cód. cooperativa
                                             ,pr_nrdconta => pr_nrdconta           -- Nr. da conta
                                             ,pr_nrctrpro => pr_nrctremp           -- Nr. contrato
                                             ,pr_idseqbem => rw_crapbpr.idseqbem   -- Sequencial do bem
                                             --> OUT <--
                                             ,pr_cdsitgrv => vr_cdsitgrv           -- Situacao do Gravames(0=Nao Env/1=Em Proc/2=Alienado/3=Proces).
                                             ,pr_dscrigrv => vr_dscrigrv           -- Retorna critica de processamento do gravames
                                             ,pr_cdcritic => vr_cdcritic           -- Codigo de critica de sistema
                                             ,pr_dscritic => vr_dscritic);         -- Descrição da critica de sistema

        -- Tratamento de erro de retorno
        IF nvl(vr_cdcritic,0) > 0 THEN
          raise vr_exc_erro;
        END IF;

        -- (0- Nao solicitado o gravamos)nao registrado gravames
        IF vr_cdsitgrv = 0 THEN
          -- Caso gravames Online
          IF grvm0001.fn_tem_gravame_online(pr_cdcooper) = 'S' THEN
            -- Gravames Online - Buscar o XML para alienação
            GRVM0001.pc_busca_xml_gravame_CDC(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_nrctrpro => pr_nrctremp
                                             ,pr_nrcpfven => rw_crawepr.nrcpf
                                             ,pr_cdoperad => rw_crawepr.cdoperad
                                             ,pr_dsxmlali => vr_dsxmlali
                                             ,pr_dscritic => vr_dscritic);
            -- Tratar saida com erro
            IF vr_dscritic IS NOT NULL THEN
              raise vr_exc_erro;
            END IF;            
            -- Gravar evento SOA
            soap0003.pc_gerar_evento_soa(pr_cdcooper               => pr_cdcooper
                                        ,pr_nrdconta               => pr_nrdconta
                                        ,pr_nrctrprp               => pr_nrctremp
                                        ,pr_tpevento               => 'REGISTRO_GRAVAME'
                                        ,pr_tproduto_evento        => 'CDC'
                                        ,pr_tpoperacao             => 'INSERT'
                                        ,pr_dsconteudo_requisicao  => vr_dsxmlali.getClobVal()
                                        ,pr_idevento               => vr_idevento
                                        ,pr_dscritic               => vr_dscritic);
            -- Tratar saida com erro                          
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
          END IF;
          ELSE
            -- Gravames apenas por arquivo, então criamos a pendência e será aguardando o envio manual
            GRVM0001.pc_registrar_gravames(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrctrpro => pr_nrctremp
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
            -- Tratar saida com erro
            IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              raise vr_exc_erro;
            END IF;                                
          END IF;
        -- (1 - Em processamento) foi solicitado o gravames
        ELSIF vr_cdsitgrv = 1 THEN
          continue;
        -- (2 - alieando) retornar alienado
        ELSIF vr_cdsitgrv = 2 THEN
          pr_flaliena := 1; --> se foi alieando retorna 1 TODO O RESTO RETORNA 0 conforme inicio da variavel
        --> (3 - Processado com critica) Processado com Critica
        ELSIF vr_cdsitgrv = 3 THEN
          -- Gravação de pendência na proposta
          pc_grava_pedencia_emprestimo (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctremp => pr_nrctremp
                                       ,pr_dstipo_doc => 'GRAVAMES'
                                       ,pr_dsreprovacao => 2   --dsreprovacao (0-aprovado, 2-nao aprovado)
                                       ,pr_dsobservacao => vr_dscrigrv
                                       ,pr_cdcritic => vr_cdcritic 
                                       ,pr_dscritic => vr_dscritic);

          -- Tratamento de erro de retorno
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            raise vr_exc_erro;
          END IF;
          -- Reinicia fluxo de efetivação
          pc_reinicia_fluxo_efetivacao (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctremp => pr_nrctremp
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
                        
          -- Tratamento de erro de retorno
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            raise vr_exc_erro;
          END IF;                            
		  -- Retorna situação pro Ibracred
          pc_retorna_situacao_ibracred (pr_cdcooper  => pr_cdcooper      --> Coodigo Cooperativa
                                       ,pr_nrdconta  => pr_nrdconta      --> Numero da Conta do Associado
                                       ,pr_nrctremp  => pr_nrctremp      --> Numero do contrato
                                       ,pr_cdoperad  => 1                --> Codigo do operador
                                       ,pr_cdsitprp  => 25 -- Pagamento negado      --> Situação da proposta na IBRACRED
                                       ,pr_cdcritic  => vr_cdcritic      --> Código da crítica
                                       ,pr_dscritic  => vr_dscritic);   --> Descrição da crítica

          -- Tratamento de erro de retorno
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEn
            raise vr_exc_erro;
          END IF;
        END IF; 
      END LOOP; --> FIM LOOP cr_crapbpr                            
       
    END IF;   
       
  EXCEPTION   
     
    -- Críticas tratadas
    WHEN vr_exc_erro THEN
    
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);      
      END IF;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    -- Críticas nao tratadas
    WHEN OTHERS THEN                                      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na rotina GRVM0001.pc_valida_situacao_gravames -> '||SQLERRM;        
      
      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );      
      
  END pc_gravames_proposta_cdc;
  
  
  PROCEDURE pc_manter_tarifa_adesao_cdc(pr_cdcooper  IN crapcop.cdcooper%TYPE     -- Código da cooperativa do lojista 
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE     -- Número da conta do lojista 
                                       ,pr_flgconve  IN crapcdr.flgconve%TYPE     -- Flag de convenio (1-Sim, 0-Não) 
                                       ,pr_flcnvold  IN crapcdr.flgconve%TYPE     -- Flag de convenio anterior (1-Sim, 0-Não) 
                                       ,pr_flgitctr  IN crapcdr.flgitctr%TYPE     -- Flag de isencao de cobranca de tarifa cdc (0-nao isento, 1-isento)
                                       ,pr_flitctro  IN crapcdr.flgitctr%TYPE     -- Flag de isencao de cobranca de tarifa cdc anterior (0-nao isento, 1-isento)
                                       ,pr_cdoperad  IN crapope.cdoperad%TYPE     -- Operador
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE     -- Código de erro 
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE) IS -- Descrição de erro
    BEGIN                                   
    /* .............................................................................

    Programa: pc_manter_tarifa_adesao_cdc
    Sistema : Ayllos Web
    Autor   : Jean Michel
    Data    : 11/12/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Controlar adesão da tarifa CDC

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      
      -- Consultar tipo de cooperado
      CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT ass.inpessoa
              ,ass.cdagenci
              ,ass.nrdctitg
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Consultar tipo de cooperado
      CURSOR cr_craplat(pr_cdcooper crapass.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE
                       ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                       ,pr_cdhistor craphis.cdhistor%TYPE) IS
        SELECT lat.rowid
          FROM craplat lat
         WHERE lat.cdcooper = pr_cdcooper
           AND lat.nrdconta = pr_nrdconta
           AND lat.dtmvtolt = pr_dtmvtolt
           AND lat.cdhistor = pr_cdhistor;
      rw_craplat cr_craplat%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Variáveis de Erro          
      vr_exc_erro EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic crapcri.dscritic%TYPE := '';
      -- PLTABLE de erro generica
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Variáveis locais
      vr_inpessoa crapass.inpessoa%TYPE := 0;
      vr_rowid_lat ROWID;
      vr_cdbattar VARCHAR2(50) := '';
      vr_cdhistor INTEGER;
      vr_cdhisest NUMBER;
      vr_vlrtarif NUMBER;
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;
      vr_cdprogra VARCHAR2(50) := 'ATENDA_CVNCDC';
      vr_qtmesren INTEGER;
      vr_flcbrtar integer := 0; -- se ja cobrou tarifa (0-Nao, 1-Sim)

    BEGIN

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);

      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
        vr_inpessoa := rw_crapass.inpessoa;
      END IF;

      IF vr_inpessoa = 1 THEN -- PF
        vr_cdbattar := 'CADCDCLJPF'; -- Cadastro CDC Pessoa Fisica TAR 157
        vr_cdhistor := 1437;
      ELSE -- PJ
        vr_cdbattar := 'CADCDCLJPJ'; -- Cadastro CDC Pessoa Juridica TAR 158
        vr_cdhistor := 1461;
      END IF;
      
      BEGIN
        --> Buscar quantidade de meses para renovação
        vr_qtmesren := trim(gene0001.fn_param_sistema (pr_nmsistem => 'CRED'
                                                      ,pr_cdcooper => pr_cdcooper
                                                      ,pr_cdacesso => 'QTD_MES_RENOVA_TAR_CDC'));
        IF nvl(vr_qtmesren,0) <= 0 THEN
          vr_qtmesren := 12;  
        END IF;
        
      EXCEPTION 
        WHEN OTHERS THEN
          vr_qtmesren := 12; 
      END;

      IF pr_flgconve = 1 AND pr_flcnvold  = 0 THEN -- possui CDC

        OPEN cr_craplat (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                        ,pr_cdhistor => vr_cdhistor);
        FETCH cr_craplat INTO rw_craplat;

        -- se ja tiver tarifa nao faz nada e sai fora do programa
        IF cr_craplat%FOUND THEN
           vr_flcbrtar := 1;
        END IF;
        CLOSE cr_craplat;

        BEGIN
          update crapcdr cdr
             set cdr.dttercon=add_months(rw_crapdat.dtmvtolt, vr_qtmesren)
           where cdr.cdcooper=pr_cdcooper
             and cdr.nrdconta=pr_nrdconta;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar data de termino!';
            RAISE vr_exc_erro;
        END;

        -- somente cobrar quando o lojista nao possuir isencao e se nao foi lancada tarifa
        IF pr_flgitctr=0 AND vr_flcbrtar=0 THEN
          TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper -- IN cooperativa 
                                               ,pr_cdbattar => vr_cdbattar -- IN nome da tarifa 
                                               ,pr_vllanmto => 1 -- IN 0 ou 1 -- valor do movimento 
                                               ,pr_cdprogra => vr_cdprogra -- IN 
                                               ,pr_cdhistor => vr_cdhistor -- OUT 
                                               ,pr_cdhisest => vr_cdhisest -- OUT 
                                               ,pr_vltarifa => vr_vlrtarif -- OUT 
                                               ,pr_dtdivulg => vr_dtdivulg -- OUT 
                                               ,pr_dtvigenc => vr_dtvigenc -- OUT 
                                               ,pr_cdfvlcop => vr_cdfvlcop -- OUT 
                                               ,pr_cdcritic => vr_cdcritic -- OUT 
                                               ,pr_dscritic => vr_dscritic -- OUT 
                                               ,pr_tab_erro => vr_tab_erro); -- OUT 

          -- Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            -- Se possui erro no vetor
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic := 0;
              vr_dscritic := 'Erro no lancamento de tarifa CDC.';
            END IF;
            -- Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

          TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper => pr_cdcooper -- Codigo Cooperativa 
                                          ,pr_nrdconta => pr_nrdconta -- Numero da Conta 
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data Lancamento 
                                          ,pr_cdhistor => vr_cdhistor -- retornado na chamada pc_carrega_dados_tar_vigente -- Codigo Historico 
                                          ,pr_vllanaut => vr_vlrtarif -- retornado na chamada pc_carrega_dados_tar_vigente -- Valor lancamento automatico 
                                          ,pr_cdoperad => pr_cdoperad -- Codigo Operador 
                                          ,pr_cdagenci => rw_crapass.cdagenci -- PEGAR DA TABELA E COLUNA CITADA -- Codigo Agencia 
                                          ,pr_cdbccxlt => 100 -- valor fixo -Codigo banco caixa 
                                          ,pr_nrdolote => 650007 -- valor fixo -Numero do lote 
                                          ,pr_tpdolote => 1 -- valor fixo -Tipo do lote 
                                          ,pr_nrdocmto => 0 -- valor fixo -numero do documento 
                                          ,pr_nrdctabb => pr_nrdconta -- numero da conta 
                                          ,pr_nrdctitg => rw_crapass.nrdctitg -- PEGAR DA TABELA E COLUNA CITADA -- Numero da conta integraca 
                                          ,pr_cdpesqbb => 'Fato gerador tarifa: ' || vr_cdbattar -- Codigo pesquisa 
                                          ,pr_cdbanchq => 0 -- Codigo Banco Cheque 
                                          ,pr_cdagechq => 0 -- Codigo Agencia Cheque 
                                          ,pr_nrctachq => 0 -- Numero Conta Cheque 
                                          ,pr_flgaviso => FALSE --Flag aviso 
                                          ,pr_tpdaviso => 0 -- Tipo aviso 
                                          ,pr_cdfvlcop => vr_cdfvlcop -- retornado na chamada pc_carrega_dados_tar_vigente -- Codigo cooperativa 
                                          ,pr_inproces => rw_crapdat.inproces --Indicador processo 
                                          ,pr_rowid_craplat => vr_rowid_lat -- Rowid do lancamento tarifa 
                                          ,pr_tab_erro => vr_tab_erro 
                                          ,pr_cdcritic => vr_cdcritic 
                                          ,pr_dscritic => vr_dscritic);

          -- Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            -- Se possui erro no vetor
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic := 0;
              vr_dscritic := 'Erro no lancamento de tarifa CDC.';
            END IF;
            -- Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        
        END IF;

      END IF; -- Não possui CDC

      -- Efetua o commit
      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC(pc_manter_tarifa_adesao_cdc): ' || SQLERRM;
        ROLLBACK;
    END;

  END pc_manter_tarifa_adesao_cdc;
  
  PROCEDURE pc_manter_tarifa_renovacao_cdc(pr_cdcritic OUT crapcri.cdcritic%TYPE     -- Código de erro 
                                          ,pr_dscritic OUT crapcri.dscritic%TYPE) IS -- Descrição de erro
    BEGIN                                   
    /* .............................................................................

    Programa: pc_manter_tarifa_renovacao_cdc
    Sistema : Ayllos Web
    Autor   : Jean Michel
    Data    : 11/12/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Controlar adesão da tarifa CDC

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- data das coopeativas
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- cursor com as cooperativas
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper
          FROM crapcop cop
         ORDER BY cop.cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- lojista que precisam de renovacao
      CURSOR cr_crapcdr (pr_cdcooper crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
        SELECT pr_dtmvtolt dtrencon -- data de renovacao do convenio 
              ,cdr.cdcooper 
              ,cdr.nrdconta 
              ,cdr.dttercon 
              ,ass.inpessoa
              ,ass.cdagenci
              ,ass.nrdctitg
              ,DECODE(ass.inpessoa,1,'RENCDCLJPF','RENCDCLJPJ') as cdbattar
              ,DECODE(ass.inpessoa,1,'1439','1463') as cdhistor
              ,cdr.flgitctr
              ,cdr.rowid
          FROM crapcdr cdr
              ,crapass ass 
         WHERE cdr.cdcooper = pr_cdcooper
           AND cdr.flgconve = 1 -- cdc ativo
           AND cdr.dttercon < pr_dtmvtolt -- contratos vencidos
           AND cdr.cdcooper = ass.cdcooper
           AND cdr.nrdconta = ass.nrdconta;
      rw_crapcdr cr_crapcdr%ROWTYPE;

      -- Variáveis de Erro          
      vr_exc_erro EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic crapcri.dscritic%TYPE := '';
      -- PLTABLE de erro generica
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Variáveis locais
      vr_assunto  VARCHAR2(4000) := '';     
      vr_conteudo VARCHAR2(4000) := '';

      vr_rowid_lat ROWID;
      vr_cdbattar VARCHAR2(50) := '';
      vr_cdhistor INTEGER;
      vr_cdhisest NUMBER;
      vr_vlrtarif NUMBER;
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;
      vr_cdprogra VARCHAR2(50) := 'ATENDA_CVNCDC';
      vr_dttercon_prox DATE;
      vr_qtmesren      INTEGER;

    BEGIN

      FOR rw_crapcop IN cr_crapcop LOOP

        -- Leitura do calendário da cooperativa
        OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
       
        -- Se não encontrar
        IF btch0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois efetuaremos raise
          CLOSE btch0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic := 1;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor
          CLOSE btch0001.cr_crapdat;
        END IF;
        
        BEGIN
          --> Buscar quantidade de meses para renovação
          vr_qtmesren := trim(gene0001.fn_param_sistema ( pr_nmsistem => 'CRED', 
                                                          pr_cdcooper => rw_crapcop.cdcooper, 
                                                          pr_cdacesso => 'QTD_MES_RENOVA_TAR_CDC'));
          IF nvl(vr_qtmesren,0) <= 0 THEN
            vr_qtmesren := 12;  
          END IF;
          
        EXCEPTION 
          WHEN OTHERS THEN
            vr_qtmesren := 12; 
        END;

        -- Definir proxima data de termino 
        vr_dttercon_prox  := add_months(rw_crapdat.dtmvtolt, vr_qtmesren); 
        
        
        FOR rw_crapcdr IN cr_crapcdr(rw_crapcop.cdcooper, rw_crapdat.dtmvtolt) LOOP

          BEGIN
            -- atualiza registro para renovar a matricula
            UPDATE crapcdr cdr
               SET cdr.dtrencon = rw_crapcdr.dtrencon
                  ,cdr.dttercon = vr_dttercon_prox
             WHERE rowid= rw_crapcdr.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar renovacao de tarifa';
              RAISE vr_exc_erro;
          END;

          -- se for isento de tarifa nao deve aplicar a cobranca de tarifa
          IF rw_crapcdr.flgitctr=1 THEN
            continue;
          END IF;

          -- busca a tarifa
          TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => rw_crapcdr.cdcooper -- IN cooperativa 
                                               ,pr_cdbattar => rw_crapcdr.cdbattar -- IN nome da tarifa 
                                               ,pr_vllanmto => 1 -- IN 0 ou 1 -- valor do movimento 
                                               ,pr_cdprogra => vr_cdprogra -- IN 
                                               ,pr_cdhistor => vr_cdhistor -- OUT 
                                               ,pr_cdhisest => vr_cdhisest -- OUT 
                                               ,pr_vltarifa => vr_vlrtarif -- OUT 
                                               ,pr_dtdivulg => vr_dtdivulg -- OUT 
                                               ,pr_dtvigenc => vr_dtvigenc -- OUT 
                                               ,pr_cdfvlcop => vr_cdfvlcop -- OUT 
                                               ,pr_cdcritic => vr_cdcritic -- OUT 
                                               ,pr_dscritic => vr_dscritic -- OUT 
                                               ,pr_tab_erro => vr_tab_erro); -- OUT 
          
          -- cria a tarifa
          TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper => rw_crapcdr.cdcooper -- Codigo Cooperativa 
                                          ,pr_nrdconta => rw_crapcdr.nrdconta -- Numero da Conta 
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data Lancamento 
                                          ,pr_cdhistor => vr_cdhistor -- retornado na chamada pc_carrega_dados_tar_vigente -- Codigo Historico 
                                          ,pr_vllanaut => vr_vlrtarif -- retornado na chamada pc_carrega_dados_tar_vigente -- Valor lancamento automatico 
                                          ,pr_cdoperad => '1' -- Codigo Operador 
                                          ,pr_cdagenci => rw_crapcdr.cdagenci -- PEGAR DA TABELA E COLUNA CITADA -- Codigo Agencia 
                                          ,pr_cdbccxlt => 100 -- valor fixo -Codigo banco caixa 
                                          ,pr_nrdolote => 650006 -- valor fixo -Numero do lote 
                                          ,pr_tpdolote => 1 -- valor fixo -Tipo do lote 
                                          ,pr_nrdocmto => 0 -- valor fixo -numero do documento 
                                          ,pr_nrdctabb => rw_crapcdr.nrdconta -- numero da conta 
                                          ,pr_nrdctitg => rw_crapcdr.nrdctitg -- PEGAR DA TABELA E COLUNA CITADA -- Numero da conta integraca 
                                          ,pr_cdpesqbb => 'Fato gerador tarifa: ' || vr_cdbattar -- Codigo pesquisa 
                                          ,pr_cdbanchq => 0 -- Codigo Banco Cheque 
                                          ,pr_cdagechq => 0 -- Codigo Agencia Cheque 
                                          ,pr_nrctachq => 0 -- Numero Conta Cheque 
                                          ,pr_flgaviso => FALSE --Flag aviso 
                                          ,pr_tpdaviso => 0 -- Tipo aviso 
                                          ,pr_cdfvlcop => vr_cdfvlcop -- retornado na chamada pc_carrega_dados_tar_vigente -- Codigo cooperativa 
                                          ,pr_inproces => rw_crapdat.inproces --Indicador processo 
                                          ,pr_rowid_craplat => vr_rowid_lat -- Rowid do lancamento tarifa 
                                          ,pr_tab_erro => vr_tab_erro 
                                          ,pr_cdcritic => vr_cdcritic 
                                          ,pr_dscritic => vr_dscritic);

          -- Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            -- Se possui erro no vetor
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic := 0;
              vr_dscritic := 'Erro no lancamento de tarifa CDC.';
            END IF;

            vr_assunto := 'Erro ao cobrar tarifa de renovacao CDC';
            vr_conteudo := 'Cooperativa: ' || rw_crapcdr.cdcooper
                         || CHR(10) 
                         ||'Conta: ' || rw_crapcdr.nrdconta ;

            --Enviar Email
            GENE0003.pc_solicita_email(pr_cdcooper        => rw_crapcdr.cdcooper    --> Cooperativa conectada
                                      ,pr_cdprogra        => 'JBEPR_RENOVARTARIFACDC'    --> Programa conectado
                                      ,pr_des_destino     => 'cdc@ailos.coop.br' --> Um ou mais detinatários separados por ';' ou ','
                                      ,pr_des_assunto     => vr_assunto     --> Assunto do e-mail
                                      ,pr_des_corpo       => vr_conteudo    --> Corpo (conteudo) do e-mail
                                      ,pr_des_anexo       => NULL           --> Um ou mais anexos separados por ';' ou ','
                                      ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                                      ,pr_flg_remete_coop => 'N'            --> Se o envio será do e-mail da Cooperativa
                                      ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                                      ,pr_des_email_reply => NULL           --> Endereço para resposta ao e-mail
                                      ,pr_flg_enviar      => 'S'            --> Enviar o e-mail na hora
                                      ,pr_flg_log_batch   => 'N'            --> Incluir inf. no log
                                      ,pr_des_erro        => vr_dscritic);  --> Descricao Erro
            --Se ocorreu erro
            IF vr_dscritic IS NOT NULL THEN
              vr_cdcritic:= 0;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;

          END IF; -- validacao de erro          
        END LOOP; -- dados
      END LOOP; -- cooperativa

      -- Efetua o commit
      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CVNCDC(pc_manter_tarifa_renovacao_cdc): ' || SQLERRM;
        ROLLBACK;
    END;

  END pc_manter_tarifa_renovacao_cdc;
  
  --> Rotina para atualizar situação da propost - Rotina utilizada pelo CDC atraves do barramento
  PROCEDURE pc_altera_situacao_proposta (pr_cdcooper  IN crapcop.cdcooper%TYPE    -- Código da cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE    -- Número da conta
                                        ,pr_nrctremp  IN crawepr.nrdconta%TYPE    -- Número do contrato
                                        ,pr_insitapr  IN crawepr.insitapr%TYPE    -- situação da proposta 
                                        ,pr_insitest  IN crawepr.insitest%TYPE    -- Situação da esteira      
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE    -- Código de erro 
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE) IS -- Descrição de erro                              
    /* .............................................................................

      Programa: pc_altera_situacao_proposta
      Sistema : Barramento de Serviço
      Autor   : Odirlei Busana - AMcom
      Data    : 10/07/2018                 Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para atualizar situação da propost - Rotina utilizada pelo CDC atraves do barramento

      Alteracoes: -----
    ..............................................................................*/

      -- Verificar se contrato de emprestimo já foi aprovado
      CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                       ,pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT ROWID,
               epr.insitapr,
               epr.insitest
          FROM crawepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;     
      rw_crawepr cr_crawepr%ROWTYPE;
       
      --> Cursor de Emprestimos
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT 1              
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;

      -- Variáveis de Erro          
      vr_exc_erro EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic crapcri.dscritic%TYPE := '';

    BEGIN
    
      -- Verificar se contrato de emprestimo existe
      OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;
      
      -- Se não encotrou, incluir critica e sair
      IF cr_crawepr%NOTFOUND THEN
        vr_cdcritic := 535;
        close cr_crawepr;
        raise vr_exc_erro;
      END IF;
      CLOSE cr_crawepr; 
      
      -- Busca dos detalhes do empréstimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      -- Se encontrar informações
      IF cr_crapepr%FOUND THEN
        CLOSE cr_crapepr;
        
        -- Gerar critica 
        vr_cdcritic := 970; --> 970 - Proposta ja efetivada.
        RAISE vr_exc_erro;
        
      ELSE
        CLOSE cr_crapepr;
      END IF;
      
      --> Atualizar situaçao da proposta
      BEGIN
        UPDATE crawepr epr
           SET insitapr = pr_insitapr,
               insitest = pr_insitest
         WHERE epr.rowid = rw_crawepr.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel atualizar proposta: '||SQLERRM;
      END;
      
      -- Efetua o commit
      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral ao atualizar sit. proposta: ' || SQLERRM;
        ROLLBACK;

  END pc_altera_situacao_proposta;
  
  PROCEDURE pc_retorna_situacao_ibracred (pr_cdcooper  IN crapcop.cdcooper%TYPE      --> Coodigo Cooperativa
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE      --> Numero da Conta do Associado
                                         ,pr_nrctremp  IN crapepr.nrctremp%TYPE      --> Numero do contrato
                                         ,pr_cdoperad  IN crapope.cdoperad%TYPE      --> Codigo do operador
                                         ,pr_cdsitprp  IN INTEGER                    --> Situação da proposta na IBRACRED
                                         -->> SAIDA
                                         ,pr_cdcritic OUT PLS_INTEGER                --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2                   --> Descrição da crítica
                                         ) IS 

  /* .............................................................................

       Programa: pc_retorna_situacao_ibracred 
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana - AMcom
       Data    : 13/07/2018                            Ultima atualizacao: 13/07/2018

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Rotina responsavel por retornar situação para o IBRACRED

       Alteracoes:
       
                  
    ............................................................................. */
    ----->> CURSORES <<-----
    --> Buscar dados do emprestimo
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE)IS
      SELECT epr.cdagenci cdagenci_epr,
             age_epr.nmresage nmresage_epr,
             ass.cdagenci cdagenci_ass,
             age_ass.nmresage nmresage_ass,
             epr.cdfinemp,
             -- Indica que am linha de credito eh CDC ou C DC
             DECODE(EMPR0001.fn_tipo_finalidade(pr_cdcooper => epr.cdcooper
                                               ,pr_cdfinemp => epr.cdfinemp),3,1,0) AS inlcrcdc
        FROM crawepr epr,
             crapass ass,
             crapage age_epr,
             crapage age_ass
       WHERE epr.cdcooper = ass.cdcooper
         AND epr.nrdconta = ass.nrdconta
         AND epr.cdcooper = age_epr.cdcooper
         AND epr.cdagenci = age_epr.cdagenci
         AND epr.cdcooper = age_ass.cdcooper
         AND epr.cdagenci = age_ass.cdagenci         
         AND epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;  
    rw_crawepr cr_crawepr%ROWTYPE;
    
    --> Buscar operador
    CURSOR cr_crapope (pr_cdcooper  crapope.cdcooper%TYPE,
                       pr_cdoperad  crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad,
             ope.cdoperad,
             ope.cdagenci  
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND upper(ope.cdoperad) = upper(pr_cdoperad);
    
    rw_crapope cr_crapope%ROWTYPE;
    
    ----->> VARIAVEIS <<-----
    -- Variáveis de Erro          
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   crapcri.cdcritic%TYPE := 0;
    vr_dscritic   crapcri.dscritic%TYPE := '';
    
    -- variaveis programa
    vr_cdprodut   INTEGER;
    vr_dsprodut   VARCHAR2(20);
    vr_idevento   tbgen_evento_soa.idevento%type;
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    ---------------------------> SUBROTINAS <--------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END; 
    
  BEGIN  
    
    --> validar situações possiveis
    IF pr_cdsitprp NOT IN (21,22,23,24,25,26,27) THEN
      vr_dscritic := 'Situação invalida';
      RAISE vr_exc_erro;
    END IF;
    
    --> Buscar dados do emprestimo
    OPEN cr_crawepr (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta,
                     pr_nrctremp => pr_nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;                  
    IF cr_crawepr%NOTFOUND THEN
      vr_cdcritic := 535; --> 535 - Proposta nao encontrada.
      CLOSE cr_crawepr;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crawepr;
    END IF;
    
    -- Buscar dados do operador
    OPEN cr_crapope (pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
      RAISE vr_exc_erro; 
    ELSE
      CLOSE cr_crapope;
    END IF; 
   
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;

    pc_escreve_xml ('<?xml version="1.0" encoding="ISO-8859-1" ?><dados>');   
    
    pc_escreve_xml ('<cooperativa><codigo>'||pr_cdcooper||'</codigo></cooperativa>');
    pc_escreve_xml ('<postoAtendimento><codigo>'||rw_crawepr.cdagenci_epr||'</codigo></postoAtendimento>');
    -- tag propostaContratoCredito
    pc_escreve_xml ('<propostaContratoCredito>');
      -- tag emitente
      pc_escreve_xml ('<emitente>');
        pc_escreve_xml ('<contaCorrente>'); 
        pc_escreve_xml ('<codigoContaSemDigito>'||substr(pr_nrdconta,1,length(pr_nrdconta)-1)||'</codigoContaSemDigito>');
        pc_escreve_xml ('<digitoVerificadorConta>'||substr(pr_nrdconta,-1)||'</digitoVerificadorConta>');
        pc_escreve_xml ('<cooperativa><codigo>'||pr_cdcooper||'</codigo></cooperativa>');
        pc_escreve_xml ('<postoAtendimento><codigo>'||rw_crawepr.cdagenci_ass||'</codigo></postoAtendimento>');
        pc_escreve_xml ('</contaCorrente>'); 
      pc_escreve_xml ('</emitente>');
    
                    
    /* 0 – CDC Diversos
       1 – CDC Veículos 
       2 – Empréstimos /Financiamentos 
       3 – Desconto Cheques 
       4 – Desconto Títulos 
       5 – Cartão de Crédito 
       6 – Limite de Crédito) */

    -- Se for CDC e diversos
    IF rw_crawepr.cdfinemp = 58 AND rw_crawepr.inlcrcdc = 1 THEN
      vr_cdprodut := 0; -- CDC Diversos
      vr_dsprodut := 'CDC Diversos';
    -- Se for CDC e veiculos
    ELSIF rw_crawepr.cdfinemp = 59 AND rw_crawepr.inlcrcdc = 1 THEN
      vr_cdprodut := 1; -- CDC Veiculos
      vr_dsprodut := 'CDC Veiculos';
    ELSE
      vr_cdprodut := 2; -- Emprestimos/Financiamento
      vr_dsprodut := 'Emprestimos/Financiamento';  
    END IF;
    
      pc_escreve_xml ('<statusProposta><codigo>'||pr_cdsitprp||'</codigo></statusProposta>');
      pc_escreve_xml ('<identificadorProposta>'||pr_nrctremp||'</identificadorProposta>');

      -- tag produto
      pc_escreve_xml ('<produto>');
      pc_escreve_xml ('<codigo>'||vr_cdprodut||'</codigo>');
      pc_escreve_xml ('<descricao>'||vr_dsprodut||'</descricao>');
      pc_escreve_xml ('</produto>');
    pc_escreve_xml ('</propostaContratoCredito>');

    -- tag configuracaoAnaliseCredito
    pc_escreve_xml ('<configuracaoAnaliseCredito><dataAlteracaoProposta>'|| este0001.fn_DataTempo_ibra(SYSDATE)||'</dataAlteracaoProposta></configuracaoAnaliseCredito>');

    -- tag usuarioDominioCecred
    pc_escreve_xml ('<usuarioDominioCecred>');
    pc_escreve_xml ('<codigo>'||rw_crapope.cdoperad||'</codigo>');
    pc_escreve_xml ('<descricao>'||rw_crapope.nmoperad||'</descricao>');
    pc_escreve_xml ('</usuarioDominioCecred>');

    pc_escreve_xml ('</dados>',TRUE);  

    soap0003.pc_gerar_evento_soa(pr_cdcooper               => pr_cdcooper
                                ,pr_nrdconta               => pr_nrdconta
                                ,pr_nrctrprp               => pr_nrctremp
                                ,pr_tpevento               => 'ATUALIZASTATUS'
                                ,pr_tproduto_evento        => 'CDC'
                                ,pr_tpoperacao             => 'UPDATE'
                                ,pr_dsconteudo_requisicao  => vr_des_xml
                                ,pr_idevento               => vr_idevento
                                ,pr_dscritic               => vr_dscritic);
                               
                               
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro ao retornar situacao: ' || SQLERRM;
  END pc_retorna_situacao_ibracred;      
  
  PROCEDURE pc_reinicia_fluxo_efetivacao (pr_cdcooper  IN crapcop.cdcooper%TYPE      --> Coodigo Cooperativa
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE      --> Numero da Conta do Associado
                                         ,pr_nrctremp  IN crapepr.nrctremp%TYPE      --> Numero do contrato
                                         -->> SAIDA
                                         ,pr_cdcritic OUT PLS_INTEGER                --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2) IS               --> Descrição da crítica

  /* .............................................................................

       Programa: pc_reinicia_fluxo_efetivacao 
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Rafael Faria (supero)
       Data    : 20/08/2018                            Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Rotina responsavel por retornar o fluxo de pagamento

       Alteracoes:
    ............................................................................. */

    -- Variáveis de Erro          
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   crapcri.cdcritic%TYPE := 0;
    vr_dscritic   crapcri.dscritic%TYPE := '';
    
  BEGIN 

    BEGIN
      -- Informa que a proposta possui erro e reiniciar o fluxo de ajustes da proposta
      UPDATE crawepr w
         SET flgdocdg = 0 
       WHERE w.cdcooper=pr_cdcooper
         and w.nrdconta=pr_nrdconta
         and w.nrctremp=pr_nrctremp;
    EXCEPTION 
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar o crawepr: '||SQLERRM;
        RAISE vr_exc_erro;                 
    END;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro ao retornar situacao: ' || SQLERRM;
  END pc_reinicia_fluxo_efetivacao;      

  PROCEDURE pc_grava_pedencia_emprestimo (pr_cdcooper   IN tbepr_cdc_empr_doc.cdcooper%TYPE      --> Coodigo Cooperativa
                                         ,pr_nrdconta   IN tbepr_cdc_empr_doc.nrdconta%TYPE      --> Numero da Conta do Associado
                                         ,pr_nrctremp   IN tbepr_cdc_empr_doc.nrctremp%TYPE      --> Numero do contrato
                                         ,pr_dstipo_doc IN tbepr_cdc_empr_doc.dstipo_doc%TYPE         --> dstipo_doc
                                         ,pr_dsreprovacao IN tbepr_cdc_empr_doc.dsreprovacao%TYPE     --> dsreprovacao (0-aprovado, 2-nao aprovado)
                                         ,pr_dsobservacao IN tbepr_cdc_empr_doc.dsobservacao%TYPE     --> observacao da reprovacao
                                         -->> SAIDA
                                         ,pr_cdcritic OUT PLS_INTEGER                --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2) IS               --> Descrição da crítica

  /* .............................................................................

       Programa: pc_grava_pedencia_emprestimo 
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Rafael Faria (supero)
       Data    : 20/08/2018                            Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Rotina responsavel por retornar o fluxo de pagamento

       Alteracoes:
    ............................................................................. */

    -- Variáveis de Erro          
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   crapcri.cdcritic%TYPE := 0;
    vr_dscritic   crapcri.dscritic%TYPE := '';

  BEGIN 

    BEGIN
      INSERT INTO tbepr_cdc_empr_doc
                 (cdcooper
                 ,nrdconta
                 ,nrctremp
                 ,dstipo_doc
                 ,dsreprovacao
                 ,dsobservacao)
          values(pr_cdcooper      --> cdcooper
                ,pr_nrdconta      --> nrdconta
                ,pr_nrctremp      --> nrctremp
                ,pr_dstipo_doc    --> dstipo_doc
                ,pr_dsreprovacao  --> dsreprovacao (0-aprovado, 2-nao aprovado)
                ,pr_dsobservacao);--> observacao da reprovacao

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivei incluir tbepr_cdc_empr_doc: '||SQLERRM;
        RAISE vr_exc_erro;
    END; 

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro ao retornar situacao: ' || SQLERRM;
  END pc_grava_pedencia_emprestimo;      

  PROCEDURE pc_reg_push_sit_prop_cdc_web (pr_cdcooper   IN tbgen_evento_soa.cdcooper%TYPE      --> Coodigo Cooperativa
                                         ,pr_nrdconta   IN tbgen_evento_soa.nrdconta%TYPE      --> Numero da Conta do Associado
                                         ,pr_nrctremp   IN tbgen_evento_soa.nrctrprp%TYPE      --> Numero do contrato
                                         ,pr_insitpro   IN NUMBER                              --> Situação da proposta
                                         ,pr_xmllog     IN VARCHAR2                            --> XML com informações de LOG
                                         ,pr_cdcritic   OUT PLS_INTEGER                        --> Código da crítica
                                         ,pr_dscritic   OUT VARCHAR2                           --> Descrição da crítica
                                         ,pr_retxml     IN OUT NOCOPY xmltype                  --> Arquivo de retorno do XML
                                         ,pr_nmdcampo   OUT VARCHAR2                           --> Nome do Campo
                                         ,pr_des_erro   OUT VARCHAR2) IS                       --> Saida OK/NOK
  /* .............................................................................
       Programa: pc_reg_push_sit_prop_cdc_web 
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Rafael Faria (supero)
       Data    : 24/08/2018                            Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Rotina responsavel por notificar alteracao de proposta

       Alteracoes:
    ............................................................................. */
    
  BEGIN

    pc_registra_push_sit_prop_cdc (pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp
                                  ,pr_insitpro => pr_insitpro
                                  ,pr_cdcritic => pr_cdcritic
                                  ,pr_dscritic => pr_dscritic);
    
    -- Carregar XML padrao para variavel de retorno
  	pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																	 '<Root></Root>');

  EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral no programa: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_reg_push_sit_prop_cdc_web;      

  PROCEDURE pc_registra_push_sit_prop_cdc (pr_cdcooper   IN tbgen_evento_soa.cdcooper%TYPE      --> Coodigo Cooperativa
                                          ,pr_nrdconta   IN VARCHAR2                            --> Numero da Conta do Associado
                                          ,pr_nrctremp   IN VARCHAR2                            --> Numero do contrato
                                          ,pr_insitpro   IN NUMBER                              --> Situação da proposta
                                          -->> SAIDA
                                          ,pr_cdcritic OUT PLS_INTEGER                --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2) IS               --> Descrição da crítica

  /* .............................................................................

       Programa: pc_registra_push_sit_prop_cdc 
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Rafael Faria (supero)
       Data    : 24/08/2018                            Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Rotina responsavel por notificar alteracao de proposta

       Alteracoes:
    ............................................................................. */

    ----->> VARIAVEIS <<-----
    -- Variáveis de Erro          
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   crapcri.cdcritic%TYPE := 0;
    vr_dscritic   crapcri.dscritic%TYPE;
    
    -- variaveis programa
    vr_cdprodut   INTEGER;
    vr_dsprodut   VARCHAR2(20);
    vr_idevento   tbgen_evento_soa.idevento%type;
    
    vr_nrdconta   NUMBER;
    vr_nrctremp   NUMBER;
    
    vr_tpevento tbgen_evento_soa.tpevento%type := 'COMUNICACAO';
    vr_tproduto_evento tbgen_evento_soa.tproduto_evento%type := 'CDC';
    vr_tpoperacao tbgen_evento_soa.tpoperacao%type := 'NOTIFICAR';

    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    ---------------------------> SUBROTINAS <--------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END; 
    
  BEGIN

    vr_nrdconta := to_number(REPLACE(pr_nrdconta,'.',''));
    vr_nrctremp := to_number(REPLACE(pr_nrctremp,'.',''));

    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;

    pc_escreve_xml ('<?xml version="1.0" encoding="ISO-8859-1" ?><dados>');   
    
    -- tag propostaContratoCredito
    pc_escreve_xml ('<propostaContratoCredito>');
      -- tag emitente
      pc_escreve_xml ('<emitente>');
        pc_escreve_xml ('<contaCorrente>'); 
        pc_escreve_xml ('<codigoContaSemDigito>'||substr(vr_nrdconta,1,length(vr_nrdconta)-1)||'</codigoContaSemDigito>');
        pc_escreve_xml ('<digitoVerificadorConta>'||substr(vr_nrdconta,-1)||'</digitoVerificadorConta>');
        pc_escreve_xml ('<cooperativa><codigo>'||pr_cdcooper||'</codigo></cooperativa>');
        pc_escreve_xml ('</contaCorrente>'); 
      pc_escreve_xml ('</emitente>');
       /*
        3:"Aprovada"
        4:"Não Aprovada"
        5:"Pagamento Efetuado"
        8:"Cancelada"
        18:"Pendente"
        24:"Pagamento em análise"
        25:"Pagamento Negado"
       */
      pc_escreve_xml ('<statusProposta><codigo>'||pr_insitpro||'</codigo></statusProposta>');
      pc_escreve_xml ('<identificadorProposta>'||pr_nrctremp||'</identificadorProposta>');

    pc_escreve_xml ('</propostaContratoCredito>');

    pc_escreve_xml ('</dados>',TRUE);

    soap0003.pc_gerar_evento_soa(pr_cdcooper               => pr_cdcooper
                                ,pr_nrdconta               => vr_nrdconta
                                ,pr_nrctrprp               => vr_nrctremp
                                ,pr_tpevento               => vr_tpevento
                                ,pr_tproduto_evento        => vr_tproduto_evento
                                ,pr_tpoperacao             => vr_tpoperacao
                                ,pr_dsconteudo_requisicao  => vr_des_xml
                                ,pr_idevento               => vr_idevento
                                ,pr_dscritic               => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro ao retornar situacao: ' || SQLERRM;
  END pc_registra_push_sit_prop_cdc;      

  PROCEDURE pc_prepara_push_prop_cdc (pr_cdcooper   IN tbepr_cdc_emprestimo.cdcooper%TYPE      --> Coodigo Cooperativa
                                     ,pr_nrdconta   IN tbepr_cdc_emprestimo.nrdconta%TYPE      --> Numero da Conta do Associado
                                     ,pr_nrctremp   IN tbepr_cdc_emprestimo.nrctremp%TYPE      --> Numero do contrato
                                     ,pr_insitpro   IN NUMBER                                  --> Situação da proposta
                                     -->> SAIDA
                                     ,pr_retorno     OUT xmltype                               --> XML de retorno
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS               --> Descrição da crítica

  /* .............................................................................

       Programa: pc_prepara_push_prop_cdc 
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Rafael Faria (supero)
       Data    : 24/08/2018                            Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Rotina responsavel prepara notificacao proposta

       Alteracoes:
    ............................................................................. */
    ----->> CURSORES <<-----
    --> Buscar dados do emprestimo
    CURSOR cr_emprestimo (pr_cdcooper crawepr.cdcooper%TYPE
                         ,pr_nrdconta crawepr.nrdconta%TYPE
                         ,pr_nrctremp crawepr.nrctremp%TYPE)IS
      SELECT tce.idcooperado_cdc
            ,a.nmprimtl
            ,epr.cdfinemp
            -- Indica que am linha de credito eh CDC ou C DC
            ,DECODE(EMPR0001.fn_tipo_finalidade(pr_cdcooper => epr.cdcooper
                                               ,pr_cdfinemp => epr.cdfinemp),3,1,0) AS inlcrcdc
        FROM tbepr_cdc_emprestimo tce
            ,crawepr epr
            ,crapass a
       WHERE epr.cdcooper = tce.cdcooper
         AND epr.nrdconta = tce.nrdconta
         AND epr.nrctremp = tce.nrctremp
         AND epr.cdcooper = a.cdcooper
         AND epr.nrdconta = a.nrdconta
         AND tce.cdcooper = pr_cdcooper
         AND tce.nrdconta = pr_nrdconta
         AND tce.nrctremp = pr_nrctremp;
    rw_emprestimo cr_emprestimo%ROWTYPE;

    CURSOR cr_usuario (pr_idcooperado_cdc IN tbsite_cooperado_cdc.idcooperado_cdc%type) IS
      SELECT u.idusuario
            ,u.dslogin
            ,u.dstoken_ios
            ,u.dstoken_android
            ,u.dstoken_web
            ,n.flgprop_aprovada
            ,n.flgprop_negagada
            ,n.flgprop_cancelada
            ,n.flgpgto_efetuado
            ,n.flgpgto_analise
            ,n.flgpgto_negado
            ,n.flgpgto_pendente
        FROM tbepr_cdc_usuario_vinculo v
            ,tbepr_cdc_usuario u
            ,tbepr_cdc_usuario_notifica n
       WHERE v.idusuario=u.idusuario
         and u.idusuario=n.idusuario
         and v.idcooperado_cdc=pr_idcooperado_cdc
         and n.flgnotifica=0; --TODO 1 quando liberar
    rw_usuario cr_usuario%rowtype;

    ----->> VARIAVEIS <<-----
    -- Variáveis de Erro          
    vr_exc_erro   EXCEPTION;
    vr_cdcritic   crapcri.cdcritic%TYPE := 0;
    vr_dscritic   crapcri.dscritic%TYPE;

    -- variaveis programa
    vr_contador   numeric :=0;
    vr_idevento   tbgen_evento_soa.idevento%type;

    -- chamada do servico
    vr_tpevento        tbgen_evento_soa.tpevento%type        := 'COMUNICACAO';
    vr_tproduto_evento tbgen_evento_soa.tproduto_evento%type := 'CDC';
    vr_tpoperacao      tbgen_evento_soa.tpoperacao%type      := 'NOTIFICAR';
    vr_dssitpro        varchar2(100);

    -- links para acesso
    vr_url_portal  varchar2(100) := 'https://portalcdchml2.ailos.coop.br';
    vr_url_ios     varchar2(100) := '';
    vr_url_android varchar2(100) := '';
    
    vr_prioridade number(1) :=2;
    vr_canalComunicacao number(1) :=3;
    vr_canalRelacionamento number(1) :=2;

    -- variaveis de controle de push
    vr_flgprop_aprovada  tbepr_cdc_usuario_notifica.flgprop_aprovada%type  :=0;
    vr_flgprop_negagada  tbepr_cdc_usuario_notifica.flgprop_negagada%type  :=0;
    vr_flgprop_cancelada tbepr_cdc_usuario_notifica.flgprop_cancelada%type :=0;
    vr_flgpgto_efetuado  tbepr_cdc_usuario_notifica.flgpgto_efetuado%type  :=0;
    vr_flgpgto_analise   tbepr_cdc_usuario_notifica.flgpgto_analise%type   :=0;
    vr_flgpgto_negado    tbepr_cdc_usuario_notifica.flgpgto_negado%type    :=0;
    vr_flgpgto_pendente  tbepr_cdc_usuario_notifica.flgpgto_pendente%type  :=0;

    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);

    ---------------------------> SUBROTINAS <--------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END; 
    
  BEGIN  

    --> Buscar dados do emprestimo
    OPEN cr_emprestimo (pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp);
    FETCH cr_emprestimo INTO rw_emprestimo;
    IF cr_emprestimo%NOTFOUND THEN
      vr_cdcritic := 535; --> 535 - Proposta nao encontrada.
      CLOSE cr_emprestimo;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_emprestimo;
    END IF;

    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;

    -- iniciar xml
    pc_escreve_xml ('<?xml version="1.0" encoding="ISO-8859-1" ?><dados>');

      pc_escreve_xml ('<cdcooper>'||pr_cdcooper||'</cdcooper>');
      pc_escreve_xml ('<nrdconta>'||pr_nrdconta||'</nrdconta>');
      pc_escreve_xml ('<nrctremp>'||pr_nrctremp||'</nrctremp>');
      pc_escreve_xml ('<insitpro>'||pr_insitpro||'</insitpro>');
    
    /*
    3:"Aprovada"
    4:"Não Aprovada"
    5:"Pagamento Efetuado"
    8:"Cancelada"
    18:"Pendente"
    24:"Pagamento em análise"
    25:"Pagamento Negado"
    */

    IF pr_insitpro=3 THEN
      vr_dssitpro := 'Aprovado';
      vr_flgprop_aprovada:=1;
    ELSIF pr_insitpro=4 THEN
      vr_dssitpro := 'Nao Aprovado';
      vr_flgprop_negagada:=1;
    ELSIF pr_insitpro=5 THEN
      vr_dssitpro := 'Pagamento efetuado';
      vr_flgpgto_efetuado:=1;
    ELSIF pr_insitpro=8 THEN
      vr_dssitpro := 'Cancelada';
      vr_flgprop_cancelada:=1;
    ELSIF pr_insitpro=18 THEN
      vr_dssitpro := 'Pendente';
      vr_flgpgto_pendente:=1;
    ELSIF pr_insitpro=24 THEN
      vr_dssitpro := 'Pagamento em analise';
      vr_flgpgto_analise:=1;
    ELSIF pr_insitpro=25 THEN
      vr_dssitpro := 'Pagamento negado';
      vr_flgpgto_negado:=1;
    END IF;
    
      pc_escreve_xml ('<dsmsgpush>'||'A proposta do(a) cooperado (a) '|| rw_emprestimo.nmprimtl ||' teve o status atualizado(a) para '|| vr_dssitpro ||'</dsmsgpush>');
      pc_escreve_xml ('<dstitpush>Notificacao de proposta</dstitpush>');

      pc_escreve_xml ('<prioridade>'||vr_prioridade||'</prioridade>');
      pc_escreve_xml ('<canalComunicacao>'||vr_canalComunicacao||'</canalComunicacao>');
      pc_escreve_xml ('<canalRelacionamento>'||vr_canalRelacionamento||'</canalRelacionamento>');

      pc_escreve_xml ('<lista>');  
    FOR rw_usuario in cr_usuario (rw_emprestimo.idcooperado_cdc) LOOP

      -- verifica se o usuario deve receber o PUSH conforme configuracao
      IF vr_flgprop_aprovada=1 AND rw_usuario.flgprop_aprovada=1 THEN
        vr_contador := vr_contador + 1;
      ELSIF vr_flgprop_negagada=1 AND rw_usuario.flgprop_negagada=1 THEN
        vr_contador := vr_contador + 1;
      ELSIF vr_flgprop_cancelada=1 AND rw_usuario.flgprop_cancelada=1 THEN
        vr_contador := vr_contador + 1;
      ELSIF vr_flgpgto_efetuado=1 AND rw_usuario.flgpgto_efetuado=1 THEN
        vr_contador := vr_contador + 1;
      ELSIF vr_flgpgto_analise=1 AND rw_usuario.flgpgto_analise=1 THEN
        vr_contador := vr_contador + 1;
      ELSIF vr_flgpgto_negado=1 AND rw_usuario.flgpgto_negado=1 THEN
        vr_contador := vr_contador + 1;
      ELSIF vr_flgpgto_pendente=1 AND rw_usuario.flgpgto_pendente=1 THEN
        vr_contador := vr_contador + 1;
      ELSE
        continue;
      END IF;

      -- verifica os dispositivos que iram receber a mensagem IOS
      IF rw_usuario.dstoken_ios is not null THEN
        pc_escreve_xml ('<dispostivo>');
          pc_escreve_xml ('<token>'||rw_usuario.dstoken_ios||'</token>');
          pc_escreve_xml ('<url>'||vr_url_ios||'</url>');
        pc_escreve_xml ('</dispostivo>');
      END IF;

      -- verifica os dispositivos que iram receber a mensagem ANDROID
      IF rw_usuario.dstoken_android is not null THEN
        pc_escreve_xml ('<dispostivo>');
          pc_escreve_xml ('<token>'||rw_usuario.dstoken_android||'</token>');
          pc_escreve_xml ('<url>'||vr_url_android||'</url>');
        pc_escreve_xml ('</dispostivo>');
      END IF;

      -- verifica os dispositivos que iram receber a mensagem PORTAL
      IF rw_usuario.dstoken_web is not null THEN
        pc_escreve_xml ('<dispostivo>');
          pc_escreve_xml ('<token>'||rw_usuario.dstoken_web||'</token>');
          pc_escreve_xml ('<url>'||vr_url_portal||'</url>');
        pc_escreve_xml ('</dispostivo>');
      END IF;

    END LOOP;
      pc_escreve_xml ('</lista>');
    pc_escreve_xml ('</dados>',TRUE);

    IF vr_contador = 0 THEN
      -- Gerar crítica
      vr_cdcritic := 0;  
      vr_dscritic := 'Usuario sem configuracao de push';
      -- Levantar exceção
      RAISE vr_exc_erro;
    ELSE
      pr_retorno := xmltype(vr_des_xml);
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');  

      
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
     pr_cdcritic := 0;
     pr_dscritic := 'Erro não tratado na pc_retorna_segmento: ' || SQLERRM;
     -- Carregar XML padrao para variavel de retorno
     pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');  
  END pc_prepara_push_prop_cdc;      

  PROCEDURE pc_valida_envio_proposta(pr_cdcooper IN NUMBER     --> Código da cooperativa do lojista
																		,pr_nrdconta IN NUMBER     --> Número da conta do lojista
                                    ,pr_insitblq OUT NUMBER     --> 0 bloqueado 1 liberado
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
	/* .............................................................................
		Programa: pc_valida_envio_proposta
		Sistema : Integração CDC x Autorizador
		Sigla   : CRED
		Autor   : Rafael Faria (supero)
		Data    : Agosto/2018                       Ultima atualizacao: 
	    
		Dados referentes ao programa:
	    
		Frequencia: Sempre que for chamado
		Objetivo  : Rotina responsável por validar a trava de envio de proposta
	    
		Alteracoes: 
	............................................................................. */
	
    -- Variáveis para tratamento de erros
		vr_exc_erro EXCEPTION;
    vr_erro_lojista EXCEPTION;
		vr_dscritic crapcri.dscritic%TYPE;
		
		-- Variáveis auxiliares
		vr_qtdaciona NUMBER := 0;

		 -- data das coopeativas
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Buscar parâmetros do cdc
		CURSOR cr_param_cdc(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
		  SELECT par.nrprop_env
			      ,par.intempo_prop_env
			  FROM tbepr_cdc_parametro par
			 WHERE par.cdcooper = pr_cdcooper;		
		rw_param_cdc cr_param_cdc%ROWTYPE;

		CURSOR cr_ver_aciona(pr_cdcooper IN NUMBER
		                    ,pr_nrdconta IN NUMBER
												,pr_intempo_prop_env IN NUMBER) IS 
		  SELECT count(aci.rowid)
			  FROM tbsite_cooperado_cdc c
            ,tbepr_cdc_emprestimo e
            ,tbgen_webservice_aciona aci
			 WHERE c.cdcooper=pr_cdcooper
         AND c.nrdconta=pr_nrdconta
         AND c.idmatriz is null
         AND c.idcooperado_cdc=e.idcooperado_cdc
         AND aci.cdcooper=e.cdcooper
         AND aci.nrdconta=e.nrdconta
         AND aci.nrctrprp=e.nrctremp
         AND aci.dsoperacao='INTEGRACAO CDC - INCLUSAO PROPOSTA'
         AND aci.dhacionamento >= (SYSDATE - ((pr_intempo_prop_env / 60)/24));

  BEGIN

	  -- Buscar parâmetros CDC da cooperativa
	  OPEN cr_param_cdc(pr_cdcooper => pr_cdcooper);
		FETCH cr_param_cdc INTO rw_param_cdc;

    -- Se não encontrou parâmetros de integração CDC
    IF cr_param_cdc%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_param_cdc;
			-- Gerar crítica
			vr_dscritic := 'Parametros de CDC nao cadastrados.';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
		-- Fechar cursor
		CLOSE cr_param_cdc;	

    -- Verificar quantidade de acionamentos feitos pelo mesmo lojista dentro de uma hora		
    OPEN cr_ver_aciona(pr_cdcooper => pr_cdcooper
		                  ,pr_nrdconta => pr_nrdconta
								  		,pr_intempo_prop_env=> rw_param_cdc.intempo_prop_env );
		FETCH cr_ver_aciona INTO vr_qtdaciona;
    -- Fechar cursor
		CLOSE cr_ver_aciona;

    -- Verificar quantidade máxima parametrizada de envio de propostas por hora
    IF vr_qtdaciona > rw_param_cdc.nrprop_env THEN
			-- Gerar crítica
			vr_dscritic    := 'Lojista excedeu a quantidade de envio de propostas!';
			-- Levantar exceção
			RAISE vr_erro_lojista;
		END IF;

    -- pode enviar propostas
    pr_insitblq := 1;

	EXCEPTION
		WHEN vr_erro_lojista THEN		
			gene0003.pc_solicita_email(pr_cdcooper => pr_cdcooper
		                          ,pr_cdprogra => 'EMPR0012'
															,pr_des_destino => 'cdc@ailos.coop.br'
															,pr_des_assunto => 'Lojista excedeu o numero de envio de proposta'
															,pr_des_corpo => 'O Lojista da cooperativa ' || pr_cdcooper || ' conta ' || pr_nrdconta ||'.'|| CHR(13) ||
																							 'Excedeu a quantidade maxima de proposta enviadas ' || rw_param_cdc.nrprop_env || ' em menos de ' || rw_param_cdc.intempo_prop_env || 'de horas.'
															,pr_des_anexo => ''
															,pr_des_erro => vr_dscritic);
      -- Atribuir críticas
			pr_dscritic := vr_dscritic;
      -- nao pode enviar proposta
      pr_insitblq := 0;
    WHEN vr_exc_erro THEN
      pr_dscritic := 'Cooperativa sem parametros configurados';

    WHEN OTHERS THEN
      -- Erro
      pr_dscritic := 'Erro geral do sistema ' || SQLERRM;
      -- nao pode enviar proposta
      pr_insitblq := 0;
  END pc_valida_envio_proposta;
  
  PROCEDURE pc_valida_geracao_contrato (pr_cdcooper  IN crapcop.cdcooper%TYPE    -- Código da cooperativa
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE    -- Número da conta
                                       ,pr_nrctremp  IN crawepr.nrctremp%TYPE    -- Número do contrato
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE    -- Código de erro 
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE) IS -- Descrição de erro                              
    /* .............................................................................

      Programa: pc_valida_geracao_contrato
      Sistema : Barramento de Serviço
      Autor   : Rafael Faria - Supero
      Data    : 17/12/2018                 Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotirna responsavel por validar a situacao da proposta na geracao do contrato CDC

      Alteracoes: -----
    ..............................................................................*/

      -- Verificar se contrato de emprestimo já foi aprovado
      CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE
                       ,pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT epr.insitapr
              ,epr.insitest
              ,epr.cdoperad
          FROM crawepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;     
      rw_crawepr cr_crawepr%ROWTYPE;
       
      --> Cursor de Emprestimos
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT 1              
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;

      -- Variáveis de Erro          
      vr_exc_erro EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic crapcri.dscritic%TYPE := '';

    BEGIN
    
      -- Verificar se contrato de emprestimo existe
      OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;
      
      -- Se não encotrou, incluir critica e sair
      IF cr_crawepr%NOTFOUND THEN
        vr_cdcritic := 535;
        close cr_crawepr;
        raise vr_exc_erro;
      END IF;
      CLOSE cr_crawepr;
      
      IF rw_crawepr.insitapr not in (1,       --> Aprovado
                                     3) then  --> Aprovado com Restricao
        vr_cdcritic := 0;
        vr_dscritic := 'A proposta deve estar aprovada!';
        raise vr_exc_erro;
      END IF;   
     
      IF upper(rw_crawepr.cdoperad) != 'AUTOCDC' THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Proposta nao e da integracao CDC';
        raise vr_exc_erro;
      END IF;
      
      -- Busca dos detalhes do empréstimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      -- Se encontrar informações
      IF cr_crapepr%FOUND THEN
        CLOSE cr_crapepr;
        
        -- Gerar critica 
        vr_cdcritic := 970; --> 970 - Proposta ja efetivada.
        RAISE vr_exc_erro;
        
      ELSE
        CLOSE cr_crapepr;
      END IF;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral ao atualizar sit. proposta: ' || SQLERRM;
        ROLLBACK;

  END pc_valida_geracao_contrato;
  
 PROCEDURE pc_gera_numero_proposta(pr_cdcooper IN tbgen_evento_soa.cdcooper%TYPE --> Coodigo Cooperativa  
                                  ,pr_nrctremp OUT crawepr.nrctremp%TYPE
                                  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ) IS --> Saida OK/NOK
   /* .............................................................................
      Programa: pc_gera_numero_proposta 
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Daniel Zimmermann (Ailos)
      Data    :                          Ultima atualizacao:
   
      Dados referentes ao programa:
   
      Frequencia: Sempre que for chamado.
      Objetivo  : Gera numero proposta CDC
   
      Alteracoes:
   ............................................................................. */
   
    -- Variáveis de Erro          
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_nrctremp crawepr.nrctremp%TYPE := 0;
 
 BEGIN
   
   -- Rotina para criar lote
   vr_nrctremp := fn_sequence(pr_nmtabela => 'CRAWEPR',
                              pr_nmdcampo => 'NRCTREMP_CDC',
                              pr_dsdchave => TO_CHAR(pr_cdcooper));
                              
   IF vr_nrctremp = 0 THEN
     vr_cdcritic := 0;
     vr_dscritic := 'Erro busca do numero da proposta';
     RAISE vr_exc_erro;
   END IF;        
   
   pr_nrctremp := vr_nrctremp;                   
 
 EXCEPTION
   WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
   WHEN OTHERS THEN
     pr_cdcritic := 0;
     pr_dscritic := 'Erro geral no programa: ' || SQLERRM;
   
 END pc_gera_numero_proposta;
  

END EMPR0012;
/
