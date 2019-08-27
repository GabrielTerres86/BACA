CREATE OR REPLACE PACKAGE CECRED.tela_atenda_cobran IS

	PROCEDURE pc_grava_auxiliar_crapceb(pr_cdcooper IN  crapceb.cdcooper%TYPE
																		 ,pr_nrdconta IN  crapceb.nrdconta%TYPE
																		 ,pr_nrconven IN  crapceb.nrconven%TYPE
																		 ,pr_nrcnvceb IN  crapceb.nrcnvceb%TYPE
																		 ,pr_insitceb IN  crapceb.insitceb%TYPE
																		 ,pr_dscritic OUT VARCHAR2
																		 );
	--
	PROCEDURE pc_grava_principal_crapceb(pr_cdcooper IN  crapceb.cdcooper%TYPE
                                      ,pr_nrdconta IN  crapceb.nrdconta%TYPE
                                      ,pr_nrconven IN  crapceb.nrconven%TYPE
                                      ,pr_nrcnvceb IN  crapceb.nrcnvceb%TYPE
                                      ,pr_insitceb IN  crapceb.insitceb%TYPE
                                      ,pr_dscritic OUT VARCHAR2
                                      );
	--
    PROCEDURE pc_busca_apuracao(pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                               ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                               ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE --> Convenio CECRED
                               ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_exclui_convenio(pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                                ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                                ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE --> Convenio CECRED
                                ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_valida_habilitacao(pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                                   ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_valida_dados_limite(pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                                    ,pr_dsorgarq IN crapcco.dsorgarq%TYPE --> Origem Arquivo
                                    ,pr_inarqcbr IN crapceb.inarqcbr%TYPE --> Recebe Arquivo de Retorno de Cobranca
                                    ,pr_cddemail IN crapceb.cddemail%TYPE --> Email Arquivo de Retorno de Cobranca
                                    ,pr_idseqttl IN crapcem.idseqttl%TYPE --> Sequencia do titular
                                    ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_habilita_convenio(pr_nrdconta    IN crapceb.nrdconta%TYPE --> Conta
                                  ,pr_nrconven    IN crapceb.nrconven%TYPE --> Convenio
                                  ,pr_insitceb    IN crapceb.insitceb%TYPE --> Situacao do Convenio
                                  ,pr_inarqcbr    IN crapceb.inarqcbr%TYPE --> Recebe Arquivo Retorno
                                  ,pr_cddemail    IN crapceb.cddemail%TYPE --> Email Arquivo de Retorno
                                  ,pr_flgcruni    IN crapceb.flgcruni%TYPE --> Credito Unificado
                                  ,pr_flgcebhm    IN crapceb.flgcebhm%TYPE --> Contem o convenio homologado
                                  ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Sequencia Titular
                                  ,pr_flgregon    IN crapceb.flgregon%TYPE --> Flag de registro de titulo online (0-Nao/1-Sim)
                                  ,pr_flgpgdiv    IN crapceb.flgpgdiv%TYPE --> Flag de autorizacao de pagamento divergente (0-Nao/ 1-Sim)
                                  ,pr_flcooexp    IN crapceb.flcooexp%TYPE --> Cooperado Emite e Expede Boletos
                                  ,pr_flceeexp    IN crapceb.flceeexp%TYPE --> Cooperativa Emite e Expede Boletos
                                  ,pr_flserasa    IN crapceb.flserasa%TYPE --> Pode negativar no Serasa
                                  ,pr_qtdfloat    IN crapceb.qtdfloat%TYPE --> Quantidade de dias para o Float
                                  ,pr_flprotes    IN crapceb.flprotes%TYPE --> Liberacao da opcao de Protesto na Cobranca
                                  ,pr_insrvprt    IN crapceb.insrvprt%TYPE --> Serviço de Protesto
                                  ,pr_qtlimaxp    IN crapceb.qtlimaxp%TYPE --> Limite a maximo de dias para pode protestar
                                  ,pr_qtlimmip    IN crapceb.qtlimmip%TYPE --> Quantidade de dias para poder protestar
                                  ,pr_qtdecprz    IN crapceb.qtdecprz%TYPE --> Quantidade de dias para Decurso de Prazo
                                  ,pr_idrecipr    IN crapceb.idrecipr%TYPE --> ID unico do calculo de reciprocidade atrelado a contratacao
                                  ,pr_idreciprold IN crapceb.idrecipr%TYPE --> ID unico do calculo de reciprocidade atrelado a contratacao
                                  ,pr_perdesconto IN VARCHAR2 --> Categoria e valor do desconto
                                  ,pr_inenvcob    IN crapceb.inenvcob%TYPE --> Forma de envio de arquivo de cobrança                                
								  ,pr_flgapihm    IN crapceb.flgapihm%TYPE --> Flag representando o uso da API
                                  ,pr_blnewreg    IN BOOLEAN --> Identifica se é um novo registro
                                  ,pr_retxml      IN xmltype --> Arquivo de retorno do XML
                                   -- OUT
                                  ,pr_flgimpri OUT INTEGER --> Deve imprimir?
                                  ,pr_dsdmesag OUT VARCHAR2 --> Mensagens do processo 
                                  ,pr_des_erro OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_habilita_convenio_web(pr_nrdconta    IN crapceb.nrdconta%TYPE --> Conta
                                      ,pr_nrconven    IN crapceb.nrconven%TYPE --> Convenio
                                      ,pr_insitceb    IN crapceb.insitceb%TYPE --> Situacao do Convenio
                                      ,pr_inarqcbr    IN crapceb.inarqcbr%TYPE --> Recebe Arquivo Retorno
                                      ,pr_cddemail    IN crapceb.cddemail%TYPE --> Email Arquivo de Retorno
                                      ,pr_flgcruni    IN crapceb.flgcruni%TYPE --> Credito Unificado
                                      ,pr_flgcebhm    IN crapceb.flgcebhm%TYPE --> Contem o convenio homologado
                                      ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Sequencia Titular
                                      ,pr_flgregon    IN crapceb.flgregon%TYPE --> Flag de registro de titulo online (0-Nao/1-Sim)
                                      ,pr_flgpgdiv    IN crapceb.flgpgdiv%TYPE --> Flag de autorizacao de pagamento divergente (0-Nao/ 1-Sim)
                                      ,pr_flcooexp    IN crapceb.flcooexp%TYPE --> Cooperado Emite e Expede Boletos
                                      ,pr_flceeexp    IN crapceb.flceeexp%TYPE --> Cooperativa Emite e Expede Boletos
                                      ,pr_flserasa    IN crapceb.flserasa%TYPE --> Pode negativar no Serasa
                                      ,pr_qtdfloat    IN crapceb.qtdfloat%TYPE --> Quantidade de dias para o Float
                                      ,pr_flprotes    IN crapceb.flprotes%TYPE --> Liberacao da opcao de Protesto na Cobranca
                                      ,pr_insrvprt    IN crapceb.insrvprt%TYPE --> Serviço de Protesto
                                      ,pr_qtlimaxp    IN crapceb.qtlimaxp%TYPE --> Limite a maximo de dias para pode protestar
                                      ,pr_qtlimmip    IN crapceb.qtlimmip%TYPE --> Quantidade de dias para poder protestar
                                      ,pr_qtdecprz    IN crapceb.qtdecprz%TYPE --> Quantidade de dias para Decurso de Prazo
                                      ,pr_idrecipr    IN crapceb.idrecipr%TYPE --> ID unico do calculo de reciprocidade atrelado a contratacao
                                      ,pr_idreciprold IN crapceb.idrecipr%TYPE --> ID unico do calculo de reciprocidade atrelado a contratacao
                                      ,pr_perdesconto IN VARCHAR2 --> Categoria e valor do desconto
                                      ,pr_inenvcob    IN crapceb.inenvcob%TYPE --> Forma de envio de arquivo de cobrança                                
									  ,pr_flgapihm    IN crapceb.flgapihm%TYPE --> Flag representando o uso da API
                                      ,pr_xmllog      IN VARCHAR2 --> XML com informacoes de LOG
                                      ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                                      ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                                      ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_busca_config_conv(pr_nrconven IN crapcco.nrconven%TYPE --> Convenio
                                  ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_busca_categoria(pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                                ,pr_nrconven IN crapcco.nrconven%TYPE --> Convenio
                                ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_busca_tarifa(pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                             ,pr_cdcatego IN crapcat.cdcatego%TYPE --> Convenio
                             ,pr_inpessoa IN craptar.inpessoa%TYPE --> Tipo de pessoa
                             ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                             ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                             ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_verifica_apuracao(pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                                  ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                                  ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_gera_arq_ajuda(pr_xmllog   IN VARCHAR2 --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2); --Erros do processo

    --> Rotina para ativar convenio
    PROCEDURE pc_ativar_convenio(pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                                ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                                ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE --> Ceb
                                ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2); --> Erros do processo

    --> Retornar lista com os log do convenio ceb
    PROCEDURE pc_consulta_log_conv_web(pr_idrecipr IN crapceb.idrecipr%TYPE --> Nr. da Reciprocidade
                                      ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2); --> Erros do processo                               

    PROCEDURE pc_consulta_log_negoc_web(pr_idrecipr crapceb.idrecipr%TYPE --> Nr. da Reciprocidade
                                       ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);

    --> Rotina para cancelar os boletos
    PROCEDURE pc_cancela_boletos(pr_cdcooper IN crapceb.cdcooper%TYPE --> Codigo da cooperativa
                                ,pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                                ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                                ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2); --> Erros do processo   

    --> Rotina para sustar os boletos
    PROCEDURE pc_susta_boletos(pr_cdcooper IN crapceb.cdcooper%TYPE --> Codigo da cooperativa
                              ,pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                              ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_conv_recip_desc(pr_cdcooper IN crapcco.cdcooper%TYPE --> Codigo da Cooperativa
                                ,pr_nrdconta IN crapceb.nrdconta%TYPE --> Numero da Conta
                                ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2 --> Erros do processo
                                 );
    -- PRJ431
    PROCEDURE pc_busca_dominio(pr_nmdominio IN tbcadast_dominio_campo.nmdominio%TYPE --> Nome do domínio
                              ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro  OUT VARCHAR2 --> Erros do processo
                               );

    PROCEDURE pc_consulta_descontos(pr_idcalculo_reciproci IN tbrecip_calculo.idcalculo_reciproci%TYPE
                                   ,pr_cdcooper            IN crapcop.cdcooper%TYPE
                                   ,pr_nrdconta            IN crapass.nrdconta%TYPE
                                   ,pr_xmllog              IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic            OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic            OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml              IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo            OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro            OUT VARCHAR2 --> Erros do processo
                                    );

    PROCEDURE pc_inclui_descontos(pr_cdcooper                IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                 ,pr_nrdconta                IN crapass.nrdconta%TYPE --> Número da conta cooperado
                                 ,pr_ls_convenios            IN VARCHAR2 --> Lista de convênios concatenados por vírg.
                                 ,pr_boletos_liquidados      IN INTEGER --> Qtde. boletos liquidados
                                 ,pr_volume_liquidacao       IN NUMBER --> Volume liquidação
                                 ,pr_qtdfloat                IN INTEGER --> Floating
                                 ,pr_vlaplicacoes            IN NUMBER --> Aplicações
                                 ,pr_vldeposito              IN NUMBER --> Depósito à Vista
                                 ,pr_dtfimcontrato           IN VARCHAR2 --> Data fim do contrato
                                 ,pr_flgdebito_reversao      IN INTEGER --> Débito reajuste da tarifa
                                 ,pr_vldesconto_coo          IN NUMBER --> Valor desconto adicional COO
                                 ,pr_dtfimadicional_coo      IN INTEGER --> Data fim desconto adicional COO
                                 ,pr_vldesconto_cee          IN NUMBER --> Valor desconto adicional CEE
                                 ,pr_dtfimadicional_cee      IN INTEGER --> Data fim desconto adicional CEE
                                 ,pr_txtjustificativa        IN VARCHAR2 --> Justificativa do desconto adicional
                                 ,pr_idvinculacao            IN INTEGER --> Vinculação do cooperado
                                 ,pr_perdesconto             IN VARCHAR2 --> Lista dos descontos de tarifa
                                 ,pr_vldescontoconcedido_coo IN NUMBER --> Valor desconto concedido COO
                                 ,pr_vldescontoconcedido_cee IN NUMBER --> Valor desconto concedido CEE
                                 ,pr_cdoperad                IN crapope.cdoperad%TYPE --> Operador que realizou a operação
                                 ,pr_idcalculo_reciproci     OUT INTEGER --> Código da reciprocidade
                                 ,pr_retxml                  IN xmltype --> Arquivo de retorno do XML
                                 ,pr_des_erro                OUT VARCHAR2 --> Erros do processo
                                  );

    PROCEDURE pc_inclui_descontos_web(pr_cdcooper                IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                     ,pr_nrdconta                IN crapass.nrdconta%TYPE --> Número da conta cooperado
                                     ,pr_ls_convenios            IN VARCHAR2 --> Lista de convênios concatenados por vírg.
                                     ,pr_boletos_liquidados      IN INTEGER --> Qtde. boletos liquidados
                                     ,pr_volume_liquidacao       IN VARCHAR2 --> Volume liquidação
                                     ,pr_qtdfloat                IN INTEGER --> Floating
                                     ,pr_vlaplicacoes            IN VARCHAR2 --> Aplicações
                                     ,pr_vldeposito              IN VARCHAR2 --> Depósito à Vista
                                     ,pr_dtfimcontrato           IN VARCHAR2 --> Data fim do contrato
                                     ,pr_flgdebito_reversao      IN INTEGER --> Débito reajuste da tarifa
                                     ,pr_vldesconto_coo          IN VARCHAR2 --> Valor desconto adicional COO
                                     ,pr_dtfimadicional_coo      IN INTEGER --> Data fim desconto adicional COO
                                     ,pr_vldesconto_cee          IN VARCHAR2 --> Valor desconto adicional CEE
                                     ,pr_dtfimadicional_cee      IN INTEGER --> Data fim desconto adicional CEE
                                     ,pr_txtjustificativa        IN VARCHAR2 --> Justificativa do desconto adicional
                                     ,pr_idvinculacao            IN INTEGER --> Vinculação do cooperado
                                     ,pr_perdesconto             IN VARCHAR2 --> Lista dos descontos de tarifa
                                     ,pr_vldescontoconcedido_coo IN VARCHAR2 --> Valor desconto concedido COO
                                     ,pr_vldescontoconcedido_cee IN VARCHAR2 --> Valor desconto concedido CEE
                                     ,pr_xmllog                  IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic                OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic                OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml                  IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo                OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro                OUT VARCHAR2 --> Erros do processo
                                      );

    PROCEDURE pc_altera_descontos(pr_idcalculo_reciproci     IN tbrecip_calculo.idcalculo_reciproci%TYPE --> Id da reciprocidade
                                 ,pr_cdcooper                IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                 ,pr_nrdconta                IN crapass.nrdconta%TYPE --> Número da conta cooperado
                                 ,pr_ls_convenios            IN VARCHAR2 --> Lista de convênios concatenados por vírg.
                                 ,pr_boletos_liquidados      IN INTEGER --> Qtde. boletos liquidados
                                 ,pr_volume_liquidacao       IN VARCHAR2 --> Volume liquidação
                                 ,pr_qtdfloat                IN INTEGER --> Floating
                                 ,pr_vlaplicacoes            IN VARCHAR2 --> Aplicações
                                 ,pr_vldeposito              IN VARCHAR2 --> Depósito à Vista
                                 ,pr_dtfimcontrato           IN VARCHAR2 --> Data fim do contrato
                                 ,pr_flgdebito_reversao      IN INTEGER --> Débito reajuste da tarifa
                                 ,pr_vldesconto_coo          IN VARCHAR2 --> Valor desconto adicional COO
                                 ,pr_dtfimadicional_coo      IN INTEGER --> Data fim desconto adicional COO
                                 ,pr_vldesconto_cee          IN VARCHAR2 --> Valor desconto adicional CEE
                                 ,pr_dtfimadicional_cee      IN INTEGER --> Data fim desconto adicional CEE
                                 ,pr_txtjustificativa        IN VARCHAR2 --> Justificativa do desconto adicional
                                 ,pr_idvinculacao            IN INTEGER --> Vinculação do cooperado
                                 ,pr_perdesconto             IN VARCHAR2 --> Lista dos descontos de tarifa
                                 ,pr_vldescontoconcedido_coo IN VARCHAR2 --> Valor desconto concedido COO
                                 ,pr_vldescontoconcedido_cee IN VARCHAR2 --> Valor desconto concedido CEE
                                 ,pr_xmllog                  IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic                OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic                OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml                  IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo                OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro                OUT VARCHAR2 --> Erros do processo
                                  );

    PROCEDURE pc_busca_operadores_reg(pr_nmoperad IN crapope.nmoperad%TYPE DEFAULT NULL -->Codigo da opcao
                                     ,pr_nriniseq IN INTEGER -->Quantidade inicial
                                     ,pr_nrregist IN INTEGER -->Quantidade de registros 
                                     ,pr_xmllog   IN VARCHAR2 DEFAULT NULL -->XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER -->Código da crítica
                                     ,pr_dscritic OUT VARCHAR2 -->Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype -->Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 -->Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);

    PROCEDURE pc_valida_exclusao_conven(pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                                       ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                                       ,pr_idrecipr IN crapceb.idrecipr%TYPE --> Id Reciprocidade
                                       ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);

    -- PRJ431
    PROCEDURE pc_busca_contratos(pr_cdcooper crapceb.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta crapceb.nrdconta%TYPE --> Número da conta
                                ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2 --> Erros do processo
                                 );

    PROCEDURE pc_busca_vinculacao(pr_nrdconta IN crapceb.idrecipr%TYPE --> Nr. da Reciprocidade
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);

    PROCEDURE pc_gera_log_conv(pr_cdcooper            IN tbrecip_log_contrato.cdcooper%TYPE --> Código da cooperativa
                              ,pr_idcalculo_reciproci IN tbrecip_log_contrato.idcalculo_reciproci%TYPE --> Código da Reciprocidade
                              ,pr_cdoperador          IN tbrecip_log_contrato.cdoperador%TYPE --> Código do operador
                              ,pr_dshistorico         IN VARCHAR2 --> Descrição do log
                              ,pr_cdcritic            OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic            OUT VARCHAR2 --> Descricao da critica
                               );

    PROCEDURE pc_cancela_descontos(pr_idcalculo_reciproci IN tbrecip_calculo.idcalculo_reciproci%TYPE --> Id da reciprocidade
                                  ,pr_nrdconta            IN crapceb.nrdconta%TYPE --> Numero da conta
                                  ,pr_xmllog              IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic            OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic            OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml              IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo            OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro            OUT VARCHAR2 --> Erros do processo
                                   );
    -- PRJ431
    
    -- Rafael Ferreira Mouts - INC0020100 - Situac 3
    PROCEDURE pc_consulta_convenio(pr_cdcooper    IN crapcop.cdcooper%TYPE
                                   ,pr_nrdconta   IN crapass.nrdconta%TYPE
                                   ,pr_nrconven   IN crapceb.nrconven%TYPE
                                   ,pr_xmllog     IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro   OUT VARCHAR2 --> Erros do processo
                                    );
END tela_atenda_cobran;
/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_atenda_cobran IS
    ---------------------------------------------------------------------------
    --
    --  Programa : TELA_ATENDA_COBRAN
    --  Sistema  : Ayllos Web
    --  Autor    : Jaison Fernando
    --  Data     : Fevereiro - 2016                 Ultima atualizacao: 16/12/2018
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Centralizar rotinas relacionadas a tela Cobranca dentro da ATENDA
    --
    -- Alteracoes: 04/08/2016 - Adicionado parametro pr_inenvcob na procedure 
    --              pc_habilita_convenio (Reinert).
    --
    --             14/09/2016 - Adicionado validacao de convenio ativo na procedure
    --                          pc_habilita_convenio (Douglas - Chamado 502770)
    -- 
    --             25/11/2016 - Alterado cursor cr_crapope, para ler o departamento
    --                          do operador a partir da tabela CRAPDPO. O setor de 
    --                          COBRANCA foi removido da validação, pois o mesmo não 
    --                          existe na CRAPDPO (Renato Darosci - Supero)
	--
		--             16/12/2018 - Ajustar o sistema para trabalhar com a CRAPCEB 
		--                          juntamente com uma tabela auxiliar, mantendo sempre o 
		--                          registro aprovado mais atual na tabela CRAPCEB 
		--                          (SM431 - Adriano Nagasava - Supero)
		--
	--             18/12/2018 - Correção na habilitação do convênio para inclusão na CIP
    --                          (Andre Clemer - Supero)
		--
	--             16/05/2019 - Correção no cursor principal das procedures
	--                          pc_cancela_boletos e pc_susta_boletos
	--                          para só selecionar boletos que estão em protesto
	--                          e não os que estão no SERASA
    --                          (Roberto Holz - Mout´s)
		--
    ---------------------------------------------------------------------------

    -- Busca dos valores do contrato
    CURSOR cr_info_desconto(pr_idcalculo_reciproci tbrecip_calculo.idcalculo_reciproci%TYPE
                           ,pr_cdoperad            tbrecip_aprovador_calculo.cdoperador%TYPE) IS
        SELECT cal.flgdebito_reversao
              ,cal.qtdmes_retorno_reciproci
              ,ceb.qtdfloat
              ,cal.vldesconto_adicional_coo
              ,cal.idfim_desc_adicional_coo
              ,cal.vldesconto_adicional_cee
              ,cal.idfim_desc_adicional_cee
              ,cal.dsjustificativa_desc_adic
              ,ceb.insitceb
              ,cal.idvinculacao
              ,cal.vldesconto_concedido_coo
              ,cal.vldesconto_concedido_cee
              ,vin.nmvinculacao
              ,(SELECT COUNT(apr.idcalculo_reciproci)
                  FROM tbrecip_aprovador_calculo apr
                 WHERE apr.idcalculo_reciproci = ceb.idrecipr) qtdaprov
              ,(SELECT COUNT(apr.idcalculo_reciproci)
                  FROM tbrecip_aprovador_calculo apr
                 WHERE apr.idcalculo_reciproci = ceb.idrecipr
                   AND apr.cdoperador = pr_cdoperad
                    OR pr_cdoperad = NULL) insitapr
          FROM tbrecip_calculo    cal
              ,crapceb            ceb
              ,tbrecip_vinculacao vin
         WHERE ceb.idrecipr = cal.idcalculo_reciproci(+)
           AND cal.idcalculo_reciproci = pr_idcalculo_reciproci
           AND vin.idvinculacao (+) = cal.idvinculacao
				 UNION ALL
				SELECT cal.flgdebito_reversao
              ,cal.qtdmes_retorno_reciproci
              ,ceb.qtdfloat
              ,cal.vldesconto_adicional_coo
              ,cal.idfim_desc_adicional_coo
              ,cal.vldesconto_adicional_cee
              ,cal.idfim_desc_adicional_cee
              ,cal.dsjustificativa_desc_adic
              ,ceb.insitceb
              ,cal.idvinculacao
              ,cal.vldesconto_concedido_coo
              ,cal.vldesconto_concedido_cee
              ,vin.nmvinculacao
              ,(SELECT COUNT(apr.idcalculo_reciproci)
                  FROM tbrecip_aprovador_calculo apr
                 WHERE apr.idcalculo_reciproci = ceb.idrecipr) qtdaprov
              ,(SELECT COUNT(apr.idcalculo_reciproci)
                  FROM tbrecip_aprovador_calculo apr
                 WHERE apr.idcalculo_reciproci = ceb.idrecipr
                   AND apr.cdoperador = pr_cdoperad
                    OR pr_cdoperad = NULL) insitapr
          FROM tbrecip_calculo    cal
              ,tbcobran_crapceb            ceb
              ,tbrecip_vinculacao vin
         WHERE ceb.idrecipr = cal.idcalculo_reciproci(+)
           AND cal.idcalculo_reciproci = pr_idcalculo_reciproci
           AND vin.idvinculacao (+) = cal.idvinculacao;
    rw_info_desconto cr_info_desconto%ROWTYPE;

    -- Busca dos convenios do contrato
    CURSOR cr_convenios(pr_cdcooper            crapceb.cdcooper%TYPE
                       ,pr_idcalculo_reciproci tbrecip_calculo.idcalculo_reciproci%TYPE
                       ,pr_nrdconta            crapass.nrdconta%TYPE) IS
    
        SELECT crapceb.nrconven
              ,crapcco.dsorgarq
              ,crapceb.insitceb
              ,crapceb.flgregon
              ,crapceb.flgpgdiv
              ,crapceb.flcooexp
              ,crapceb.flceeexp
              ,crapceb.qtdfloat
              ,crapceb.flserasa
              ,crapceb.flprotes
              ,crapceb.insrvprt
              ,crapceb.qtlimmip
              ,crapceb.qtlimaxp
              ,crapceb.qtdecprz
              ,crapceb.inarqcbr
              ,crapceb.inenvcob
              ,crapceb.cddemail
              ,crapceb.flgcebhm
              ,crapceb.flgapihm
              ,(SELECT COUNT(1)
                  FROM crapcob
                 WHERE crapcob.cdcooper = pr_cdcooper
                   AND crapcob.nrdconta = pr_nrdconta
                   AND crapcob.nrcnvcob = crapceb.nrconven) AS qtbolcob
          FROM crapceb
              ,crapcco
         WHERE crapcco.cdcooper = crapceb.cdcooper
           AND crapcco.nrconven = crapceb.nrconven
           AND crapceb.idrecipr = pr_idcalculo_reciproci
           AND crapceb.cdcooper = pr_cdcooper
           AND nrdconta         = pr_nrdconta
				 UNION ALL
				SELECT crapceb.nrconven
              ,crapcco.dsorgarq
              ,crapceb.insitceb
              ,crapceb.flgregon
              ,crapceb.flgpgdiv
              ,crapceb.flcooexp
              ,crapceb.flceeexp
              ,crapceb.qtdfloat
              ,crapceb.flserasa
              ,crapceb.flprotes
              ,crapceb.insrvprt
              ,crapceb.qtlimmip
              ,crapceb.qtlimaxp
              ,crapceb.qtdecprz
              ,crapceb.inarqcbr
              ,crapceb.inenvcob
              ,crapceb.cddemail
              ,crapceb.flgcebhm
              ,crapceb.flgapihm
              ,(SELECT COUNT(1)
                  FROM crapcob
                 WHERE crapcob.cdcooper = pr_cdcooper
                   AND crapcob.nrdconta = pr_nrdconta
                   AND crapcob.nrcnvcob = crapceb.nrconven) AS qtbolcob
          FROM tbcobran_crapceb crapceb
              ,crapcco
         WHERE crapcco.cdcooper = crapceb.cdcooper
           AND crapcco.nrconven = crapceb.nrconven
           AND crapceb.idrecipr = pr_idcalculo_reciproci
           AND crapceb.cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
    rw_convenios cr_convenios%ROWTYPE;
    --
		FUNCTION fn_nova_reciprocidade(pr_cdcooper IN  crapceb.cdcooper%TYPE
			                            ) RETURN BOOLEAN IS
		  --
			vr_qt_reg NUMBER;
			--
		BEGIN
			--
			SELECT COUNT(1)
			  INTO vr_qt_reg
				FROM crapprm prm
			 WHERE prm.cdacesso = 'RECIPROCIDADE_PILOTO'
			   AND prm.cdcooper = pr_cdcooper;
			--
			IF nvl(vr_qt_reg, 0) > 0 THEN
				--
				RETURN TRUE;
				--
			ELSE
				--
				RETURN FALSE;
				--
			END IF;
			--
		END fn_nova_reciprocidade;
		--
		PROCEDURE pc_grava_auxiliar_crapceb(pr_cdcooper IN  crapceb.cdcooper%TYPE
                                       ,pr_nrdconta IN  crapceb.nrdconta%TYPE
                                       ,pr_nrconven IN  crapceb.nrconven%TYPE
                                       ,pr_nrcnvceb IN  crapceb.nrcnvceb%TYPE
                                       ,pr_insitceb IN  crapceb.insitceb%TYPE
                                       ,pr_dscritic OUT VARCHAR2
                                       ) IS
     /* ................................................................................................
        
        Programa: pc_grava_auxiliar_crapceb
        Sistema : Ayllos Web
        Autor   : Adriano Nagasava (Supero)
        Data    : Dezembro/2018                 Ultima atualizacao: 
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para gerar o registro na tbcobran_crapceb.
        
        Alteracoes: 
        .................................................................................................*/
      --
      CURSOR cr_crapceb(pr_cdcooper crapceb.cdcooper%TYPE
                       ,pr_nrdconta crapceb.nrdconta%TYPE
                       ,pr_nrconven crapceb.nrconven%TYPE
                       ,pr_nrcnvceb crapceb.nrcnvceb%TYPE
                       ) IS
        SELECT crapceb.cdcooper
              ,crapceb.nrdconta
              ,crapceb.nrconven
              ,crapceb.nrcnvceb
              ,crapceb.dtcadast
              ,crapceb.cdoperad
              ,crapceb.insitceb
              ,crapceb.inarqcbr
              ,crapceb.cddemail
              ,crapceb.flgcruni
              ,crapceb.flgcebhm
              ,crapceb.flgapihm
              ,crapceb.progress_recid
              ,crapceb.cdhomolo
              ,crapceb.flcooexp
              ,crapceb.flceeexp
              ,crapceb.flserasa
              ,crapceb.cdopeori
              ,crapceb.cdageori
              ,crapceb.dtinsori
              ,crapceb.cdopeexc
              ,crapceb.cdageexc
              ,crapceb.dtinsexc
              ,crapceb.flprotes
              ,crapceb.qtdecprz
              ,crapceb.qtdfloat
              ,crapceb.idrecipr
              ,crapceb.dhanalis
              ,crapceb.cdopeana
              ,crapceb.inenvcob
              ,crapceb.flgregon
              ,crapceb.flgpgdiv
              ,crapceb.qtlimaxp
              ,crapceb.qtlimmip
              ,crapceb.insrvprt
              ,crapceb.flgdigit
              ,crapceb.fltercan
              ,crapceb.cdhomapi
              ,crapceb.dhhomapi
              ,crapceb.rowid
					FROM crapceb
				 WHERE cdcooper = pr_cdcooper
					 AND nrdconta = pr_nrdconta
					 AND nrconven = pr_nrconven
					 AND nrcnvceb = pr_nrcnvceb
					 AND insitceb NOT IN(1, 5)
					 /*AND nrconven IN(SELECT nrconven
														 FROM crapcco
														WHERE cdcooper = pr_cdcooper
															AND flgativo = 1
															AND flrecipr = 1
															AND dsorgarq <> 'PROTESTO')*/;
			--
			rw_crapceb cr_crapceb%ROWTYPE;
			-- Tratamento de erros
      vr_exc_saida EXCEPTION;
			--
		BEGIN
			--
			OPEN cr_crapceb(pr_cdcooper
										 ,pr_nrdconta
										 ,pr_nrconven
										 ,pr_nrcnvceb
										 );
			--
			LOOP
				--
				FETCH cr_crapceb INTO rw_crapceb;
				EXIT WHEN cr_crapceb%NOTFOUND;
				-- Insere o registro na auxiliar
				BEGIN
					--
					INSERT INTO tbcobran_crapceb(cdcooper
																			,nrdconta
																			,nrconven
																			,nrcnvceb
																			,dtcadast
																			,cdoperad
																			,insitceb
																			,inarqcbr
																			,cddemail
																			,flgcruni
																			,flgcebhm
                                                                                                                                                        ,flgapihm
																			,cdhomolo
																			,flcooexp
																			,flceeexp
																			,flserasa
																			,cdopeori
																			,cdageori
																			,dtinsori
																			,cdopeexc
																			,cdageexc
																			,dtinsexc
																			,flprotes
																			,qtdecprz
																			,qtdfloat
																			,idrecipr
																			,dhanalis
																			,cdopeana
																			,inenvcob
																			,flgregon
																			,flgpgdiv
																			,qtlimaxp
																			,qtlimmip
																			,insrvprt
																			,flgdigit
																			,fltercan
															                                ,cdhomapi
															                                ,dhhomapi
																			)
																VALUES(rw_crapceb.cdcooper -- cdcooper
																			,rw_crapceb.nrdconta -- nrdconta
																			,rw_crapceb.nrconven -- nrconven
																			,rw_crapceb.nrcnvceb -- nrcnvceb
																			,rw_crapceb.dtcadast -- dtcadast
																			,rw_crapceb.cdoperad -- cdoperad
																			,nvl(pr_insitceb
																			    ,rw_crapceb.insitceb) -- insitceb
																			,rw_crapceb.inarqcbr -- inarqcbr
																			,rw_crapceb.cddemail -- cddemail
																			,rw_crapceb.flgcruni -- flgcruni
																			,rw_crapceb.flgcebhm -- flgcebhm
                                                                                                                                                        ,rw_crapceb.flgapihm -- flgapihm
																			,rw_crapceb.cdhomolo -- cdhomolo
																			,rw_crapceb.flcooexp -- flcooexp
																			,rw_crapceb.flceeexp -- flceeexp
																			,rw_crapceb.flserasa -- flserasa
																			,rw_crapceb.cdopeori -- cdopeori
																			,rw_crapceb.cdageori -- cdageori
																			,SYSDATE             -- dtinsori
																			,rw_crapceb.cdopeexc -- cdopeexc
																			,rw_crapceb.cdageexc -- cdageexc
																			,rw_crapceb.dtinsexc -- dtinsexc
																			,rw_crapceb.flprotes -- flprotes
																			,rw_crapceb.qtdecprz -- qtdecprz
																			,rw_crapceb.qtdfloat -- qtdfloat
																			,rw_crapceb.idrecipr -- idrecipr
																			,rw_crapceb.dhanalis -- dhanalis
																			,rw_crapceb.cdopeana -- cdopeana
																			,rw_crapceb.inenvcob -- inenvcob
																			,rw_crapceb.flgregon -- flgregon
																			,rw_crapceb.flgpgdiv -- flgpgdiv
																			,rw_crapceb.qtlimaxp -- qtlimaxp
																			,rw_crapceb.qtlimmip -- qtlimmip
																			,rw_crapceb.insrvprt -- insrvprt
																			,rw_crapceb.flgdigit -- flgdigit
																			,rw_crapceb.fltercan -- fltercan
														                                        ,rw_crapceb.cdhomapi
														                                        ,rw_crapceb.dhhomapi
																			);
					--
				EXCEPTION
					WHEN OTHERS THEN
						pr_dscritic := 'Erro ao inserir o registro na TBCOBRAN_CRAPCEB: ' || SQLERRM;
						RAISE vr_exc_saida;
				END;
				-- Exclui o registro da CRAPCEB
				BEGIN
					--
					DELETE FROM crapceb
					      WHERE crapceb.rowid = rw_crapceb.rowid;
					--
				EXCEPTION
					WHEN OTHERS THEN
						pr_dscritic := 'Erro ao excluir o registro na CRAPCEB: ' || SQLERRM;
						RAISE vr_exc_saida;
				END;
				--
			END LOOP;
			--
			CLOSE cr_crapceb;
			--
		EXCEPTION
			WHEN vr_exc_saida THEN
				CLOSE cr_crapceb;
			WHEN OTHERS THEN
				CLOSE cr_crapceb;
				pr_dscritic := 'Erro na pc_grava_auxiliar_crapceb: ' || SQLERRM;
		END pc_grava_auxiliar_crapceb;
		--
		PROCEDURE pc_grava_principal_crapceb(pr_cdcooper IN  crapceb.cdcooper%TYPE
                                       ,pr_nrdconta IN  crapceb.nrdconta%TYPE
                                       ,pr_nrconven IN  crapceb.nrconven%TYPE
                                       ,pr_nrcnvceb IN  crapceb.nrcnvceb%TYPE
                                       ,pr_insitceb IN  crapceb.insitceb%TYPE
                                       ,pr_dscritic OUT VARCHAR2
                                       ) IS
     /* ................................................................................................
        
        Programa: pc_grava_principal_crapceb
        Sistema : Ayllos Web
        Autor   : Adriano Nagasava (Supero)
        Data    : Dezembro/2018                 Ultima atualizacao: 
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para gerar o registro na crapceb.
        
        Alteracoes: 
        .................................................................................................*/
      --
      CURSOR cr_crapceb(pr_cdcooper crapceb.cdcooper%TYPE
                       ,pr_nrdconta crapceb.nrdconta%TYPE
                       ,pr_nrconven crapceb.nrconven%TYPE
                       ,pr_nrcnvceb crapceb.nrcnvceb%TYPE
                       ) IS
        SELECT crapceb.cdcooper
              ,crapceb.nrdconta
              ,crapceb.nrconven
              ,crapceb.nrcnvceb
              ,crapceb.dtcadast
              ,crapceb.cdoperad
              ,crapceb.insitceb
              ,crapceb.inarqcbr
              ,crapceb.cddemail
              ,crapceb.flgcruni
              ,crapceb.flgcebhm
              ,crapceb.flgapihm
              ,NULL
              ,crapceb.cdhomolo
              ,crapceb.flcooexp
              ,crapceb.flceeexp
              ,crapceb.flserasa
              ,crapceb.cdopeori
              ,crapceb.cdageori
              ,crapceb.dtinsori
              ,crapceb.cdopeexc
              ,crapceb.cdageexc
              ,crapceb.dtinsexc
              ,crapceb.flprotes
              ,crapceb.qtdecprz
              ,crapceb.qtdfloat
              ,crapceb.idrecipr
              ,crapceb.dhanalis
              ,crapceb.cdopeana
              ,crapceb.inenvcob
              ,crapceb.flgregon
              ,crapceb.flgpgdiv
              ,crapceb.qtlimaxp
              ,crapceb.qtlimmip
              ,crapceb.insrvprt
              ,crapceb.flgdigit
              ,crapceb.fltercan
              ,crapceb.cdhomapi
              ,crapceb.dhhomapi
              ,crapceb.rowid
					FROM tbcobran_crapceb crapceb
				 WHERE cdcooper = pr_cdcooper
					 AND nrdconta = pr_nrdconta
					 AND nrconven = pr_nrconven
					 AND nrcnvceb = pr_nrcnvceb
					 AND insitceb IN(1, 5)
					 AND nrconven IN(SELECT nrconven
														 FROM crapcco
														WHERE cdcooper = pr_cdcooper
															AND flgativo = 1
															AND flrecipr = 1
															AND dsorgarq <> 'PROTESTO');
			--
			rw_crapceb cr_crapceb%ROWTYPE;
			-- Tratamento de erros
      vr_exc_saida EXCEPTION;
			--
		BEGIN
			--
			pc_grava_auxiliar_crapceb(pr_cdcooper => pr_cdcooper -- IN
															 ,pr_nrdconta => pr_nrdconta -- IN
															 ,pr_nrconven => pr_nrconven -- IN
															 ,pr_nrcnvceb => pr_nrcnvceb -- IN
															 ,pr_insitceb => NULL        -- IN
															 ,pr_dscritic => pr_dscritic -- OUT
															 );
			--
			IF pr_dscritic IS NOT NULL THEN
				--
				RAISE vr_exc_saida;
				--
			END IF;
			--
			OPEN cr_crapceb(pr_cdcooper
										 ,pr_nrdconta
										 ,pr_nrconven
										 ,pr_nrcnvceb
										 );
			--
			LOOP
				--
				FETCH cr_crapceb INTO rw_crapceb;
				EXIT WHEN cr_crapceb%NOTFOUND;
				-- Insere o registro na auxiliar
				BEGIN
					--
					INSERT INTO crapceb(cdcooper
														 ,nrdconta
														 ,nrconven
														 ,nrcnvceb
														 ,dtcadast
														 ,cdoperad
														 ,insitceb
														 ,inarqcbr
														 ,cddemail
														 ,flgcruni
														 ,flgcebhm
                                                                                                                 ,flgapihm
														 ,cdhomolo
														 ,flcooexp
														 ,flceeexp
														 ,flserasa
														 ,cdopeori
														 ,cdageori
														 ,dtinsori
														 ,cdopeexc
														 ,cdageexc
														 ,dtinsexc
														 ,flprotes
														 ,qtdecprz
														 ,qtdfloat
														 ,idrecipr
														 ,dhanalis
														 ,cdopeana
														 ,inenvcob
														 ,flgregon
														 ,flgpgdiv
														 ,qtlimaxp
														 ,qtlimmip
														 ,insrvprt
														 ,flgdigit
														 ,fltercan
											                         ,cdhomapi
											                         ,dhhomapi
														 )
											 VALUES(rw_crapceb.cdcooper -- cdcooper
														 ,rw_crapceb.nrdconta -- nrdconta
														 ,rw_crapceb.nrconven -- nrconven
														 ,rw_crapceb.nrcnvceb -- nrcnvceb
														 ,rw_crapceb.dtcadast -- dtcadast
														 ,rw_crapceb.cdoperad -- cdoperad
														 ,nvl(pr_insitceb
														 		 ,rw_crapceb.insitceb) -- insitceb
														 ,rw_crapceb.inarqcbr -- inarqcbr
														 ,rw_crapceb.cddemail -- cddemail
														 ,rw_crapceb.flgcruni -- flgcruni
														 ,rw_crapceb.flgcebhm -- flgcebhm
                                                                                                                 ,rw_crapceb.flgapihm -- flgapihm
														 ,rw_crapceb.cdhomolo -- cdhomolo
														 ,rw_crapceb.flcooexp -- flcooexp
														 ,rw_crapceb.flceeexp -- flceeexp
														 ,rw_crapceb.flserasa -- flserasa
														 ,rw_crapceb.cdopeori -- cdopeori
														 ,rw_crapceb.cdageori -- cdageori
														 ,rw_crapceb.dtinsori -- dtinsori
														 ,rw_crapceb.cdopeexc -- cdopeexc
														 ,rw_crapceb.cdageexc -- cdageexc
														 ,rw_crapceb.dtinsexc -- dtinsexc
														 ,rw_crapceb.flprotes -- flprotes
														 ,rw_crapceb.qtdecprz -- qtdecprz
														 ,rw_crapceb.qtdfloat -- qtdfloat
														 ,rw_crapceb.idrecipr -- idrecipr
														 ,rw_crapceb.dhanalis -- dhanalis
														 ,rw_crapceb.cdopeana -- cdopeana
														 ,rw_crapceb.inenvcob -- inenvcob
														 ,rw_crapceb.flgregon -- flgregon
														 ,rw_crapceb.flgpgdiv -- flgpgdiv
														 ,rw_crapceb.qtlimaxp -- qtlimaxp
														 ,rw_crapceb.qtlimmip -- qtlimmip
														 ,rw_crapceb.insrvprt -- insrvprt
														 ,rw_crapceb.flgdigit -- flgdigit
														 ,rw_crapceb.fltercan -- fltercan
											                         ,rw_crapceb.cdhomapi
											                         ,rw_crapceb.dhhomapi
														 );
					--
				EXCEPTION
					WHEN OTHERS THEN
						pr_dscritic := 'Erro ao inserir o registro na CRAPCEB: ' || SQLERRM;
						RAISE vr_exc_saida;
				END;
				-- Exclui o registro da TBCOBRAN_CRAPCEB
				BEGIN
					--
					DELETE FROM tbcobran_crapceb crapceb
					      WHERE crapceb.rowid = rw_crapceb.rowid;
					--
				EXCEPTION
					WHEN OTHERS THEN
						pr_dscritic := 'Erro ao excluir o registro na TBCOBRAN_CRAPCEB: ' || SQLERRM;
						RAISE vr_exc_saida;
				END;
				--
			END LOOP;
			--
			CLOSE cr_crapceb;
			--
		EXCEPTION
			WHEN vr_exc_saida THEN
				CLOSE cr_crapceb;
			WHEN OTHERS THEN
				CLOSE cr_crapceb;
				pr_dscritic := 'Erro na pc_grava_principal_crapceb: ' || SQLERRM;
		END pc_grava_principal_crapceb;
		--
    PROCEDURE pc_busca_apuracao(pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                               ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                               ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE --> Convenio CECRED
                               ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_busca_apuracao
        Sistema : Ayllos Web
        Autor   : Jaison Fernando
        Data    : Fevereiro/2016                 Ultima atualizacao: 
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para alertar em caso de periodo de apuracao de reciprocidade em aberto.
        
        Alteracoes: 
        ..............................................................................*/
    
        DECLARE
        
            -- Verifica se possui reciprocidade
            CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                             ,pr_nrdconta IN crapceb.nrdconta%TYPE
                             ,pr_nrconven IN crapceb.nrconven%TYPE
                             ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE) IS
                SELECT nvl(crapceb.idrecipr, 0)
                  FROM crapceb
                 WHERE crapceb.cdcooper = pr_cdcooper
                   AND crapceb.nrdconta = pr_nrdconta
                   AND crapceb.nrconven = pr_nrconven
                   AND crapceb.nrcnvceb = pr_nrcnvceb
								 UNION ALL
								SELECT nvl(crapceb.idrecipr, 0)
                  FROM tbcobran_crapceb crapceb
                 WHERE crapceb.cdcooper = pr_cdcooper
                   AND crapceb.nrdconta = pr_nrdconta
                   AND crapceb.nrconven = pr_nrconven
                   AND crapceb.nrcnvceb = pr_nrcnvceb;
        
            -- Verifica se possui apuracao em aberto
            CURSOR cr_apuracao(pr_cdcooper IN crapceb.cdcooper%TYPE
                              ,pr_nrdconta IN crapceb.nrdconta%TYPE
                              ,pr_nrconven IN crapceb.nrconven%TYPE) IS
                SELECT COUNT(1)
                  FROM tbrecip_apuracao apr
                 WHERE indsituacao_apuracao = 'A' -- Em apuracao
                   AND apr.cdcooper = pr_cdcooper
                   AND apr.nrdconta = pr_nrdconta
                   AND apr.cdchave_produto = pr_nrconven
                   AND apr.cdproduto = 6; -- Cobranca
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
        
            -- Variaveis
            vr_idrecipr crapceb.idrecipr%TYPE;
            vr_qtapurac NUMBER;
        
            -- Variaveis de log
            vr_cdcooper INTEGER;
            vr_cdoperad VARCHAR2(100);
            vr_nmdatela VARCHAR2(100);
            vr_nmeacao  VARCHAR2(100);
            vr_cdagenci VARCHAR2(100);
            vr_nrdcaixa VARCHAR2(100);
            vr_idorigem VARCHAR2(100);
        
        BEGIN
            -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_nmeacao  => vr_nmeacao
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
            -- Verifica se possui reciprocidade
            OPEN cr_crapceb(pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrconven => pr_nrconven
                           ,pr_nrcnvceb => pr_nrcnvceb);
            FETCH cr_crapceb
                INTO vr_idrecipr;
            -- Fecha cursor
            CLOSE cr_crapceb;
        
            -- Se possui reciprocidade
            IF vr_idrecipr > 0 THEN
            
                -- Verifica se possui apuracao em aberto
                OPEN cr_apuracao(pr_cdcooper => vr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrconven => pr_nrconven);
                FETCH cr_apuracao
                    INTO vr_qtapurac;
                -- Fecha cursor
                CLOSE cr_apuracao;
            
                -- Se possui apuracao em aberto
                IF vr_qtapurac > 0 THEN
                    vr_dscritic := 'Atenção: Existe Reciprocidade em apuração para o convênio, os descontos concedidos não poderão ser revertidos se você cancelar o convênio!';
                    RAISE vr_exc_saida;
                END IF;
            
            END IF;
        
        EXCEPTION
            WHEN vr_exc_saida THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
            
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;
            
                -- Carregar XML padrão para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
            
        END;
    
    END pc_busca_apuracao;

    PROCEDURE pc_exclui_convenio(pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                                ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                                ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE --> Convenio CECRED
                                ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_exclui_convenio             Antigo: b1wgen0082.p/exclui-convenio
        Sistema : Ayllos Web
        Autor   : Jaison Fernando
        Data    : Fevereiro/2016                 Ultima atualizacao: 08/12/2017
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para excluir o convenio.
        
        Alteracoes: 25/04/2016 - Atualizar convenio na cabine e gerar log cip
                                 PRJ318 Plataforma cobrança (Odirlei-AMcom)
                              
                    08/12/2017 - Inclusão de chamada da npcb0002.pc_libera_sessao_sqlserver_npc
                                 (SD#791193 - AJFink)
        
        ..............................................................................*/
        DECLARE
        
            -- Verifica se possui boletos
            CURSOR cr_crapcob(pr_cdcooper IN crapcob.cdcooper%TYPE
                             ,pr_nrdconta IN crapcob.nrdconta%TYPE
                             ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE) IS
                SELECT COUNT(1)
                  FROM crapcob
                 WHERE crapcob.cdcooper = pr_cdcooper
                   AND crapcob.nrdconta = pr_nrdconta
                   AND crapcob.nrcnvcob = pr_nrcnvcob;
        
            -- Busca o cadastro de convenio
            CURSOR cr_crapcco(pr_cdcooper IN crapcco.cdcooper%TYPE
                             ,pr_nrconven IN crapcco.nrconven%TYPE) IS
                SELECT 1
                  FROM crapcco
                 WHERE crapcco.cdcooper = pr_cdcooper
                   AND crapcco.nrconven = pr_nrconven;
            rw_crapcco cr_crapcco%ROWTYPE;
        
            -- Busca o operador
            CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                             ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
                SELECT 1
                  FROM crapope
                 WHERE crapope.cdcooper = pr_cdcooper
                   AND crapope.cdoperad = pr_cdoperad;
            rw_crapope cr_crapope%ROWTYPE;
        
            --> Busca associado
            CURSOR cr_crapass(pr_cdcooper IN crapcco.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
                SELECT ass.inpessoa
                      ,to_char(ass.nrcpfcgc) nrcpfcgc
                      ,to_char(ass.nrdconta) nrdconta
                      ,decode(ass.inpessoa, 1, lpad(ass.nrcpfcgc, 11, '0'), lpad(ass.nrcpfcgc, 14, '0')) dscpfcgc
                      ,decode(ass.inpessoa, 1, 'F', 'J') dspessoa
                      ,to_char(cop.cdagectl) cdagectl
                  FROM crapass ass
                      ,crapcop cop
                 WHERE ass.cdcooper = cop.cdcooper
                   AND ass.cdcooper = pr_cdcooper
                   AND ass.nrdconta = pr_nrdconta;
            rw_crapass cr_crapass%ROWTYPE;
        
            -- Cadastro de Bloquetos
            CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                             ,pr_nrdconta IN crapceb.nrdconta%TYPE
                             ,pr_nrconven IN crapceb.nrconven%TYPE) IS
                SELECT crapceb.insitceb
                  FROM crapceb
                 WHERE crapceb.cdcooper = pr_cdcooper
                   AND crapceb.nrdconta = pr_nrdconta
                   AND crapceb.nrconven = pr_nrconven
								 UNION ALL
								SELECT crapceb.insitceb
                  FROM tbcobran_crapceb crapceb
                 WHERE crapceb.cdcooper = pr_cdcooper
                   AND crapceb.nrdconta = pr_nrdconta
                   AND crapceb.nrconven = pr_nrconven;
            rw_crapceb cr_crapceb%ROWTYPE;
        
            -- Cursor generico de calendario
            rw_crapdat btch0001.cr_crapdat%ROWTYPE;
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
        
            -- Variaveis
            vr_blnfound BOOLEAN;
            vr_qtbolcob NUMBER;
            vr_nrdrowid ROWID;
            vr_dstransa VARCHAR2(1000);
            vr_dtfimrel VARCHAR2(8);
            vr_nrconven VARCHAR2(10);
        
            -- Variaveis de log
            vr_cdcooper INTEGER;
            vr_cdoperad VARCHAR2(100);
            vr_nmdatela VARCHAR2(100);
            vr_nmeacao  VARCHAR2(100);
            vr_cdagenci VARCHAR2(100);
            vr_nrdcaixa VARCHAR2(100);
            vr_idorigem VARCHAR2(100);
        
        BEGIN
            -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_nmeacao  => vr_nmeacao
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
            -- Seta a descricao da transacao
            vr_dstransa := 'Validar cancelamento do convenio de cobranca.';
        
            -- Verificacao do calendario
            OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
            FETCH btch0001.cr_crapdat
                INTO rw_crapdat;
            CLOSE btch0001.cr_crapdat;
        
            -- Verifica se possui boletos
            OPEN cr_crapcob(pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrcnvcob => pr_nrconven);
            FETCH cr_crapcob
                INTO vr_qtbolcob;
            -- Fecha cursor
            CLOSE cr_crapcob;
            -- Se possui boletos cadastrados
            IF vr_qtbolcob > 0 THEN
                vr_dscritic := 'Existem boletos cadastrados para este convenio CEB.';
                RAISE vr_exc_saida;
            END IF;
        
            -- Busca o cadastro de convenio
            OPEN cr_crapcco(pr_cdcooper => vr_cdcooper, pr_nrconven => pr_nrconven);
            FETCH cr_crapcco
                INTO rw_crapcco;
            -- Alimenta a booleana se achou ou nao
            vr_blnfound := cr_crapcco%FOUND;
            -- Fecha cursor
            CLOSE cr_crapcco;
            -- Se NAO encontrou
            IF NOT vr_blnfound THEN
                vr_cdcritic := 563;
                RAISE vr_exc_saida;
            END IF;
        
            -- Busca o operador
            OPEN cr_crapope(pr_cdcooper => vr_cdcooper, pr_cdoperad => vr_cdoperad);
            FETCH cr_crapope
                INTO rw_crapope;
            -- Alimenta a booleana se achou ou nao
            vr_blnfound := cr_crapope%FOUND;
            -- Fecha cursor
            CLOSE cr_crapope;
            -- Se NAO encontrou
            IF NOT vr_blnfound THEN
                vr_cdcritic := 67;
                RAISE vr_exc_saida;
            END IF;
        
            -- Cadastro de bloquetos
            OPEN cr_crapceb(pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrconven => pr_nrconven);
            FETCH cr_crapceb
                INTO rw_crapceb;
            CLOSE cr_crapceb;
        
            -- Seta a descricao da transacao
            vr_dstransa := 'Efetuar o cancelamento do convenio de cobranca.';
        
            BEGIN
                DELETE tbcobran_categ_tarifa_conven
                 WHERE cdcooper = vr_cdcooper
                   AND nrdconta = pr_nrdconta
                   AND nrconven = pr_nrconven;
            
                DELETE tbrecip_apuracao_indica
                 WHERE idapuracao_reciproci IN (SELECT idapuracao_reciproci
                                                  FROM tbrecip_apuracao
                                                 WHERE cdcooper = vr_cdcooper
                                                   AND nrdconta = pr_nrdconta
                                                   AND cdchave_produto = pr_nrconven
                                                   AND cdproduto = 6); -- Cobranca
            
                DELETE tbrecip_apuracao
                 WHERE cdcooper = vr_cdcooper
                   AND nrdconta = pr_nrdconta
                   AND cdchave_produto = pr_nrconven
                   AND cdproduto = 6; -- Cobranca
            
                DELETE tbrecip_apuracao_tarifa
                 WHERE cdcooper = vr_cdcooper
                   AND nrdconta = pr_nrdconta
                   AND cdchave_produto = pr_nrconven
                   AND cdproduto = 6; -- Cobranca
            
                DELETE tbcobran_categ_tarifa_conven
                 WHERE cdcooper = vr_cdcooper
                   AND nrdconta = pr_nrdconta
                   AND nrconven = pr_nrconven;
            
                DELETE FROM crapceb
                 WHERE cdcooper = vr_cdcooper
                   AND nrdconta = pr_nrdconta
                   AND nrconven = pr_nrconven
                   AND nrcnvceb = pr_nrcnvceb;
							 
						    DELETE FROM tbcobran_crapceb
                 WHERE cdcooper = vr_cdcooper
                   AND nrdconta = pr_nrdconta
                   AND nrconven = pr_nrconven
                   AND nrcnvceb = pr_nrcnvceb;
            EXCEPTION
                WHEN OTHERS THEN
                    vr_dscritic := 'Problema ao excluir convenio: ' || SQLERRM;
                    RAISE vr_exc_saida;
            END;
        
            -- Gerar informacoes do log
            gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => ' '
                                ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                                ,pr_dstransa => vr_dstransa
                                ,pr_dttransa => trunc(SYSDATE)
                                ,pr_flgtrans => 1 --> TRUE
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => 'COBRANCA'
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
        
            -- Gerar informacoes do item
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'nrconven'
                                     ,pr_dsdadant => pr_nrconven
                                     ,pr_dsdadatu => NULL);
        
            -- Gerar informacoes do item
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'nrcnvceb'
                                     ,pr_dsdadant => pr_nrcnvceb
                                     ,pr_dsdadatu => NULL);
        
            --> Busca associado
            OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
            FETCH cr_crapass
                INTO rw_crapass;
            IF cr_crapass%NOTFOUND THEN
                vr_cdcritic := 9; -- associado nao cadastrado
                CLOSE cr_crapass;
            ELSE
                CLOSE cr_crapass;
            END IF;
        
            --> Gravar o log de adesao ou bloqueio do convenio
            cobr0008.pc_gera_log_ceb(pr_idorigem     => vr_idorigem
                                    ,pr_cdcooper     => vr_cdcooper
                                    ,pr_cdoperad     => vr_cdoperad
                                    ,pr_nrdconta     => pr_nrdconta
                                    ,pr_nrconven     => pr_nrconven
                                    ,pr_insitceb_ant => nvl(rw_crapceb.insitceb, 0)
                                    ,pr_insitceb     => 2
                                    , -- 'INATIVO'
                                     pr_dscritic     => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
            END IF;
        
            -- Atualizar convenio na CIP  
            BEGIN
                vr_dtfimrel := to_char(rw_crapdat.dtmvtolt, 'RRRRMMDD');
                vr_nrconven := to_char(pr_nrconven);
                UPDATE cecredleg.tbjdddabnf_convenio@jdnpcsql
                   SET TBJDDDABNF_Convenio."SitConvBenfcrioPar" = 'E'
                       ,TBJDDDABNF_Convenio."DtFimRelctConv"     = vr_dtfimrel
                 WHERE TBJDDDABNF_Convenio."ISPB_IF" = '05463212'
                   AND TBJDDDABNF_Convenio."TpPessoaBenfcrio" = rw_crapass.dspessoa
                   AND TBJDDDABNF_Convenio."CNPJ_CPFBenfcrio" = rw_crapass.dscpfcgc
                   AND TBJDDDABNF_Convenio."CodCli_Conv" = vr_nrconven
                   AND TBJDDDABNF_Convenio."AgDest" = rw_crapass.cdagectl
                   AND TBJDDDABNF_Convenio."CtDest" = rw_crapass.nrdconta;
            
            EXCEPTION
                WHEN OTHERS THEN
                    vr_dscritic := 'Nao foi possivel atualizar convenio na CIP: ' || SQLERRM;
                    RAISE vr_exc_saida;
            END;
        
            COMMIT;
            npcb0002.pc_libera_sessao_sqlserver_npc('TELA_ATENDA_COBRAN_1');
        
        EXCEPTION
            WHEN vr_exc_saida THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
								pr_des_erro := vr_dscritic;
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
                npcb0002.pc_libera_sessao_sqlserver_npc('TELA_ATENDA_COBRAN_2');
            
                -- Gerar informacoes do log
                gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                                    ,pr_dstransa => vr_dstransa
                                    ,pr_dttransa => trunc(SYSDATE)
                                    ,pr_flgtrans => 0 --> FALSE
                                    ,pr_hrtransa => gene0002.fn_busca_time
                                    ,pr_idseqttl => 1
                                    ,pr_nmdatela => 'COBRANCA'
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrdrowid => vr_nrdrowid);
                COMMIT;
            
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;
            
								pr_des_erro := pr_dscritic;
            
                -- Carregar XML padrão para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
                npcb0002.pc_libera_sessao_sqlserver_npc('TELA_ATENDA_COBRAN_3');
        END;
    
    END pc_exclui_convenio;

    PROCEDURE pc_valida_habilitacao(pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                                   ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_valida_habilitacao          Antigo: b1wgen0082.p/valida-habilitacao
        Sistema : Ayllos Web
        Autor   : Jaison Fernando
        Data    : Fevereiro/2016                 Ultima atualizacao: 
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para validar a habilitacao do convenio.
        
        Alteracoes: 
        ..............................................................................*/
        DECLARE
        
            -- Busca o cadastro de convenio
            CURSOR cr_crapcco(pr_cdcooper IN crapcco.cdcooper%TYPE
                             ,pr_nrconven IN crapcco.nrconven%TYPE) IS
                SELECT crapcco.flgativo
                      ,crapcco.dsorgarq
                      ,crapcco.flgregis
                      ,crapcco.cddbanco
                      ,crapcco.flserasa
                  FROM crapcco
                 WHERE crapcco.cdcooper = pr_cdcooper
                   AND crapcco.nrconven = pr_nrconven;
            rw_crapcco cr_crapcco%ROWTYPE;
        
            -- Cadastro de bloquetos
            CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                             ,pr_nrdconta IN crapceb.nrdconta%TYPE
                             ,pr_nrconven IN crapceb.nrconven%TYPE) IS
                SELECT 1
                  FROM crapceb
                 WHERE crapceb.cdcooper = pr_cdcooper
                   AND crapceb.nrdconta = pr_nrdconta
                   AND crapceb.nrconven = pr_nrconven
								 UNION
							 SELECT 1
                  FROM tbcobran_crapceb crapceb
                 WHERE crapceb.cdcooper = pr_cdcooper
                   AND crapceb.nrdconta = pr_nrdconta
                   AND crapceb.nrconven = pr_nrconven;
            rw_crapceb cr_crapceb%ROWTYPE;
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
        
            -- Variaveis
            vr_blnfound BOOLEAN;
            vr_nrdrowid ROWID;
            vr_dstransa VARCHAR2(1000);
            vr_flgregis VARCHAR2(3);
        
            -- Variaveis de log
            vr_cdcooper INTEGER;
            vr_cdoperad VARCHAR2(100);
            vr_nmdatela VARCHAR2(100);
            vr_nmeacao  VARCHAR2(100);
            vr_cdagenci VARCHAR2(100);
            vr_nrdcaixa VARCHAR2(100);
            vr_idorigem VARCHAR2(100);
        
        BEGIN
            -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_nmeacao  => vr_nmeacao
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
            -- Seta a descricao da transacao
            vr_dstransa := 'Validar habilitacao de cadastro de cobranca.';
        
            -- Busca o cadastro de convenio
            OPEN cr_crapcco(pr_cdcooper => vr_cdcooper, pr_nrconven => pr_nrconven);
            FETCH cr_crapcco
                INTO rw_crapcco;
            -- Alimenta a booleana se achou ou nao
            vr_blnfound := cr_crapcco%FOUND;
            -- Fecha cursor
            CLOSE cr_crapcco;
            -- Se NAO encontrou
            IF NOT vr_blnfound THEN
                vr_cdcritic := 563;
                RAISE vr_exc_saida;
            END IF;
        
            -- Se convenio esta desativado
            IF rw_crapcco.flgativo = 0 THEN
                vr_cdcritic := 949;
                RAISE vr_exc_saida;
            END IF;
        
            -- Cadastro de bloquetos
            OPEN cr_crapceb(pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrconven => pr_nrconven);
            FETCH cr_crapceb
                INTO rw_crapceb;
            -- Alimenta a booleana se achou ou nao
            vr_blnfound := cr_crapceb%FOUND;
            -- Fecha cursor
            CLOSE cr_crapceb;
            -- Se encontrou
            IF vr_blnfound THEN
                vr_cdcritic := 793;
                RAISE vr_exc_saida;
            END IF;
        
            -- Se NAO for registrada
            IF rw_crapcco.flgregis = 0 THEN
                vr_flgregis := 'NAO';
            ELSE
                vr_flgregis := 'SIM';
            END IF;
        
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
                                  ,pr_tag_nova => 'cddbanco'
                                  ,pr_tag_cont => rw_crapcco.cddbanco
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'dsorgarq'
                                  ,pr_tag_cont => rw_crapcco.dsorgarq
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flgregis'
                                  ,pr_tag_cont => vr_flgregis
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flserasa'
                                  ,pr_tag_cont => rw_crapcco.flserasa
                                  ,pr_des_erro => vr_dscritic);
        
        EXCEPTION
            WHEN vr_exc_saida THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
            
                -- Gerar informacoes do log
                gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                                    ,pr_dstransa => vr_dstransa
                                    ,pr_dttransa => trunc(SYSDATE)
                                    ,pr_flgtrans => 0 --> FALSE
                                    ,pr_hrtransa => gene0002.fn_busca_time
                                    ,pr_idseqttl => 1
                                    ,pr_nmdatela => 'COBRANCA'
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrdrowid => vr_nrdrowid);
                COMMIT;
            
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;
            
                -- Carregar XML padrão para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
        END;
    
    END pc_valida_habilitacao;

    PROCEDURE pc_valida_dados_limite(pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                                    ,pr_dsorgarq IN crapcco.dsorgarq%TYPE --> Origem Arquivo
                                    ,pr_inarqcbr IN crapceb.inarqcbr%TYPE --> Recebe Arquivo de Retorno de Cobranca
                                    ,pr_cddemail IN crapceb.cddemail%TYPE --> Email Arquivo de Retorno de Cobranca
                                    ,pr_idseqttl IN crapcem.idseqttl%TYPE --> Sequencia do titular
                                    ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_valida_dados_limite         Antigo: b1wgen0082.p/valida-dados-limites
        Sistema : Ayllos Web
        Autor   : Jaison Fernando
        Data    : Fevereiro/2016                 Ultima atualizacao: 
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para validar os dados inclusao/alteracao do convenio.
        
        Alteracoes: 
        ..............................................................................*/
        DECLARE
        
            -- Busca o cadastro de email
            CURSOR cr_crapcem(pr_cdcooper IN crapcem.cdcooper%TYPE
                             ,pr_nrdconta IN crapcem.nrdconta%TYPE
                             ,pr_idseqttl IN crapcem.idseqttl%TYPE
                             ,pr_cddemail IN crapcem.cddemail%TYPE) IS
                SELECT 1
                  FROM crapcem
                 WHERE crapcem.cdcooper = pr_cdcooper
                   AND crapcem.nrdconta = pr_nrdconta
                   AND crapcem.idseqttl = pr_idseqttl
                   AND crapcem.cddemail = pr_cddemail;
            rw_crapcem cr_crapcem%ROWTYPE;
        
            -- Cadastro de associados
            CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
                SELECT crapass.idastcjt
                  FROM crapass
                 WHERE crapass.cdcooper = pr_cdcooper
                   AND crapass.nrdconta = pr_nrdconta;
            rw_crapass cr_crapass%ROWTYPE;
        
            -- Cadastro de senhas
            CURSOR cr_crapsnh(pr_cdcooper IN crapsnh.cdcooper%TYPE
                             ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                             ,pr_idseqttl IN crapsnh.idseqttl%TYPE) IS
                SELECT 1
                  FROM crapsnh
                 WHERE crapsnh.cdcooper = pr_cdcooper
                   AND crapsnh.nrdconta = pr_nrdconta
                   AND crapsnh.tpdsenha = 1 -- Internet
                   AND crapsnh.idseqttl = decode(pr_idseqttl, 0, crapsnh.idseqttl, pr_idseqttl)
                   AND crapsnh.cdsitsnh = 1; -- Ativa
            rw_crapsnh cr_crapsnh%ROWTYPE;
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
        
            -- Variaveis
            vr_blnfound BOOLEAN;
            vr_nrdrowid ROWID;
            vr_dstransa VARCHAR2(1000);
            vr_idseqttl crapsnh.idseqttl%TYPE;
        
            -- Variaveis de log
            vr_cdcooper INTEGER;
            vr_cdoperad VARCHAR2(100);
            vr_nmdatela VARCHAR2(100);
            vr_nmeacao  VARCHAR2(100);
            vr_cdagenci VARCHAR2(100);
            vr_nrdcaixa VARCHAR2(100);
            vr_idorigem VARCHAR2(100);
        
        BEGIN
            -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_nmeacao  => vr_nmeacao
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
            -- Seta a descricao da transacao
            vr_dstransa := 'Validar dados de inclusao/alteracao do convenio.';
        
            -- Se NAO foi informado um tipo de retorno
            IF pr_inarqcbr < 0 OR pr_inarqcbr > 3 THEN
                vr_dscritic := 'Tipo de arquivo de retorno invalido.';
                RAISE vr_exc_saida;
            END IF;
        
            -- Se NAO foi informado email para o retorno
            IF pr_cddemail = 0 AND pr_inarqcbr > 0 THEN
                vr_dscritic := 'Informe email para arquivo de retorno.';
                RAISE vr_exc_saida;
            END IF;
        
            -- Se tem arquivo de retorno
            IF pr_inarqcbr > 0 THEN
                -- Busca o cadastro de email
                OPEN cr_crapcem(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_idseqttl => pr_idseqttl
                               ,pr_cddemail => pr_cddemail);
                FETCH cr_crapcem
                    INTO rw_crapcem;
                -- Alimenta a booleana se achou ou nao
                vr_blnfound := cr_crapcem%FOUND;
                -- Fecha cursor
                CLOSE cr_crapcem;
                -- Se NAO encontrou
                IF NOT vr_blnfound THEN
                    vr_cdcritic := 812;
                    RAISE vr_exc_saida;
                END IF;
            END IF;
        
            -- Cadastro de associados
            OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
            FETCH cr_crapass
                INTO rw_crapass;
            -- Alimenta a booleana se achou ou nao
            vr_blnfound := cr_crapass%FOUND;
            -- Fecha cursor
            CLOSE cr_crapass;
            -- Se NAO encontrou
            IF NOT vr_blnfound THEN
                vr_cdcritic := 9;
                RAISE vr_exc_saida;
            END IF;
        
            -- Se convenio INTERNET
            IF pr_dsorgarq = 'INTERNET' THEN
            
                -- Indicador de assinatura conjunta (0 – Nao exige)
                IF rw_crapass.idastcjt = 0 THEN
                    vr_idseqttl := 1;
                ELSE
                    vr_idseqttl := 0;
                END IF;
            
                -- Cadastro de senhas
                OPEN cr_crapsnh(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_idseqttl => vr_idseqttl);
                FETCH cr_crapsnh
                    INTO rw_crapsnh;
                -- Alimenta a booleana se achou ou nao
                vr_blnfound := cr_crapsnh%FOUND;
                -- Fecha cursor
                CLOSE cr_crapsnh;
                -- Se NAO encontrou
                IF NOT vr_blnfound THEN
                    vr_dscritic := 'Nenhuma senha de internet esta ativa.';
                    RAISE vr_exc_saida;
                END IF;
            
            END IF;
        
        EXCEPTION
            WHEN vr_exc_saida THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
            
                -- Gerar informacoes do log
                gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                                    ,pr_dstransa => vr_dstransa
                                    ,pr_dttransa => trunc(SYSDATE)
                                    ,pr_flgtrans => 0 --> FALSE
                                    ,pr_hrtransa => gene0002.fn_busca_time
                                    ,pr_idseqttl => pr_idseqttl
                                    ,pr_nmdatela => 'COBRANCA'
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrdrowid => vr_nrdrowid);
                COMMIT;
            
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;
            
                -- Carregar XML padrão para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
        END;
    
    END pc_valida_dados_limite;

    PROCEDURE pc_habilita_convenio(pr_nrdconta    IN crapceb.nrdconta%TYPE --> Conta
                                  ,pr_nrconven    IN crapceb.nrconven%TYPE --> Convenio
                                  ,pr_insitceb    IN crapceb.insitceb%TYPE --> Situacao do Convenio
                                  ,pr_inarqcbr    IN crapceb.inarqcbr%TYPE --> Recebe Arquivo Retorno
                                  ,pr_cddemail    IN crapceb.cddemail%TYPE --> Email Arquivo de Retorno
                                  ,pr_flgcruni    IN crapceb.flgcruni%TYPE --> Credito Unificado
                                  ,pr_flgcebhm    IN crapceb.flgcebhm%TYPE --> Contem o convenio homologado
                                  ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Sequencia Titular
                                  ,pr_flgregon    IN crapceb.flgregon%TYPE --> Flag de registro de titulo online (0-Nao/1-Sim)
                                  ,pr_flgpgdiv    IN crapceb.flgpgdiv%TYPE --> Flag de autorizacao de pagamento divergente (0-Nao/ 1-Sim)
                                  ,pr_flcooexp    IN crapceb.flcooexp%TYPE --> Cooperado Emite e Expede Boletos
                                  ,pr_flceeexp    IN crapceb.flceeexp%TYPE --> Cooperativa Emite e Expede Boletos
                                  ,pr_flserasa    IN crapceb.flserasa%TYPE --> Pode negativar no Serasa
                                  ,pr_qtdfloat    IN crapceb.qtdfloat%TYPE --> Quantidade de dias para o Float
                                  ,pr_flprotes    IN crapceb.flprotes%TYPE --> Liberacao da opcao de Protesto na Cobranca
                                  ,pr_insrvprt    IN crapceb.insrvprt%TYPE --> Serviço de Protesto
                                  ,pr_qtlimaxp    IN crapceb.qtlimaxp%TYPE --> Limite a maximo de dias para pode protestar
                                  ,pr_qtlimmip    IN crapceb.qtlimmip%TYPE --> Quantidade de dias para poder protestar
                                  ,pr_qtdecprz    IN crapceb.qtdecprz%TYPE --> Quantidade de dias para Decurso de Prazo
                                  ,pr_idrecipr    IN crapceb.idrecipr%TYPE --> ID unico do calculo de reciprocidade atrelado a contratacao
                                  ,pr_idreciprold IN crapceb.idrecipr%TYPE --> ID unico do calculo de reciprocidade atrelado a contratacao
                                  ,pr_perdesconto IN VARCHAR2 --> Categoria e valor do desconto
                                  ,pr_inenvcob    IN crapceb.inenvcob%TYPE --> Forma de envio de arquivo de cobrança
				  ,pr_flgapihm    IN crapceb.flgapihm%TYPE --> Flag representando o uso da API
                                  ,pr_blnewreg    IN BOOLEAN --> Identifica se é um novo registro
                                  ,pr_retxml      IN xmltype --> Arquivo de retorno do XML
                                   -- OUT
                                  ,pr_flgimpri OUT INTEGER --> Deve imprimir?
                                  ,pr_dsdmesag OUT VARCHAR2 --> Mensagens do processo 
                                  ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_habilita_convenio           Antigo: b1wgen0082.p/habilita-convenio
        Sistema : Ayllos Web
        Autor   : Jaison Fernando
        Data    : Fevereiro/2016                 Ultima atualizacao: 08/08/2019
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para habilitar o convenio do cooperado.
        
        Alteracoes: 26/04/2016 - Ajustes projeto PRJ318 - Nova Plataforma cobrança
                                 (Odirlei-AMcom)
        
                    24/08/2016 - Ajuste emergencial pós-liberação do projeto 318. (Rafael)
                                 
                    14/09/2016 - Adicionado validacao de convenio ativo 
                                 (Douglas - Chamado 502770)
        
                    03/11/2016 - Ajustado as validacoes de situacao do convenio na conta do 
                                 cooperado quando alterar os dados (Douglas - Chamado 547082)
        
                    13/12/2016 - PRJ340 - Nova Plataforma de Cobranca - Fase II. (Jaison/Cechet)
        
                    17/10/2017 - Utilizar data de abertura da conta (ass.dtabtcct) ao registrar
                                 beneficiario na CIP. (Rafael)
        
                    08/12/2017 - Inclusão de chamada da npcb0002.pc_libera_sessao_sqlserver_npc
                                 (SD#791193 - AJFink)
        
                    17/04/2018 - Validação se o vr_insitceb é diferente de 2, tratamento para permitir inativação
                                 da cobrança caso o cooperado esteja classificado na categoria de risco de fraude.
                                 (Chamado 853600 - GSaquetta)

                    18/12/2018 - Correção na habilitação do convênio para inclusão na CIP
                                 (Andre Clemer - Supero)
                    
					18/02/2019 - Novo campo tela ATENDA -> Cobranca (Homologado API)
								 (Andrey Formigari - Supero)
                 
                    07/08/2019 - Correção na gravação do Flag Homologado API
                                 (Rafael Ferreira - Mouts)
                                 
                    08/08/2019 - Tratamento de Nulos para INC0020100
                                 (Rafael Ferreira - Mouts)
                 
                    
        ..............................................................................*/
        DECLARE
        
            -- Cadastro de associados
            CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
                SELECT to_char(crapass.nrdconta) nrdconta
                      ,crapass.inpessoa
                      ,decode(crapass.inpessoa, 1, 'F', 'J') dspessoa
                      ,crapass.nmprimtl
                      ,decode(crapass.inpessoa
                             ,1
                             ,lpad(crapass.nrcpfcgc, 11, '0')
                             ,lpad(crapass.nrcpfcgc, 14, '0')) dscpfcgc
                      ,decode(crapass.inpessoa, 1, to_char(crapass.nrcpfcgc), to_char(crapass.nrcpfcgc)) nrcpfcgc
                      ,to_char(crapcop.cdagectl) cdagectl
                      ,nvl(crapass.dtabtcct, crapass.dtmvtolt) dtabtcct -- existem casos que a dtabtcct é nula (?)
                  FROM crapass
                      ,crapcop
                 WHERE crapass.cdcooper = crapcop.cdcooper
                   AND crapass.cdcooper = pr_cdcooper
                   AND crapass.nrdconta = pr_nrdconta;
            rw_crapass cr_crapass%ROWTYPE;
        
            -- Busca o cadastro de convenio
            CURSOR cr_crapcco(pr_cdcooper IN crapcco.cdcooper%TYPE
                             ,pr_nrconven IN crapcco.nrconven%TYPE) IS
                SELECT crapcco.nrconven
                      ,crapcco.cddbanco
                      ,crapcco.dsorgarq
                      ,crapcco.flgregis
                      ,crapcco.flgutceb
                      ,crapcco.flgativo
                      ,crapcco.qtdfloat
                      ,crapcco.qtdecini --Quantidade Inicial de Dias para Decurso de Prazo
                  FROM crapcco
                 WHERE crapcco.cdcooper = pr_cdcooper
                   AND crapcco.nrconven = pr_nrconven;
            rw_crapcco cr_crapcco%ROWTYPE;
            
            -- Busca o operador
            CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                             ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
                SELECT crapope.cddepart
                      ,crapope.nmoperad
                  FROM crapope
                 WHERE crapope.cdcooper = pr_cdcooper
                   AND crapope.cdoperad = pr_cdoperad;
            rw_crapope cr_crapope%ROWTYPE;
        
            -- Verifica se existe convenio INTERNET habilitado
            CURSOR cr_cco_ceb(pr_cdcooper IN crapcco.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE
                             ,pr_nrconven IN crapcco.nrconven%TYPE
                             ,pr_flgregis IN crapcco.flgregis%TYPE
                             ,pr_cddbanco IN crapcco.cddbanco%TYPE) IS
                SELECT COUNT(1)
                  FROM crapcco
                      ,crapceb
                 WHERE crapcco.cdcooper = pr_cdcooper
                   AND crapcco.nrconven <> pr_nrconven
                   AND crapcco.flgregis = pr_flgregis
                   AND crapcco.cddbanco = pr_cddbanco
                   AND crapcco.dsorgarq = 'INTERNET'
                   AND crapcco.flginter = 1 -- Utilizado na Internet
                   AND crapceb.cdcooper = crapcco.cdcooper
                   AND crapceb.nrconven = crapcco.nrconven
                   AND crapceb.nrdconta = pr_nrdconta
                   AND crapceb.insitceb = 1 -- Ativo
								 UNION ALL
							  SELECT COUNT(1)
                  FROM crapcco
                      ,tbcobran_crapceb crapceb
                 WHERE crapcco.cdcooper = pr_cdcooper
                   AND crapcco.nrconven <> pr_nrconven
                   AND crapcco.flgregis = pr_flgregis
                   AND crapcco.cddbanco = pr_cddbanco
                   AND crapcco.dsorgarq = 'INTERNET'
                   AND crapcco.flginter = 1 -- Utilizado na Internet
                   AND crapceb.cdcooper = crapcco.cdcooper
                   AND crapceb.nrconven = crapcco.nrconven
                   AND crapceb.nrdconta = pr_nrdconta
                   AND crapceb.insitceb = 1; -- Ativo
        
            -- Cadastro de Bloquetos
            CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                             ,pr_nrdconta IN crapceb.nrdconta%TYPE
                             ,pr_nrconven IN crapceb.nrconven%TYPE) IS
                SELECT crapceb.nrcnvceb
                      ,crapceb.insitceb
                      ,crapceb.inarqcbr
                      ,crapceb.cddemail
                      ,crapceb.flgcruni
                      ,crapceb.flgregon
                      ,crapceb.flgpgdiv
                      ,crapceb.flcooexp
                      ,crapceb.flceeexp
                      ,crapceb.flprotes
                      ,crapceb.insrvprt
                      ,crapceb.qtlimaxp
                      ,crapceb.qtlimmip
                      ,crapceb.qtdecprz
                      ,crapceb.qtdfloat
                      ,crapceb.inenvcob
		      ,crapceb.dhhomapi
                      ,crapceb.cdhomapi
                      ,crapceb.flgapihm
                  FROM crapceb
                 WHERE crapceb.cdcooper = pr_cdcooper
                   AND crapceb.nrdconta = pr_nrdconta
                   AND crapceb.nrconven = pr_nrconven
								 UNION ALL
								SELECT crapceb.nrcnvceb
                      ,crapceb.insitceb
                      ,crapceb.inarqcbr
                      ,crapceb.cddemail
                      ,crapceb.flgcruni
                      ,crapceb.flgregon
                      ,crapceb.flgpgdiv
                      ,crapceb.flcooexp
                      ,crapceb.flceeexp
                      ,crapceb.flprotes
                      ,crapceb.insrvprt
                      ,crapceb.qtlimaxp
                      ,crapceb.qtlimmip
                      ,crapceb.qtdecprz
                      ,crapceb.qtdfloat
                      ,crapceb.inenvcob
		      ,crapceb.dhhomapi
                      ,crapceb.cdhomapi
                      ,crapceb.flgapihm
                  FROM tbcobran_crapceb crapceb
                 WHERE crapceb.cdcooper = pr_cdcooper
                   AND crapceb.nrdconta = pr_nrdconta
                   AND crapceb.nrconven = pr_nrconven;
            rw_crapceb cr_crapceb%ROWTYPE;
        
            -- Ultimo Cadastro de Bloquetos
            CURSOR cr_lastceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                             ,pr_nrconven IN crapceb.nrconven%TYPE) IS
                SELECT nrcnvceb 
								  FROM( SELECT /*+ INDEX_DESC(T0 CRAPCEB##CRAPCEB3) */
                 nrcnvceb
                  FROM crapceb t0
                 WHERE cdcooper = pr_cdcooper
                   AND nrconven = pr_nrconven
													 AND rownum = 1
												 UNION ALL
									      SELECT nrcnvceb
													FROM tbcobran_crapceb t0
												 WHERE cdcooper = pr_cdcooper
													 AND nrconven = pr_nrconven
													 AND rownum = 1) 
								 WHERE rownum = 1;
            rw_lastceb cr_lastceb%ROWTYPE;
        
            -- Verifica se existe convenio do mesmo tipo
            CURSOR cr_ceb_cco(pr_cdcooper IN crapceb.cdcooper%TYPE
                             ,pr_nrdconta IN crapceb.nrdconta%TYPE) IS
                SELECT crapcco.flgregis
                  FROM crapceb
                      ,crapcco
                 WHERE crapceb.cdcooper = pr_cdcooper
                   AND crapceb.nrdconta = pr_nrdconta
                   AND crapceb.cdcooper = crapcco.cdcooper
                   AND crapceb.nrconven = crapcco.nrconven
								 UNION ALL
								SELECT crapcco.flgregis
                  FROM tbcobran_crapceb crapceb
                      ,crapcco
                 WHERE crapceb.cdcooper = pr_cdcooper
                   AND crapceb.nrdconta = pr_nrdconta
                   AND crapceb.cdcooper = crapcco.cdcooper
                   AND crapceb.nrconven = crapcco.nrconven;
        
            -- Busca a categoria
            CURSOR cr_crapcat(pr_cdcatego IN crapcat.cdcatego%TYPE) IS
                SELECT initcap(crapcat.dscatego) dscatego FROM crapcat WHERE crapcat.cdcatego = pr_cdcatego;
            rw_crapcat cr_crapcat%ROWTYPE;
        
            -- Busca periodo de apuracao da Reciprocidade
            CURSOR cr_apuracao(pr_nrconven IN crapcco.nrconven%TYPE
                              ,pr_idrecipr IN crapceb.idrecipr%TYPE) IS
                SELECT apr.idapuracao_reciproci
                      ,apr.dtinicio_apuracao
                      ,apr.dttermino_apuracao
                      ,apr.idconfig_recipro
                      ,apr.tpreciproci
                  FROM tbrecip_apuracao apr
                 WHERE apr.indsituacao_apuracao = 'A' -- Em apuracao
                   AND apr.idconfig_recipro = pr_idrecipr
                   AND apr.cdproduto = 6 -- Cobranca
                   AND apr.cdchave_produto = pr_nrconven;
            rw_apuracao cr_apuracao%ROWTYPE;
        
            -- Configuracao para calculo de Reciprocidade
            CURSOR cr_indicador(pr_idapuracao_reciproci IN tbrecip_apuracao_indica.idapuracao_reciproci%TYPE) IS
                SELECT air.idindicador
                      ,idr.tpindicador
                  FROM tbrecip_apuracao_indica air
                      ,tbrecip_indicador       idr
                 WHERE air.idindicador = idr.idindicador
                   AND air.idapuracao_reciproci = pr_idapuracao_reciproci;
        
            --> Cursor para verificar se ja existe o beneficiario na cip
            CURSOR cr_dda_benef(pr_dspessoa VARCHAR2
                               ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
                SELECT 1
                  FROM cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql b
                 WHERE b.ispb_if = '05463212'
                   AND "TpPessoaBenfcrio" = pr_dspessoa
                   AND "CNPJ_CPFBenfcrio" = pr_nrcpfcgc;
            rw_dda_benef cr_dda_benef%ROWTYPE;
        
            --> Cursor para verificar se ja existe o convenio na cip
            CURSOR cr_dda_conven(pr_dspessoa VARCHAR2
                                ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE
                                ,pr_nrconven VARCHAR2) IS
                SELECT 1
                  FROM cecredleg.tbjdddabnf_convenio@jdnpcsql b
                 WHERE b."ISPB_IF" = '05463212'
                   AND b."TpPessoaBenfcrio" = pr_dspessoa
                   AND b."CNPJ_CPFBenfcrio" = pr_nrcpfcgc
                   AND b."CodCli_Conv" = pr_nrconven;
            rw_dda_conven cr_dda_conven%ROWTYPE;
        
            --> Buscar dados pessoa juridica
            CURSOR cr_crapjur(pr_cdcooper crapjur.cdcooper%TYPE
                             ,pr_nrdconta crapjur.nrdconta%TYPE) IS
                SELECT jur.nmfansia
                  FROM crapjur jur
                 WHERE jur.cdcooper = pr_cdcooper
                   AND jur.nrdconta = pr_nrdconta;
            rw_crapjur cr_crapjur%ROWTYPE;
        
            -- Cursor generico de calendario
            rw_crapdat btch0001.cr_crapdat%ROWTYPE;
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
            vr_des_erro VARCHAR2(3);
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
        
            -- Variaveis
            vr_blnfound      BOOLEAN;
	    vr_blnewreg_cip  BOOLEAN := FALSE;
            vr_fldda_sit_ben BOOLEAN;
            vr_flgimpri      INTEGER;
            vr_qtccoceb      NUMBER;
            vr_nrdrowid      ROWID;
            vr_dstransa      VARCHAR2(1000);
            vr_dsoperac      VARCHAR2(1000);
            vr_dsdmesag      VARCHAR2(1000);
            vr_nrcnvceb      crapceb.nrcnvceb%TYPE;
            vr_lstdados      gene0002.typ_split;
            vr_lstdado2      gene0002.typ_split;
            vr_cdcatego      tbcobran_categ_tarifa_conven.cdcatego%TYPE;
            vr_percdesc      tbcobran_categ_tarifa_conven.perdesconto%TYPE;
            vr_flgatingido   CHAR(1);
            vr_insitceb      crapceb.insitceb%TYPE;
            vr_sitifcnv      VARCHAR2(10);
            vr_dsdtmvto      VARCHAR2(10);
            vr_insitif       VARCHAR2(10);
            vr_insitcip      VARCHAR2(10);
            vr_nrconven      VARCHAR2(10);
            vr_dtfimrel      VARCHAR2(10) := NULL;
            vr_qtdfloat      cecred.crapcco.qtdfloat%type;
            vr_qtdecini      cecred.crapcco.qtdecini%type;
        
            -- Variaveis de log
            vr_cdcooper INTEGER;
            vr_cdoperad VARCHAR2(100);
            vr_nmdatela VARCHAR2(100);
            vr_nmeacao  VARCHAR2(100);
            vr_cdagenci VARCHAR2(100);
            vr_nrdcaixa VARCHAR2(100);
            vr_idorigem VARCHAR2(100);
        
            ------------> SUB-Programas <------------
        
        BEGIN
            -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_nmeacao  => vr_nmeacao
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
            -- Verificacao do calendario
            OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
            FETCH btch0001.cr_crapdat
                INTO rw_crapdat;
            CLOSE btch0001.cr_crapdat;
        
            -- Cadastro de associados
            OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
            FETCH cr_crapass
                INTO rw_crapass;
            -- Alimenta a booleana se achou ou nao
            vr_blnfound := cr_crapass%FOUND;
            -- Fecha cursor
            CLOSE cr_crapass;
            -- Se NAO encontrou
            IF NOT vr_blnfound THEN
                vr_cdcritic := 9;
                RAISE vr_exc_saida;
            END IF;
        
            vr_insitceb := pr_insitceb;
            IF vr_insitceb <> 2 THEN
                -- Monta a mensagem da operacao para envio no e-mail
                vr_dsoperac := 'Tentativa de habilitacao de cobranca na conta ' ||
                               gene0002.fn_mask_conta(rw_crapass.nrdconta) || ' - CPF/CNPJ ' ||
                               gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc, rw_crapass.inpessoa);
            
                -- Verificar se a conta esta no cadastro restritivo
                cada0004.pc_alerta_fraude(pr_cdcooper => vr_cdcooper --> Cooperativa
                                         ,pr_cdagenci => vr_cdagenci --> PA
                                         ,pr_nrdcaixa => vr_nrdcaixa --> Nr. do caixa
                                         ,pr_cdoperad => vr_cdoperad --> Cod. operador
                                         ,pr_nmdatela => vr_nmdatela --> Nome da tela
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data de movimento
                                         ,pr_idorigem => vr_idorigem --> ID de origem
                                         ,pr_nrcpfcgc => rw_crapass.nrcpfcgc --> Nr. do CPF/CNPJ
                                         ,pr_nrdconta => pr_nrdconta --> Nr. da conta
                                         ,pr_idseqttl => pr_idseqttl --> Id de sequencia do titular
                                         ,pr_bloqueia => 1 --> Flag Bloqueia operacao
                                         ,pr_cdoperac => 2 --> Cod da operacao
                                         ,pr_dsoperac => vr_dsoperac --> Desc. da operacao
                                         ,pr_cdcritic => vr_cdcritic --> Cod. da critica
                                         ,pr_dscritic => vr_dscritic --> Desc. da critica
                                         ,pr_des_erro => vr_des_erro); --> Retorno de erro  OK/NOK
                -- Se retornou erro
                IF vr_des_erro <> 'OK' THEN
                    RAISE vr_exc_saida;
                END IF;
            END IF;
        
            -- Busca o cadastro de convenio
            OPEN cr_crapcco(pr_cdcooper => vr_cdcooper, pr_nrconven => pr_nrconven);
            FETCH cr_crapcco
                INTO rw_crapcco;
            -- Alimenta a booleana se achou ou nao
            vr_blnfound := cr_crapcco%FOUND;
            vr_qtdfloat := rw_crapcco.qtdfloat;
            vr_qtdecini := rw_crapcco.qtdecini;
            
            -- Fecha cursor
            CLOSE cr_crapcco;
            -- Se NAO encontrou
            IF NOT vr_blnfound THEN
                vr_cdcritic := 563;
                RAISE vr_exc_saida;
            END IF;
        
            -- Se for CECRED
            IF rw_crapcco.cddbanco = 85 THEN
                -- Caso NAO foi informado quem ira Emitir e Expedir
                IF pr_flcooexp = 0 AND pr_flceeexp = 0 THEN
                    vr_dscritic := 'Campo Cooperativa Emite e Expede ou Cooperado Emite e Expede devem ser preenchidos';
                    RAISE vr_exc_saida;
                END IF;
                
            END IF;
        
            -- Busca o operador
            OPEN cr_crapope(pr_cdcooper => vr_cdcooper, pr_cdoperad => vr_cdoperad);
            FETCH cr_crapope
                INTO rw_crapope;
            -- Alimenta a booleana se achou ou nao
            vr_blnfound := cr_crapope%FOUND;
            -- Fecha cursor
            CLOSE cr_crapope;
            -- Se NAO encontrou
            IF NOT vr_blnfound THEN
                vr_cdcritic := 67;
                RAISE vr_exc_saida;
            END IF;
        
            -- NAO pode haver dois convenios INTERNET ativos do mesmo banco
            -- para o mesmo cooperado - cob. sem registro
            IF vr_insitceb = 1 THEN
                -- Se a origem arquivo for INTERNET
                IF rw_crapcco.dsorgarq = 'INTERNET' THEN
                    -- Verifica se existe convenio INTERNET habilitado
                    OPEN cr_cco_ceb(pr_cdcooper => vr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrconven => pr_nrconven
                                   ,pr_flgregis => rw_crapcco.flgregis
                                   ,pr_cddbanco => rw_crapcco.cddbanco);
                    FETCH cr_cco_ceb
                        INTO vr_qtccoceb;
                    -- Fecha cursor
                    CLOSE cr_cco_ceb;
                    -- Se possui convenio INTERNET habilitado
                    IF vr_qtccoceb > 0 THEN
                        vr_dscritic := 'Ja existe um convenio INTERNET habilitado.';
                        RAISE vr_exc_saida;
                    END IF;
                END IF;
            END IF;
        
            -- Cadastro de bloquetos
            OPEN cr_crapceb(pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrconven => pr_nrconven);
            FETCH cr_crapceb
                INTO rw_crapceb;
            -- Alimenta a booleana se achou ou nao
            vr_blnfound := cr_crapceb%FOUND;
            -- Fecha cursor
            CLOSE cr_crapceb;
            -- Se encontrou
            IF vr_blnfound THEN
                -- Se for BB e foi escolhido CNAB 400
                IF rw_crapcco.cddbanco = 1 AND pr_inarqcbr = 3 THEN
                    vr_dscritic := 'Convenio nao suporta arquivo de retorno CNAB400.';
                    RAISE vr_exc_saida;
                ELSE
                    -- Se tem identificador de sequencia
                    IF rw_crapcco.flgutceb = 1 THEN
                        vr_nrcnvceb := rw_crapceb.nrcnvceb;
                    ELSE
                        vr_nrcnvceb := 0;
                    END IF;
                END IF;
            ELSE
                -- Se tem identificador de sequencia
                IF rw_crapcco.flgutceb = 1 THEN
                    -- Ultimo Cadastro de bloquetos
                    OPEN cr_lastceb(pr_cdcooper => vr_cdcooper, pr_nrconven => pr_nrconven);
                    FETCH cr_lastceb
                        INTO rw_lastceb;
                    -- Alimenta a booleana se achou ou nao
                    vr_blnfound := cr_lastceb%FOUND;
                    -- Fecha cursor
                    CLOSE cr_lastceb;
                    -- Se NAO encontrou
                    IF NOT vr_blnfound THEN
                        vr_nrcnvceb := 1;
                    ELSE
                        vr_nrcnvceb := rw_lastceb.nrcnvceb + 1;
                    END IF;
                    -- Numero do Convenio CECRED for superior
                    IF vr_nrcnvceb > 9999 THEN
                        vr_dscritic := 'Numero CEB superior a 9999.';
                        RAISE vr_exc_saida;
                    END IF;
                ELSE
                    vr_nrcnvceb := 0;
                END IF;
            END IF;
        
            -- Gerar impressao
            vr_flgimpri := 1;
        
            -- Verifica se existe convenio do mesmo tipo
            FOR rw_ceb_cco IN cr_ceb_cco(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta) LOOP
                -- Se ja tem, flega para nao imprimir
                IF rw_ceb_cco.flgregis = rw_crapcco.flgregis THEN
                    vr_flgimpri := 0;
                END IF;
            END LOOP;
        
            -- Permitir a reativacao de convenios de cobranca sem registro (Renato - Supero - SD 194301)
            IF rw_crapope.cddepart NOT IN (18) THEN
                -- Regra para nao permitir ativar um convenio sem registro do BB inativo
                IF vr_insitceb = 1 AND rw_crapceb.insitceb = 2 AND rw_crapcco.flgregis = 0 AND
                   rw_crapcco.cddbanco = 1 THEN
                    vr_dscritic := 'Nao eh permitido habilitar convenio BB sem registro inativado.';
                    RAISE vr_exc_saida;
                END IF;
            END IF;
        
            /* Se forma de envio de arquivo de cobrança for por FTP e origem do convênio 
            não for "IMPRESSO PELO SOFTWARE", gerar crítica*/
            IF pr_inenvcob = 2 AND rw_crapcco.dsorgarq <> 'IMPRESSO PELO SOFTWARE' THEN
                -- Atribuir descrição da crítica
                vr_dscritic := 'Forma de envio de arquivo de cobrança não permitido para esta origem de convênio.';
                -- Levantar exceção
                RAISE vr_exc_saida;
            END IF;
        
            -- Valida intervalo de protesto
            IF pr_qtlimaxp < pr_qtlimmip THEN
                vr_dscritic := 'Data máxima de Intervalo de Protesto não pode ser menor que data mínima.';
                RAISE vr_exc_saida;
            END IF;
        
            -- Cadastro de bloquetos
            OPEN cr_crapceb(pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrconven => pr_nrconven);
            FETCH cr_crapceb
                INTO rw_crapceb;
            -- Alimenta a booleana se achou ou nao
            vr_blnfound := cr_crapceb%FOUND;
            -- Fecha cursor
            CLOSE cr_crapceb;
            -- Se NAO encontrou
        
            IF NOT vr_blnfound OR pr_blnewreg THEN
                -- setado como TRUE para contemplar a nova reciprocidade
            
                -- Se convenio esta desativado, e a situacao que esta sendo alterada eh para ativa-lo
                IF rw_crapcco.flgativo = 0 AND pr_insitceb = 1 THEN
                    vr_cdcritic := 949;
                    RAISE vr_exc_saida;
                END IF;
            
								-- Verifica se a nova reciprocidade esta ativa para a cooperativa informada
								IF fn_nova_reciprocidade(vr_cdcooper
			                                  ) THEN
									--
                BEGIN
								--
										INSERT INTO tbcobran_crapceb(cdcooper
                        ,nrdconta
                        ,nrconven
                        ,nrcnvceb
                        ,cdoperad
                        ,cdopeori
                        ,cdageori
                        ,idrecipr
											,dtinsori
											,insitceb
											)
																					VALUES(vr_cdcooper
                        ,pr_nrdconta
                        ,pr_nrconven
                        ,vr_nrcnvceb
                        ,vr_cdoperad
                        ,vr_cdoperad
                        ,vr_cdagenci
                        ,pr_idrecipr
											,SYSDATE
											,vr_insitceb
											);
									  --
									EXCEPTION
										WHEN OTHERS THEN
											vr_dscritic := 'Erro ao inserir o registro na CRAPCEB: ' || SQLERRM;
											RAISE vr_exc_saida;
									END;
							    --
								ELSE
									--
									BEGIN
										--
										INSERT INTO crapceb(cdcooper
																			 ,nrdconta
																			 ,nrconven
																			 ,nrcnvceb
																			 ,cdoperad
																			 ,cdopeori
																			 ,cdageori
																			 ,dtinsori
																			 )
																 VALUES(vr_cdcooper
																			 ,pr_nrdconta
																			 ,pr_nrconven
																			 ,vr_nrcnvceb
																			 ,vr_cdoperad
																			 ,vr_cdoperad
																			 ,vr_cdagenci
																			 ,SYSDATE
																			 );
										--
									EXCEPTION
										WHEN OTHERS THEN
											vr_dscritic := 'Erro ao inserir o registro na CRAPCEB: ' || SQLERRM;
											RAISE vr_exc_saida;
									END;
									--
								END IF;
                    -- Seta como registro novo
                    vr_blnewreg_cip := TRUE;
								--
            END IF;
        
            -- Verificar se o convenio esta sendo atualizado 
            IF NOT pr_blnewreg THEN
                -- Se convenio esta desativado, e a situacao que esta sendo alterada eh para ativa-lo
                IF rw_crapcco.flgativo = 0 AND -- Convenio Inativo
                   rw_crapceb.insitceb = 2 AND -- Convenio na conta do cooperado Inativo
                   pr_insitceb <> 2 THEN
                    -- Alterando a situacao do convenio para qualquer outra situacao
                    vr_cdcritic := 949;
                    RAISE vr_exc_saida;
                END IF;
            END IF;
        
            /**** - Tratamento CIP ****/
        
            --> Buscar situacao do benificiario na cip
            vr_insitif  := NULL;
            vr_insitcip := NULL;
            ddda0001.pc_ret_sit_beneficiario(pr_inpessoa => rw_crapass.inpessoa
                                            , --> Tipo de pessoa
                                             pr_nrcpfcgc => rw_crapass.nrcpfcgc
                                            , --> CPF/CNPJ do beneficiario
                                             pr_insitif  => vr_insitif
                                            , --> Retornar situação IF
                                             pr_insitcip => vr_insitcip
                                            , --> Retorna situação na CIP
                                             pr_dscritic => vr_dscritic); --> Retorna critica
            IF TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
            END IF;
        
            --> Se foi inclusao 
            IF (pr_blnewreg OR vr_blnewreg_cip) AND (nvl(vr_insitif, 'A') <> 'I' AND (vr_insitcip IS NULL OR vr_insitcip = 'A')) THEN
            
                vr_dsdtmvto := to_char(rw_crapdat.dtmvtolt, 'RRRRMMDD');
            
                --> Verificar se ja existe o beneficiario na cip
                OPEN cr_dda_benef(pr_dspessoa => rw_crapass.dspessoa, pr_nrcpfcgc => rw_crapass.nrcpfcgc);
                FETCH cr_dda_benef
                    INTO rw_dda_benef;
            
                IF cr_dda_benef%NOTFOUND THEN
                    IF rw_crapass.inpessoa = 2 THEN
                        --> Buscar dados pessoa juridica
                        OPEN cr_crapjur(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
                        FETCH cr_crapjur
                            INTO rw_crapjur;
                        CLOSE cr_crapjur;
                    END IF;
                
                    BEGIN
                        -- utilizar a data de admissao do cooperado como data de relacionamento
                        vr_dsdtmvto := to_char(nvl(rw_crapass.dtabtcct, rw_crapdat.dtmvtolt), 'RRRRMMDD');
                    
                        INSERT INTO cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
                            ("ISPB_IF"
                             ,"TpPessoaBenfcrio"
                             ,"CNPJ_CPFBenfcrio"
                             ,"Nom_RzSocBenfcrio"
                             ,"Nom_FantsBenfcrio"
                             ,"DtInicRelctPart"
                             ,"DtFimRelctPart")
                        VALUES
                            ('05463212' -- ISPB_IF
                            ,rw_crapass.dspessoa -- TpPessoaBenfcrio
                            ,rw_crapass.dscpfcgc -- CNPJ_CPFBenfcrio
                            ,rw_crapass.nmprimtl -- Nom_RzSocBenfcrio 
                            ,rw_crapjur.nmfansia -- Nom_FantsBenfcrio 
                            ,vr_dsdtmvto -- DtInicRelctPart    
                            ,NULL); -- DtFimRelctPart    
                    
                    EXCEPTION
                        WHEN dup_val_on_index THEN
                            vr_dscritic := 'CPF/CNPJ do Beneficiario ja cadastrado na CIP, favor verificar.';
                            RAISE vr_exc_saida;
                        WHEN OTHERS THEN
                            vr_dscritic := 'Nao foi possivel cadastrar Beneficiario na CIP: ' || SQLERRM;
                            RAISE vr_exc_saida;
                    END;
                END IF;
                CLOSE cr_dda_benef;
            
                --> Verificar se situacao permite continuar        
                IF vr_insitif IN ('A') OR
                  -- ou não houver sit IF porem ativo na CIP
                   (vr_insitif IS NULL AND vr_insitcip = 'A') OR
                  -- Ou ativo no IF e sem sit na CIP
                   (vr_insitif = 'A' AND vr_insitcip IS NULL) OR
                  -- Ou ainda nao existir situacao
                   (vr_insitif IS NULL AND vr_insitcip IS NULL) THEN
                
                    --> Gravar o log de adesao ou bloqueio do convenio
                    cobr0008.pc_gera_log_ceb(pr_idorigem => vr_idorigem
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_cdoperad => vr_cdoperad
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_nrconven => pr_nrconven
                                            ,pr_insitceb => 1
                                            , --'ATIVO'
                                             pr_dscritic => vr_dscritic);
                    IF vr_dscritic IS NOT NULL THEN
                        RAISE vr_exc_saida;
                    END IF;
                
                    vr_sitifcnv := 'A'; -- Apto
                
                    --SITIF => “I”, bloquear convênio de cobrança mostrando a mensagem no final: “Cobrança não liberada”;                          
                ELSIF vr_insitif = 'I' THEN
                
                    --> Gravar o log de adesao ou bloqueio do convenio
                    cobr0008.pc_gera_log_ceb(pr_idorigem => vr_idorigem
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_cdoperad => vr_cdoperad
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_nrconven => pr_nrconven
                                            ,pr_insitceb => 4
                                            , -- 'BLOQUEADO'
                                             pr_dscritic => vr_dscritic);
                    IF vr_dscritic IS NOT NULL THEN
                        RAISE vr_exc_saida;
                    END IF;
                
                    vr_cdcritic := 0;
                    vr_dscritic := 'Convênio de cobrança não liberado.';
                    RAISE vr_exc_saida;
                
                    -- Guardar variavel para atualizar crapceb
                    --vr_insitceb := 4; -- Bloqueado
                    --vr_sitifcnv := 'I'; -- Inativo
                    --vr_dtfimrel := to_char(rw_crapdat.dtmvtolt,'RRRRMMDD');
                
                    --> SITCIP => “I” ou “E” ou SITIF = "E", realizar o cadastro do convênio do cooperado com status “PENDENTE”;
                ELSIF vr_insitcip IN ('I', 'E') OR vr_insitif IN ('E') THEN
                
                    --> Gravar o log de adesao ou bloqueio do convenio
                    cobr0008.pc_gera_log_ceb(pr_idorigem => vr_idorigem
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_cdoperad => vr_cdoperad
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_nrconven => pr_nrconven
                                            ,pr_insitceb => 3
                                            , -- 'PENDENTE'
                                             pr_dscritic => vr_dscritic);
                    IF vr_dscritic IS NOT NULL THEN
                        RAISE vr_exc_saida;
                    END IF;
                
                    -- Guardar variavel para atualizar crapceb
                    vr_insitceb := 3; -- PENDENTE
                    vr_sitifcnv := 'A'; -- Ativo
                    vr_dtfimrel := NULL;
                    vr_flgimpri := 0;
                ELSE
                    vr_dscritic := 'Situacao invalida do Beneficiario na JDBNF1.';
                    RAISE vr_exc_saida;
                END IF;
            
                --> Verificar se ja existe o convenio na cip
                OPEN cr_dda_conven(pr_dspessoa => rw_crapass.dspessoa
                                  ,pr_nrcpfcgc => rw_crapass.nrcpfcgc
                                  ,pr_nrconven => to_char(pr_nrconven));
                FETCH cr_dda_conven
                    INTO rw_dda_conven;
                IF cr_dda_conven%NOTFOUND THEN
                    --> Gerar informação de adesão de convênio ao JDBNF                            
                    BEGIN
                    
                        vr_dsdtmvto := to_char(rw_crapdat.dtmvtolt, 'RRRRMMDD');
                    
                        INSERT INTO cecredleg.tbjdddabnf_convenio@jdnpcsql
                            ("ISPB_IF"
                             ,"ISPBPartIncorpd"
                             ,"TpPessoaBenfcrio"
                             ,"CNPJ_CPFBenfcrio"
                             ,"CodCli_Conv"
                             ,"SitConvBenfcrioPar"
                             ,"DtInicRelctConv"
                             ,"DtFimRelctConv"
                             ,"TpAgDest"
                             ,"AgDest"
                             ,"TpCtDest"
                             ,"CtDest"
                             ,"TpProdtConv"
                             ,"TpCartConvCobr")
                        VALUES
                            ('05463212'
                            , -- ISPB_IF
                             NULL
                            , -- ISPBPartIncorpd
                             rw_crapass.dspessoa
                            , -- TpPessoaBenfcrio
                             rw_crapass.dscpfcgc
                            , -- CNPJ_CPFBenfcrio
                             pr_nrconven
                            , -- CodCli_Conv
                             vr_sitifcnv
                            , -- SitConvBenfcrioPar
                             vr_dsdtmvto
                            , -- DtInicRelctConv
                             vr_dtfimrel
                            , -- DtFimRelctConv
                             'F'
                            , -- TpAgDest (F=Fisica)
                             rw_crapass.cdagectl
                            , -- AgDest
                             'CC'
                            , -- TpCtDest
                             rw_crapass.nrdconta
                            , -- CtDest
                             '01'
                            , -- boleto de cobranca             -- TpProdtConv
                             '1'); -- com registro                   -- TpCartConvCobr
                    EXCEPTION
                        WHEN OTHERS THEN
                            vr_dscritic := 'Nao foi possivel registrar convenio na CIP: ' || SQLERRM;
                            RAISE vr_exc_saida;
                    END;
                ELSE
                    BEGIN
                        vr_nrconven := to_char(pr_nrconven);
                    
                        UPDATE cecredleg.tbjdddabnf_convenio@jdnpcsql a
                           SET a."SitConvBenfcrioPar" = vr_sitifcnv
                               ,a."DtInicRelctConv"    = nvl(vr_dsdtmvto, a."DtInicRelctConv")
                               ,a."DtFimRelctConv"     = vr_dtfimrel
                         WHERE a."ISPB_IF" = '05463212'
                           AND a."TpPessoaBenfcrio" = rw_crapass.dspessoa
                           AND a."CNPJ_CPFBenfcrio" = rw_crapass.dscpfcgc
                           AND a."CodCli_Conv" = vr_nrconven;
                    EXCEPTION
                        WHEN OTHERS THEN
                            vr_dscritic := 'Nao foi possivel atualizar convenio na CIP: ' || SQLERRM;
                            RAISE vr_exc_saida;
                    END;
                END IF;
                CLOSE cr_dda_conven;
            
                --> senao é manutencao  
            ELSE
                IF (rw_crapceb.flprotes = 0 AND pr_flprotes = 1) THEN
                
                    --> Gravar o log atenda - cobram - log, registrando o cancelamento do serviço de protesto
                    cobr0008.pc_gera_log_ceb(pr_idorigem     => vr_idorigem
                                            ,pr_cdcooper     => vr_cdcooper
                                            ,pr_cdoperad     => vr_cdoperad
                                            ,pr_nrdconta     => pr_nrdconta
                                            ,pr_nrconven     => pr_nrconven
                                            ,pr_dstransa     => 'Ativacao do servico de protesto'
                                            ,pr_insitceb_ant => nvl(rw_crapceb.insitceb, 0)
                                            , --Antes de alterar
                                             pr_insitceb     => vr_insitceb
                                            ,pr_dscritic     => vr_dscritic);
                
                    -- Efetua os inserts para apresentacao na tela VERLOG
                    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                        ,pr_cdoperad => vr_cdoperad
                                        ,pr_dscritic => ' '
                                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                                        ,pr_dstransa => 'Ativacao do servico de protesto'
                                        ,pr_dttransa => trunc(SYSDATE)
                                        ,pr_flgtrans => 1
                                        ,pr_hrtransa => to_char(SYSDATE, 'SSSSS')
                                        ,pr_idseqttl => 1
                                        ,pr_nmdatela => 'ATENDA'
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdrowid => vr_nrdrowid);
                    IF vr_dscritic IS NOT NULL THEN
                        RAISE vr_exc_saida;
                    END IF;
                
                ELSIF (rw_crapceb.flprotes = 1 AND pr_flprotes = 0) THEN
                
                    -- Gera Pendencia de digitalizacao do documento
                    digi0001.pc_grava_pend_digitalizacao(pr_cdcooper => vr_cdcooper
                                                        ,pr_nrdconta => pr_nrdconta
                                                        ,pr_idseqttl => 1
                                                        ,pr_nrcpfcgc => rw_crapass.nrcpfcgc
                                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                        ,pr_tpdocmto => 57 -- Termo de Cancelamento do protesto
                                                        ,pr_cdoperad => vr_cdoperad
                                                        ,pr_nrseqdoc => pr_nrconven
                                                        ,pr_cdcritic => vr_cdcritic
                                                        ,pr_dscritic => vr_dscritic);
                
                    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                        RAISE vr_exc_saida;
                    END IF;
                
                    --> Gravar o log atenda - cobram - log, registrando o cancelamento do serviço de protesto
                    cobr0008.pc_gera_log_ceb(pr_idorigem     => vr_idorigem
                                            ,pr_cdcooper     => vr_cdcooper
                                            ,pr_cdoperad     => vr_cdoperad
                                            ,pr_nrdconta     => pr_nrdconta
                                            ,pr_nrconven     => pr_nrconven
                                            ,pr_dstransa     => 'Cancelamento do servico de protesto'
                                            ,pr_insitceb_ant => nvl(rw_crapceb.insitceb, 0)
                                            , --Antes de alterar
                                             pr_insitceb     => vr_insitceb
                                            ,pr_dscritic     => vr_dscritic);
                
                    -- Efetua os inserts para apresentacao na tela VERLOG
                    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                        ,pr_cdoperad => vr_cdoperad
                                        ,pr_dscritic => ' '
                                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                                        ,pr_dstransa => 'Cancelamento do servico de protesto'
                                        ,pr_dttransa => trunc(SYSDATE)
                                        ,pr_flgtrans => 1
                                        ,pr_hrtransa => to_char(SYSDATE, 'SSSSS')
                                        ,pr_idseqttl => 1
                                        ,pr_nmdatela => 'ATENDA'
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdrowid => vr_nrdrowid);
                    IF vr_dscritic IS NOT NULL THEN
                        RAISE vr_exc_saida;
                    END IF;
                    -- END IF;
                    --> Verificar se situacao permite continuar
                    --A=Apto, I=Inapto, E=Em análise
                ELSIF vr_insitif IN ('A', 'E') THEN
                    --> Evitar problema quando procedure é chamada dentro de um loop (gerando violacao de PK pela data/hora)
                    -- dbms_lock.sleep(1);
                    cobr0004.pc_espera_segundo(1);
                    --> Gravar o log de adesao ou bloqueio do convenio
                    cobr0008.pc_gera_log_ceb(pr_idorigem     => vr_idorigem
                                            ,pr_cdcooper     => vr_cdcooper
                                            ,pr_cdoperad     => vr_cdoperad
                                            ,pr_nrdconta     => pr_nrdconta
                                            ,pr_nrconven     => pr_nrconven
                                            ,pr_dstransa     => 'Manutencao do convenio de cobranca'
                                            ,pr_insitceb_ant => nvl(rw_crapceb.insitceb, 0)
                                            , --Antes de alterar
                                             pr_insitceb     => 1
                                            , -- 'ATIVO'
                                             pr_dscritic     => vr_dscritic);
                    IF vr_dscritic IS NOT NULL THEN
                        RAISE vr_exc_saida;
                    END IF;
                
                    --> SITIF => “I”, convênio de cobrança inapto; Deverá ser bloqueado;
                ELSIF vr_insitif = 'I' THEN
                    --> Evitar problema quando procedure é chamada dentro de um loop (gerando violacao de PK pela data/hora)
                    -- dbms_lock.sleep(1);
                    cobr0004.pc_espera_segundo(1);
                    --> Gravar o log de adesao ou bloqueio do convenio
                    cobr0008.pc_gera_log_ceb(pr_idorigem     => vr_idorigem
                                            ,pr_cdcooper     => vr_cdcooper
                                            ,pr_cdoperad     => vr_cdoperad
                                            ,pr_nrdconta     => pr_nrdconta
                                            ,pr_nrconven     => pr_nrconven
                                            ,pr_dstransa     => 'Manutencao do convenio de cobranca'
                                            ,pr_insitceb_ant => nvl(rw_crapceb.insitceb, 0)
                                            , --Antes de alterar
                                             pr_insitceb     => 4
                                            , -- 'Bloqueado'
                                             pr_dscritic     => vr_dscritic);
                    IF vr_dscritic IS NOT NULL THEN
                        RAISE vr_exc_saida;
                    END IF;
                
                    vr_cdcritic := 0;
                    vr_dscritic := 'Convênio de cobrança não liberado.';
                    RAISE vr_exc_saida;
                
                    -- Guardar variavel para atualizar crapceb
                    -- vr_insitceb := 4; -- Bloqueado
                
                ELSIF (vr_insitcip IN ('I', 'E') OR vr_insitcip IS NULL) THEN
                    --> Evitar problema quando procedure é chamada dentro de um loop (gerando violacao de PK pela data/hora)
                    -- dbms_lock.sleep(1);
                    cobr0004.pc_espera_segundo(1);
                    --> Gravar o log de adesao ou bloqueio do convenio
                    cobr0008.pc_gera_log_ceb(pr_idorigem     => vr_idorigem
                                            ,pr_cdcooper     => vr_cdcooper
                                            ,pr_cdoperad     => vr_cdoperad
                                            ,pr_nrdconta     => pr_nrdconta
                                            ,pr_nrconven     => pr_nrconven
                                            ,pr_dstransa     => 'Manutencao do convenio de cobranca'
                                            ,pr_insitceb_ant => nvl(rw_crapceb.insitceb, 0)
                                            , --Antes de alterar
                                             pr_insitceb     => 1
                                            , -- 'ATIVO'
                                             pr_dscritic     => vr_dscritic);
                    IF vr_dscritic IS NOT NULL THEN
                        RAISE vr_exc_saida;
                    END IF;
                
                    vr_flgimpri := 0; -- nao imprimir o termo de adesao
                
                ELSE
                    vr_dscritic := 'Situacao invalida do Beneficiario na JDBNF2.';
                    RAISE vr_exc_saida;
                END IF;
            
            END IF;
        
            /**** Fim Tratamento CIP ****/
        
            BEGIN
							--
                UPDATE crapceb
                   SET crapceb.dtcadast = rw_crapdat.dtmvtolt
                      ,crapceb.inarqcbr = pr_inarqcbr
                      ,crapceb.cddemail = decode(pr_inarqcbr, 0, 0, pr_cddemail)
                      ,crapceb.flgcruni = pr_flgcruni
                      ,crapceb.flgcebhm = pr_flgcebhm
                      ,crapceb.flgregon = pr_flgregon
                      ,crapceb.flgpgdiv = pr_flgpgdiv
                      ,crapceb.flcooexp = pr_flcooexp
                      ,crapceb.flceeexp = pr_flceeexp
                      ,crapceb.flserasa = pr_flserasa
                      ,crapceb.insitceb = vr_insitceb
                      ,crapceb.cdhomolo = vr_cdoperad
                      -- Rafael Ferreira (Mouts) -- INC0020100 - Se por algum motivo vier zero utiliza o Default da crapcco
                      ,crapceb.qtdfloat = decode(nvl(pr_qtdfloat,0), 0, vr_qtdfloat, pr_qtdfloat)
                      ,crapceb.flprotes = pr_flprotes
                      ,crapceb.insrvprt = pr_insrvprt
                      ,crapceb.qtlimaxp = pr_qtlimaxp
                      ,crapceb.qtlimmip = pr_qtlimmip
                      -- Rafael Ferreira (Mouts) -- INC0020100 - Se por algum motivo vier zero utiliza o Default da crapcco
                      ,crapceb.qtdecprz = decode(nvl(pr_qtdecprz,0), 0, vr_qtdecini, pr_qtdecprz)
                      ,crapceb.inenvcob = pr_inenvcob
                      ,crapceb.flgapihm = pr_flgapihm
                      --,crapceb.cdhomapi = decode(rw_crapceb.flgapihm, pr_flgapihm, rw_crapceb.cdhomapi, vr_cdoperad)
                      --,crapceb.dhhomapi = decode(rw_crapceb.flgapihm, pr_flgapihm, rw_crapceb.dhhomapi, SYSDATE)
                 WHERE crapceb.cdcooper = vr_cdcooper
                   AND crapceb.nrdconta = pr_nrdconta
                   AND crapceb.nrconven = pr_nrconven
                   AND crapceb.idrecipr = pr_idrecipr;
                   
            -- Rafael Ferreira (Mouts) - INC0020100
            -- Ajustada Logica da atualização de informações de homologação API
            IF (trim(rw_crapceb.cdhomapi) is null) and (pr_flgapihm = 1) THEN
              UPDATE crapceb crapceb
								 SET crapceb.cdhomapi = vr_cdoperad
                    ,crapceb.dhhomapi = SYSDATE
               WHERE crapceb.cdcooper = vr_cdcooper
								 AND crapceb.nrdconta = pr_nrdconta
								 AND crapceb.nrconven = pr_nrconven
								 AND crapceb.idrecipr = pr_idrecipr;
            END IF;

              --
                                     
            EXCEPTION
                WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao alterar o registro na CRAPCEB: ' || SQLERRM;
                    RAISE vr_exc_saida;
            END;
						--
						BEGIN
							--
							UPDATE tbcobran_crapceb crapceb
								 SET crapceb.dtcadast = rw_crapdat.dtmvtolt
										,crapceb.inarqcbr = pr_inarqcbr
										,crapceb.cddemail = decode(pr_inarqcbr, 0, 0, pr_cddemail)
										,crapceb.flgcruni = pr_flgcruni
										,crapceb.flgcebhm = pr_flgcebhm
										,crapceb.flgregon = pr_flgregon
										,crapceb.flgpgdiv = pr_flgpgdiv
										,crapceb.flcooexp = pr_flcooexp
										,crapceb.flceeexp = pr_flceeexp
										,crapceb.flserasa = pr_flserasa
										,crapceb.insitceb = vr_insitceb
										,crapceb.cdhomolo = vr_cdoperad
                    -- Rafael Ferreira (Mouts) -- INC0020100 - Se por algum motivo vier zero utiliza o Default da crapcco
										,crapceb.qtdfloat = decode(nvl(pr_qtdfloat,0), 0, vr_qtdfloat, pr_qtdfloat)
										,crapceb.flprotes = pr_flprotes
										,crapceb.insrvprt = pr_insrvprt
										,crapceb.qtlimaxp = pr_qtlimaxp
										,crapceb.qtlimmip = pr_qtlimmip
                    -- Rafael Ferreira (Mouts) -- INC0020100 - Se por algum motivo vier zero utiliza o Default da crapcco
										,crapceb.qtdecprz = decode(nvl(pr_qtdecprz,0), 0, vr_qtdecini, pr_qtdecprz)
										,crapceb.inenvcob = pr_inenvcob
										,crapceb.flgapihm = pr_flgapihm
                    --,crapceb.cdhomapi = decode(rw_crapceb.flgapihm, pr_flgapihm, rw_crapceb.cdhomapi, vr_cdoperad)
                    --,crapceb.dhhomapi = decode(rw_crapceb.flgapihm, pr_flgapihm, rw_crapceb.dhhomapi, SYSDATE)
							 WHERE crapceb.cdcooper = vr_cdcooper
								 AND crapceb.nrdconta = pr_nrdconta
								 AND crapceb.nrconven = pr_nrconven
								 AND crapceb.idrecipr = pr_idrecipr;
            
            -- Rafael Ferreira (Mouts) - INC0020100
            -- Ajustada Logica da atualização de informações de homologação API
            IF (trim(rw_crapceb.cdhomapi) is null) and (pr_flgapihm = 1) THEN
              UPDATE tbcobran_crapceb crapceb
								 SET crapceb.cdhomapi = vr_cdoperad
                    ,crapceb.dhhomapi = SYSDATE
               WHERE crapceb.cdcooper = vr_cdcooper
								 AND crapceb.nrdconta = pr_nrdconta
								 AND crapceb.nrconven = pr_nrconven
								 AND crapceb.idrecipr = pr_idrecipr;
            END IF;
							--
						EXCEPTION
							WHEN OTHERS THEN
								vr_dscritic := 'Erro ao alterar o registro na TBCOBRAN_CRAPCEB: ' || SQLERRM;
								RAISE vr_exc_saida;
						END;
        
            -- Verifica se a nova reciprocidade esta ativa para a cooperativa informada
						IF fn_nova_reciprocidade(vr_cdcooper
																		) THEN
						-- Verifica se está ativo e joga para a CRAPCEB
						IF vr_insitceb IN(1, 5) THEN
							--
							pc_grava_principal_crapceb(pr_cdcooper => vr_cdcooper -- IN
																			  ,pr_nrdconta => pr_nrdconta -- IN
																			  ,pr_nrconven => pr_nrconven -- IN
																			  ,pr_nrcnvceb => vr_nrcnvceb -- IN
																			  ,pr_insitceb => NULL        -- IN
																			  ,pr_dscritic => vr_dscritic -- OUT
																			  );
              --
							IF vr_dscritic IS NOT NULL THEN
								--
								RAISE vr_exc_saida;
								--
							END IF;
							--
						ELSE
							--
							IF pr_blnewreg THEN
								--
								pc_grava_auxiliar_crapceb(pr_cdcooper => vr_cdcooper -- IN
																				 ,pr_nrdconta => pr_nrdconta -- IN
																				 ,pr_nrconven => pr_nrconven -- IN
																				 ,pr_nrcnvceb => vr_nrcnvceb -- IN
																				 ,pr_insitceb => NULL        -- IN
																				 ,pr_dscritic => vr_dscritic -- OUT
																				 );
								--
								IF vr_dscritic IS NOT NULL THEN
									--
									RAISE vr_exc_saida;
										--
									END IF;
									--
								END IF;
								--
							END IF;
							--
						END IF;
            -- Remove os registros para depois incluir
            BEGIN
                DELETE FROM tbcobran_categ_tarifa_conven
                 WHERE tbcobran_categ_tarifa_conven.cdcooper = vr_cdcooper
                   AND tbcobran_categ_tarifa_conven.nrdconta = pr_nrdconta
                   AND tbcobran_categ_tarifa_conven.nrconven = pr_nrconven;
            EXCEPTION
                WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao excluir o registro na TBCOBRAN_CATEG_TARIFA_CONVEN: ' || SQLERRM;
                    RAISE vr_exc_saida;
            END;
        
            -- Separar a lista de codigos de categoria e percentual de desconto
            vr_lstdados := gene0002.fn_quebra_string(pr_string => pr_perdesconto, pr_delimit => '|');
            FOR vr_idx IN 1 .. vr_lstdados.count LOOP
                vr_lstdado2 := gene0002.fn_quebra_string(pr_string => vr_lstdados(vr_idx), pr_delimit => '#');
                vr_cdcatego := vr_lstdado2(1);
                vr_percdesc := vr_lstdado2(2);
            
                BEGIN
                    INSERT INTO tbcobran_categ_tarifa_conven
                        (cdcooper, nrdconta, nrconven, cdcatego, perdesconto)
                    VALUES
                        (vr_cdcooper, pr_nrdconta, pr_nrconven, vr_cdcatego, vr_percdesc);
                EXCEPTION
                    WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao inserir o registro na TBCOBRAN_CATEG_TARIFA_CONVEN: ' ||
                                       SQLERRM;
                        RAISE vr_exc_saida;
                END;
            END LOOP;
        
            -- Se houve alteracao no calculo devemos cancelar o periodo de apuracao em aberto
            IF pr_idreciprold <> pr_idrecipr AND pr_idreciprold > 0 THEN
            
                -- Busca periodo de apuracao da Reciprocidade
                OPEN cr_apuracao(pr_nrconven => pr_nrconven, pr_idrecipr => pr_idreciprold);
                FETCH cr_apuracao
                    INTO rw_apuracao;
                -- Alimenta a booleana se achou ou nao
                vr_blnfound := cr_apuracao%FOUND;
                -- Fecha cursor
                CLOSE cr_apuracao;
                -- Se encontrou
                IF vr_blnfound THEN
                    -- Configuracao para calculo de Reciprocidade
                    FOR rw_indicador IN cr_indicador(pr_idapuracao_reciproci => rw_apuracao.idapuracao_reciproci) LOOP
                        -- Acionamos a rotina que calculara o apurador e atualizara seu valor realizado parcialmente
                        rcip0001.pc_calcula_recipro_atingida(pr_cdcooper           => vr_cdcooper
                                                            ,pr_nrdconta           => pr_nrdconta
                                                            ,pr_idapuracao         => rw_apuracao.idapuracao_reciproci
                                                            ,pr_idindicador        => rw_indicador.idindicador
                                                            ,pr_dtinicio_apuracao  => rw_apuracao.dtinicio_apuracao
                                                            ,pr_dttermino_apuracao => rw_apuracao.dttermino_apuracao
                                                            ,pr_idconfig_recipro   => rw_apuracao.idconfig_recipro
                                                            ,pr_tpreciproci        => rw_apuracao.tpreciproci
                                                            ,pr_tpindicador        => rw_indicador.tpindicador
                                                            ,pr_flgatingido        => vr_flgatingido
                                                            ,pr_descr_error        => vr_dscritic);
                        -- Se encontrou erro
                        IF vr_dscritic IS NOT NULL THEN
                            RAISE vr_exc_saida;
                        END IF;
                    END LOOP;
                
                    BEGIN
                        UPDATE tbrecip_apuracao
                           SET indsituacao_apuracao = 'C' -- Cancelada
                              ,dtcancela_apuracao   = SYSDATE
                              ,perrecipro_atingida  = 0 -- Sempre zero em cancelamento
                              ,flgtarifa_debitada   = 0 -- Sempre nao em cancelamento
                              ,flgtarifa_revertida  = 0 -- Sempre nao em cancelamento
                         WHERE idapuracao_reciproci = rw_apuracao.idapuracao_reciproci;
                    EXCEPTION
                        WHEN OTHERS THEN
                            vr_dscritic := 'Erro ao alterar o registro na TBRECIP_APURACAO: ' || SQLERRM;
                            RAISE vr_exc_saida;
                    END;
                END IF;
            
            END IF;
        
            -- ATENCAO! As 8 posicoes destinadas ao numero do convenio
            -- no log de inclusao, estao sendo utilizadas na tela CONGPR.
            -- Se houver alteracao neste log a tela devera ser corrigida.
            IF pr_blnewreg THEN
                vr_dstransa := 'Incluir convenio de cobranca ' ||
                               to_char(gene0002.fn_mask(rw_crapcco.nrconven, 'zzzzzzz9')) || '.';
                -- Se possuir Numero do Convenio CECRED
                IF vr_nrcnvceb > 0 THEN
                    vr_dsdmesag := 'Convenio CEB de numero ' ||
                                   to_char(gene0002.fn_mask(vr_nrcnvceb, 'zzz,zz9')) ||
                                   ' habilitado com sucesso!';
                END IF;
            ELSE
                vr_dstransa := 'Alterar convenio de cobranca ' ||
                               to_char(gene0002.fn_mask(rw_crapcco.nrconven, 'zzzzzzz9')) || '.';
            END IF;
        
            -- Gerar informacoes do log
            gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => ' '
                                ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                                ,pr_dstransa => vr_dstransa
                                ,pr_dttransa => trunc(SYSDATE)
                                ,pr_flgtrans => 1 --> TRUE
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => 'COBRANCA'
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
        
            -- Se for inclusao
            IF pr_blnewreg THEN
                -- Numero convenio
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'nrconven'
                                         ,pr_dsdadant => NULL
                                         ,pr_dsdadatu => pr_nrconven);
                -- Convenio CEB
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'nrcnvceb'
                                         ,pr_dsdadant => NULL
                                         ,pr_dsdadatu => vr_nrcnvceb);
            END IF;
        
            -- Se alterou Situacao CEB
            IF rw_crapceb.insitceb <> pr_insitceb THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'insitceb'
                                         ,pr_dsdadant => CASE
                                                             WHEN rw_crapceb.insitceb = 1 THEN
                                                              'ATIVO'
                                                             ELSE
                                                              'INATIVO'
                                                         END
                                         ,pr_dsdadatu => CASE
                                                             WHEN pr_insitceb = 1 THEN
                                                              'ATIVO'
                                                             ELSE
                                                              'INATIVO'
                                                         END);
            END IF;
        
            -- Se alterou Registro de Titulo Online
            IF rw_crapceb.flgregon <> pr_flgregon THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'flgregon'
                                         ,pr_dsdadant => CASE
                                                             WHEN rw_crapceb.flgregon = 1 THEN
                                                              'ATIVO'
                                                             ELSE
                                                              'INATIVO'
                                                         END
                                         ,pr_dsdadatu => CASE
                                                             WHEN pr_flgregon = 1 THEN
                                                              'ATIVO'
                                                             ELSE
                                                              'INATIVO'
                                                         END);
            END IF;
        
            -- Se alterou Autorizacao de Pagamento Divergente
            IF rw_crapceb.flgpgdiv <> pr_flgpgdiv THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'flgpgdiv'
                                         ,pr_dsdadant => CASE
                                                             WHEN rw_crapceb.flgpgdiv = 1 THEN
                                                              'ATIVO'
                                                             ELSE
                                                              'INATIVO'
                                                         END
                                         ,pr_dsdadatu => CASE
                                                             WHEN pr_flgpgdiv = 1 THEN
                                                              'ATIVO'
                                                             ELSE
                                                              'INATIVO'
                                                         END);
            END IF;
        
            -- Se alterou Cooperado Emite e Expede
            IF rw_crapceb.flcooexp <> pr_flcooexp THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'flcooexp'
                                         ,pr_dsdadant => CASE
                                                             WHEN rw_crapceb.flcooexp = 1 THEN
                                                              'ATIVO'
                                                             ELSE
                                                              'INATIVO'
                                                         END
                                         ,pr_dsdadatu => CASE
                                                             WHEN pr_flcooexp = 1 THEN
                                                              'ATIVO'
                                                             ELSE
                                                              'INATIVO'
                                                         END);
            END IF;
        
            -- Se alterou Cooperativa Emite e Expede
            IF rw_crapceb.flceeexp <> pr_flceeexp THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'flceeexp'
                                         ,pr_dsdadant => CASE
                                                             WHEN rw_crapceb.flceeexp = 1 THEN
                                                              'ATIVO'
                                                             ELSE
                                                              'INATIVO'
                                                         END
                                         ,pr_dsdadatu => CASE
                                                             WHEN pr_flceeexp = 1 THEN
                                                              'ATIVO'
                                                             ELSE
                                                              'INATIVO'
                                                         END);
            END IF;
        
            -- Se alterou Envio de Protesto
            IF rw_crapceb.flprotes <> pr_flprotes THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'Envio de Protesto'
                                         ,pr_dsdadant => CASE
                                                             WHEN rw_crapceb.flprotes = 1 THEN
                                                              'ATIVO'
                                                             ELSE
                                                              'INATIVO'
                                                         END
                                         ,pr_dsdadatu => CASE
                                                             WHEN pr_flprotes = 1 THEN
                                                              'ATIVO'
                                                             ELSE
                                                              'INATIVO'
                                                         END);
            END IF;
        
			-- Se alterou Homologado API
            IF rw_crapceb.flgapihm <> pr_flgapihm AND vr_blnfound THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'Homologado API'
                                         ,pr_dsdadant => CASE
                                                             WHEN rw_crapceb.flgapihm = 1 THEN
                                                              'SIM'
                                                             ELSE
                                                              'NAO'
                                                         END
                                         ,pr_dsdadatu => CASE
                                                             WHEN pr_flgapihm = 1 THEN
                                                              'SIM'
                                                             ELSE
                                                              'NAO'
                                                         END);
             END IF;
        
            -- Se alterou o Serviço de Protesto
            IF rw_crapceb.insrvprt <> pr_insrvprt THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'Serviço de Protesto'
                                         ,pr_dsdadant => rw_crapceb.insrvprt
                                         ,pr_dsdadatu => pr_insrvprt);
            END IF;
        
            -- Se a quantidade de dias para poder protestar
            IF rw_crapceb.qtlimmip <> pr_qtlimmip THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'Quantidade de dias para poder protestar'
                                         ,pr_dsdadant => rw_crapceb.qtlimmip
                                         ,pr_dsdadatu => pr_qtlimmip);
            END IF;
        
            -- Se o limite a maximo de dias para pode protestar
            IF rw_crapceb.qtlimaxp <> pr_qtlimaxp THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'Limite a maximo de dias para pode protestar'
                                         ,pr_dsdadant => rw_crapceb.qtlimaxp
                                         ,pr_dsdadatu => pr_qtlimaxp);
            END IF;
        
            -- Se alterou Float a aplicar
            IF rw_crapceb.qtdfloat <> pr_qtdfloat THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'Float a aplicar'
                                         ,pr_dsdadant => rw_crapceb.qtdfloat
                                         ,pr_dsdadatu => pr_qtdfloat);
            END IF;
        
            -- Se alterou Decurso de Prazo
            IF rw_crapceb.qtdecprz <> pr_qtdecprz THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'Decurso de Prazo'
                                         ,pr_dsdadant => rw_crapceb.qtdecprz
                                         ,pr_dsdadatu => pr_qtdecprz);
            END IF;
        
            -- Se alterou Arquivo Retorno
            IF rw_crapceb.inarqcbr <> pr_inarqcbr THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'inarqcbr'
                                         ,pr_dsdadant => rw_crapceb.inarqcbr
                                         ,pr_dsdadatu => pr_inarqcbr);
            END IF;
        
            -- Se alterou Email retorno
            IF rw_crapceb.cddemail <> pr_cddemail THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'cddemail'
                                         ,pr_dsdadant => rw_crapceb.cddemail
                                         ,pr_dsdadatu => pr_cddemail);
            END IF;
        
            -- Se alterou Credito Unificado
            IF rw_crapceb.flgcruni <> pr_flgcruni THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'flgcruni'
                                         ,pr_dsdadant => CASE
                                                             WHEN rw_crapceb.flgcruni = 1 THEN
                                                              'SIM'
                                                             ELSE
                                                              'NAO'
                                                         END
                                         ,pr_dsdadatu => CASE
                                                             WHEN pr_flgcruni = 1 THEN
                                                              'SIM'
                                                             ELSE
                                                              'NAO'
                                                         END);
            END IF;
        
            -- Se alterou Forma de envio de arquivo de cobrança
            IF rw_crapceb.inenvcob <> pr_inenvcob THEN
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'inenvcob'
                                         ,pr_dsdadant => CASE
                                                             WHEN rw_crapceb.inenvcob = 1 THEN
                                                              'INTERNET BANK'
                                                             ELSE
                                                              'FTP'
                                                         END
                                         ,pr_dsdadatu => CASE
                                                             WHEN pr_inenvcob = 1 THEN
                                                              'INTERNET BANK'
                                                             ELSE
                                                              'FTP'
                                                         END);
            END IF;
        
            -- Gera log das categorias e percentual de desconto
            FOR vr_idx IN 1 .. vr_lstdados.count LOOP
                vr_lstdado2 := gene0002.fn_quebra_string(pr_string => vr_lstdados(vr_idx), pr_delimit => '#');
                vr_cdcatego := vr_lstdado2(1);
                vr_percdesc := vr_lstdado2(2);
            
                -- Busca a categoria
                OPEN cr_crapcat(pr_cdcatego => vr_cdcatego);
                FETCH cr_crapcat
                    INTO rw_crapcat;
                CLOSE cr_crapcat;
            
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => rw_crapcat.dscatego
                                         ,pr_dsdadant => NULL
                                         ,pr_dsdadatu => vr_percdesc);
            END LOOP;
        
            -- Se alterou Situacao CEB
            IF rw_crapceb.insitceb <> pr_insitceb THEN
                vr_dstransa := 'Convenio ' || (CASE
                                   WHEN pr_insitceb = 1 THEN
                                    'ativado'
                                   ELSE
                                    'desativado'
                               END) || ' pelo operador ' || vr_cdoperad || ' - ' || rw_crapope.nmoperad;
            
                -- Gerar informacoes do log
                gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => ' '
                                    ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                                    ,pr_dstransa => vr_dstransa
                                    ,pr_dttransa => trunc(SYSDATE)
                                    ,pr_flgtrans => 1 --> TRUE
                                    ,pr_hrtransa => gene0002.fn_busca_time
                                    ,pr_idseqttl => 1
                                    ,pr_nmdatela => 'COBRANCA'
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrdrowid => vr_nrdrowid);
                -- Situacao CEB
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                         ,pr_nmdcampo => 'insitceb'
                                         ,pr_dsdadant => CASE
                                                             WHEN rw_crapceb.insitceb = 1 THEN
                                                              'ATIVO'
                                                             ELSE
                                                              'INATIVO'
                                                         END
                                         ,pr_dsdadatu => CASE
                                                             WHEN pr_insitceb = 1 THEN
                                                              'ATIVO'
                                                             ELSE
                                                              'INATIVO'
                                                         END);
            END IF;
        
            --> Verificar se esta bloqueada
            IF vr_insitceb = 4 THEN
                vr_dsdmesag := 'Cobrança não liberada';
                --> Pendente  
            ELSIF vr_insitceb = 3 THEN
                --> Enviar email de convenio pendente
                ddda0001.pc_email_alert_jdbnf(pr_cdcooper => vr_cdcooper
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_nrconven => pr_nrconven
                                             ,pr_nrcnvceb => vr_nrcnvceb
                                             ,pr_tpalerta => 1
                                             , --> Convenio pendente
                                              pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
                vr_cdcritic := 0;
                vr_dscritic := 0;
                vr_dsdmesag := 'Adesão do produto em análise na AILOS. Dúvidas, entre em contato ' ||
                               'com a área de cobrança bancária.';
            END IF;
        
            COMMIT;
            npcb0002.pc_libera_sessao_sqlserver_npc('TELA_ATENDA_COBRAN_4');
        
        EXCEPTION
            WHEN vr_exc_saida THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
                pr_des_erro := vr_dscritic;
            
                ROLLBACK;
                npcb0002.pc_libera_sessao_sqlserver_npc('TELA_ATENDA_COBRAN_5');
            
                -- Gerar informacoes do log
                gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                                    ,pr_dstransa => 'Incluir/Alterar convenio de cobranca'
                                    ,pr_dttransa => trunc(SYSDATE)
                                    ,pr_flgtrans => 0 --> FALSE
                                    ,pr_hrtransa => gene0002.fn_busca_time
                                    ,pr_idseqttl => 1
                                    ,pr_nmdatela => 'COBRANCA'
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrdrowid => vr_nrdrowid);
            
                IF cr_dda_benef%ISOPEN THEN
                    CLOSE cr_dda_benef;
                END IF;
                IF cr_dda_conven%ISOPEN THEN
                    CLOSE cr_dda_conven;
                END IF;
            
                COMMIT;
            
            WHEN OTHERS THEN
                pr_des_erro := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;
            
                IF cr_dda_benef%ISOPEN THEN
                    CLOSE cr_dda_benef;
                END IF;
                IF cr_dda_conven%ISOPEN THEN
                    CLOSE cr_dda_conven;
                END IF;
            
                ROLLBACK;
                npcb0002.pc_libera_sessao_sqlserver_npc('TELA_ATENDA_COBRAN_6');
        END;
    
    END pc_habilita_convenio;

    PROCEDURE pc_habilita_convenio_web(pr_nrdconta    IN crapceb.nrdconta%TYPE --> Conta
                                      ,pr_nrconven    IN crapceb.nrconven%TYPE --> Convenio
                                      ,pr_insitceb    IN crapceb.insitceb%TYPE --> Situacao do Convenio
                                      ,pr_inarqcbr    IN crapceb.inarqcbr%TYPE --> Recebe Arquivo Retorno
                                      ,pr_cddemail    IN crapceb.cddemail%TYPE --> Email Arquivo de Retorno
                                      ,pr_flgcruni    IN crapceb.flgcruni%TYPE --> Credito Unificado
                                      ,pr_flgcebhm    IN crapceb.flgcebhm%TYPE --> Contem o convenio homologado
                                      ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Sequencia Titular
                                      ,pr_flgregon    IN crapceb.flgregon%TYPE --> Flag de registro de titulo online (0-Nao/1-Sim)
                                      ,pr_flgpgdiv    IN crapceb.flgpgdiv%TYPE --> Flag de autorizacao de pagamento divergente (0-Nao/ 1-Sim)
                                      ,pr_flcooexp    IN crapceb.flcooexp%TYPE --> Cooperado Emite e Expede Boletos
                                      ,pr_flceeexp    IN crapceb.flceeexp%TYPE --> Cooperativa Emite e Expede Boletos
                                      ,pr_flserasa    IN crapceb.flserasa%TYPE --> Pode negativar no Serasa
                                      ,pr_qtdfloat    IN crapceb.qtdfloat%TYPE --> Quantidade de dias para o Float
                                      ,pr_flprotes    IN crapceb.flprotes%TYPE --> Liberacao da opcao de Protesto na Cobranca
                                      ,pr_insrvprt    IN crapceb.insrvprt%TYPE --> Serviço de Protesto
                                      ,pr_qtlimaxp    IN crapceb.qtlimaxp%TYPE --> Limite a maximo de dias para pode protestar
                                      ,pr_qtlimmip    IN crapceb.qtlimmip%TYPE --> Quantidade de dias para poder protestar
                                      ,pr_qtdecprz    IN crapceb.qtdecprz%TYPE --> Quantidade de dias para Decurso de Prazo
                                      ,pr_idrecipr    IN crapceb.idrecipr%TYPE --> ID unico do calculo de reciprocidade atrelado a contratacao
                                      ,pr_idreciprold IN crapceb.idrecipr%TYPE --> ID unico do calculo de reciprocidade atrelado a contratacao
                                      ,pr_perdesconto IN VARCHAR2 --> Categoria e valor do desconto
                                      ,pr_inenvcob    IN crapceb.inenvcob%TYPE --> Forma de envio de arquivo de cobrança
                                      ,pr_flgapihm    IN crapceb.flgapihm%TYPE --> Flag representando o uso da API
                                      ,pr_xmllog      IN VARCHAR2 --> XML com informacoes de LOG
                                      ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                                      ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                                      ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_habilita_convenio_web
        Sistema : Ayllos Web
        Autor   : Augusto (Supero)
        Data    : Junho/2018                 Ultima atualizacao: 24/07/2018
        
        Dados referentes ao programa:
        
        Frequencia:
        
        Objetivo: Rotina para habilitar o convenio do cooperado.
        
        Alteracoes:
                    
        ..............................................................................*/
        DECLARE
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
            vr_des_erro VARCHAR2(3);
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
        
            -- Variaveis        
            vr_flgimpri INTEGER;
        
            -- Variaveis de log
            vr_cdcooper INTEGER;
            vr_cdoperad VARCHAR2(100);
            vr_nmdatela VARCHAR2(100);
            vr_nmeacao  VARCHAR2(100);
            vr_cdagenci VARCHAR2(100);
            vr_dsdmesag VARCHAR2(5000);
            vr_nrdcaixa VARCHAR2(100);
            vr_idorigem VARCHAR2(100);
        
        BEGIN
        
            pc_habilita_convenio(pr_nrdconta    => pr_nrdconta
                                ,pr_nrconven    => pr_nrconven
                                ,pr_insitceb    => pr_insitceb
                                ,pr_inarqcbr    => pr_inarqcbr
                                ,pr_cddemail    => pr_cddemail
                                ,pr_flgcruni    => pr_flgcruni
                                ,pr_flgcebhm    => pr_flgcebhm
                                ,pr_idseqttl    => pr_idseqttl
                                ,pr_flgregon    => pr_flgregon
                                ,pr_flgpgdiv    => pr_flgpgdiv
                                ,pr_flcooexp    => pr_flcooexp
                                ,pr_flceeexp    => pr_flceeexp
                                ,pr_flserasa    => pr_flserasa
                                ,pr_qtdfloat    => pr_qtdfloat
                                ,pr_flprotes    => pr_flprotes
                                ,pr_insrvprt    => pr_insrvprt
                                ,pr_qtlimaxp    => pr_qtlimaxp
                                ,pr_qtlimmip    => pr_qtlimmip
                                ,pr_qtdecprz    => pr_qtdecprz
                                ,pr_idrecipr    => pr_idrecipr
                                ,pr_idreciprold => pr_idreciprold
                                ,pr_perdesconto => pr_perdesconto
                                ,pr_inenvcob    => pr_inenvcob
				,pr_flgapihm	=> pr_flgapihm
                                ,pr_blnewreg    => FALSE
                                ,pr_retxml      => pr_retxml
                                 -- OUT
                                ,pr_flgimpri => vr_flgimpri
                                ,pr_dsdmesag => vr_dsdmesag
                                ,pr_des_erro => vr_dscritic);
        
            IF vr_dscritic IS NOT NULL THEN
							--
							RAISE vr_exc_saida;
							--
						END IF;
						
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
                                  ,pr_tag_nova => 'flgimpri'
                                  ,pr_tag_cont => vr_flgimpri
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'dsdmesag'
                                  ,pr_tag_cont => vr_dsdmesag
                                  ,pr_des_erro => vr_dscritic);
        
        EXCEPTION
            WHEN vr_exc_saida THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;
            
                -- Carregar XML padrão para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        END;
    
    END pc_habilita_convenio_web;

    PROCEDURE pc_busca_config_conv(pr_nrconven IN crapcco.nrconven%TYPE --> Convenio
                                  ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_busca_config_conv
        Sistema : Ayllos Web
        Autor   : Jaison Fernando
        Data    : Marco/2016                 Ultima atualizacao: 08/07/2016
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para buscar a configuracao do convenio selecionado.
        
        Alteracoes: 08/07/2016 - Envio da flag Serasa (Marcos-Supero)
        ..............................................................................*/
        DECLARE
        
            -- Busca o cadastro de convenio
            CURSOR cr_cco_prc(pr_cdcooper IN crapcco.cdcooper%TYPE
                             ,pr_nrconven IN crapcco.nrconven%TYPE) IS
                SELECT cco.qtdfloat
                      ,cco.qtfltate
                      ,cco.flrecipr
                      ,cco.idprmrec
                      ,cco.fldctman
                      ,cco.perdctmx
                      ,prc.perdesconto_maximo perdesconto_maximo_recipro
                      ,cco.flgapvco
                      ,cco.flprotes
                      ,cco.insrvprt
                      ,cco.flserasa
                      ,cco.qtdecini
                      ,cco.qtdecate
                      ,cco.cddbanco
                      ,cco.flgregis
                  FROM tbrecip_parame_calculo prc
                      ,crapcco                cco
                 WHERE cco.idprmrec = prc.idparame_reciproci(+) -- Outer pois nem sempre havera PRC
                   AND cco.cdcooper = pr_cdcooper
                   AND cco.nrconven = pr_nrconven;
            CURSOR cr_parprot(pr_cdcooper IN crapcco.cdcooper%TYPE) IS
                SELECT parprot.qtlimitemin_tolerancia
                      ,parprot.qtlimitemax_tolerancia
                  FROM tbcobran_param_protesto parprot
                 WHERE parprot.cdcooper = pr_cdcooper;
        
            rw_cco_prc    cr_cco_prc%ROWTYPE;
            rw_cr_parprot cr_parprot%ROWTYPE;
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
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
        
        BEGIN
            -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_nmeacao  => vr_nmeacao
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
            -- Busca o cadastro de convenio
            OPEN cr_cco_prc(pr_cdcooper => vr_cdcooper, pr_nrconven => pr_nrconven);
            FETCH cr_cco_prc
                INTO rw_cco_prc;
        
            OPEN cr_parprot(pr_cdcooper => vr_cdcooper);
            FETCH cr_parprot
                INTO rw_cr_parprot;
            -- Fecha cursor
            CLOSE cr_parprot;
        
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
                                  ,pr_tag_nova => 'qtdfloat'
                                  ,pr_tag_cont => rw_cco_prc.qtdfloat
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'qtfltate'
                                  ,pr_tag_cont => rw_cco_prc.qtfltate
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flrecipr'
                                  ,pr_tag_cont => rw_cco_prc.flrecipr
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'idprmrec'
                                  ,pr_tag_cont => rw_cco_prc.idprmrec
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'fldctman'
                                  ,pr_tag_cont => rw_cco_prc.fldctman
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'perdctmx'
                                  ,pr_tag_cont => rw_cco_prc.perdctmx
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'perdesconto_maximo_recipro'
                                  ,pr_tag_cont => rw_cco_prc.perdesconto_maximo_recipro
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flgapvco'
                                  ,pr_tag_cont => rw_cco_prc.flgapvco
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flprotes'
                                  ,pr_tag_cont => rw_cco_prc.flprotes
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'insrvprt'
                                  ,pr_tag_cont => rw_cco_prc.insrvprt
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flgregis'
                                  ,pr_tag_cont => rw_cco_prc.flgregis
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flserasa'
                                  ,pr_tag_cont => rw_cco_prc.flserasa
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'qtdecini'
                                  ,pr_tag_cont => rw_cco_prc.qtdecini
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'qtdecate'
                                  ,pr_tag_cont => rw_cco_prc.qtdecate
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'cddbanco'
                                  ,pr_tag_cont => rw_cco_prc.cddbanco
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flgregis'
                                  ,pr_tag_cont => rw_cco_prc.flgregis
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'insrvprt'
                                  ,pr_tag_cont => rw_cco_prc.insrvprt
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'QTLIMITEMIN_TOLERANCIA'
                                  ,pr_tag_cont => rw_cr_parprot.qtlimitemin_tolerancia
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'QTLIMITEMAX_TOLERANCIA'
                                  ,pr_tag_cont => rw_cr_parprot.qtlimitemax_tolerancia
                                  ,pr_des_erro => vr_dscritic);
        
        EXCEPTION
            WHEN vr_exc_saida THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
            
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;
            
                -- Carregar XML padrão para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
        END;
    
    END pc_busca_config_conv;

    PROCEDURE pc_busca_categoria(pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                                ,pr_nrconven IN crapcco.nrconven%TYPE --> Convenio
                                ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_busca_categoria
        Sistema : Ayllos Web
        Autor   : Jaison Fernando
        Data    : Marco/2016                 Ultima atualizacao: 
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para buscar as categorias com base nas tarifas vinculadas.
        
        Alteracoes: 
        ..............................................................................*/
        DECLARE
        
            -- Busca as categorias
            CURSOR cr_cat_sgr(pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE
                             ,pr_nrconven IN crapcco.nrconven%TYPE) IS
                SELECT initcap(sgr.dssubgru) dssubgru
                      ,cat.cdcatego
                      ,initcap(cat.dscatego) dscatego
                      ,cat.fldesman
                      ,cat.flrecipr
                      ,cat.flcatcee
                      ,cat.flcatcoo
                      ,decode(ctc.perdesconto, NULL, 0, ctc.perdesconto) perdesconto
                      ,sgr.cdsubgru
                  FROM crapcat                      cat
                      ,crapsgr                      sgr
                      ,tbcobran_categ_tarifa_conven ctc
                 WHERE cat.cdsubgru = sgr.cdsubgru
                   AND cat.cdtipcat = 2 -- Cobranca
                      -- AND sgr.cdsubgru <> 28 -- Registro e Liquidação
                   AND ctc.cdcatego(+) = cat.cdcatego
                   AND ctc.cdcooper(+) = pr_cdcooper
                   AND ctc.nrdconta(+) = pr_nrdconta
                   AND ctc.nrconven(+) = pr_nrconven
                 ORDER BY cat.flcatcee + cat.flcatcoo DESC -- COO E CEE Antes
                         ,sgr.cdsubgru
                         ,cat.dscatego;
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
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
        
            -- Variaveis gerais
            vr_cont_cat  PLS_INTEGER := 0;
            vr_cont_sub  PLS_INTEGER := -1;
            vr_ultsubgru VARCHAR2(60) := ' ';
        
        BEGIN
            -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_nmeacao  => vr_nmeacao
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
            -- Criar cabecalho do XML
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Root'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Dados'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
        
            -- Cadastro das categorias
            FOR rw_cat_sgr IN cr_cat_sgr(pr_cdcooper => vr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrconven => pr_nrconven) LOOP
            
                -- Se for um novo sub grupo
                IF vr_ultsubgru <> rw_cat_sgr.dssubgru THEN
                    vr_cont_sub := vr_cont_sub + 1;
                
                    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                          ,pr_tag_pai  => 'Dados'
                                          ,pr_posicao  => 0
                                          ,pr_tag_nova => 'subgrupo'
                                          ,pr_tag_cont => NULL
                                          ,pr_des_erro => vr_dscritic);
                
                    gene0007.pc_gera_atributo(pr_xml      => pr_retxml
                                             ,pr_tag      => 'subgrupo'
                                             ,pr_atrib    => 'dssubgru'
                                             ,pr_atval    => rw_cat_sgr.dssubgru
                                             ,pr_numva    => vr_cont_sub
                                             ,pr_des_erro => vr_dscritic);
                
                    gene0007.pc_gera_atributo(pr_xml      => pr_retxml
                                             ,pr_tag      => 'subgrupo'
                                             ,pr_atrib    => 'cdsubgru'
                                             ,pr_atval    => rw_cat_sgr.cdsubgru
                                             ,pr_numva    => vr_cont_sub
                                             ,pr_des_erro => vr_dscritic);
                
                    vr_ultsubgru := rw_cat_sgr.dssubgru;
                END IF;
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'subgrupo'
                                      ,pr_posicao  => vr_cont_sub
                                      ,pr_tag_nova => 'categoria'
                                      ,pr_tag_cont => NULL
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'categoria'
                                      ,pr_posicao  => vr_cont_cat
                                      ,pr_tag_nova => 'cdcatego'
                                      ,pr_tag_cont => rw_cat_sgr.cdcatego
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'categoria'
                                      ,pr_posicao  => vr_cont_cat
                                      ,pr_tag_nova => 'dscatego'
                                      ,pr_tag_cont => rw_cat_sgr.dscatego
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'categoria'
                                      ,pr_posicao  => vr_cont_cat
                                      ,pr_tag_nova => 'fldesman'
                                      ,pr_tag_cont => rw_cat_sgr.fldesman
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'categoria'
                                      ,pr_posicao  => vr_cont_cat
                                      ,pr_tag_nova => 'flrecipr'
                                      ,pr_tag_cont => rw_cat_sgr.flrecipr
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'categoria'
                                      ,pr_posicao  => vr_cont_cat
                                      ,pr_tag_nova => 'flcatcee'
                                      ,pr_tag_cont => rw_cat_sgr.flcatcee
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'categoria'
                                      ,pr_posicao  => vr_cont_cat
                                      ,pr_tag_nova => 'flcatcoo'
                                      ,pr_tag_cont => rw_cat_sgr.flcatcoo
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'categoria'
                                      ,pr_posicao  => vr_cont_cat
                                      ,pr_tag_nova => 'perdesconto'
                                      ,pr_tag_cont => rw_cat_sgr.perdesconto
                                      ,pr_des_erro => vr_dscritic);
            
                vr_cont_cat := vr_cont_cat + 1;
            END LOOP;
        
        EXCEPTION
            WHEN vr_exc_saida THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
            
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;
            
                -- Carregar XML padrão para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
        END;
    
    END pc_busca_categoria;

    PROCEDURE pc_busca_tarifa(pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                             ,pr_cdcatego IN crapcat.cdcatego%TYPE --> Convenio
                             ,pr_inpessoa IN craptar.inpessoa%TYPE --> Tipo de pessoa
                             ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                             ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                             ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_busca_tarifa
        Sistema : Ayllos Web
        Autor   : Jaison Fernando
        Data    : Marco/2016                 Ultima atualizacao: 
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para buscar as tarifas com base nas categorias.
        
        Alteracoes: 
        ..............................................................................*/
        DECLARE
        
            -- Busca as tarifas
            CURSOR cr_tar_inc(pr_cdcatego IN craptar.cdcatego%TYPE
                             ,pr_inpessoa IN craptar.inpessoa%TYPE) IS
                SELECT tar.cdtarifa
                      ,tar.dstarifa
                      ,inc.dsinctar
                      ,tar.cdocorre
                      ,tar.cdmotivo
                  FROM craptar tar
                      ,crapint inc
                 WHERE tar.cdinctar = inc.cdinctar
                   AND tar.cdcatego = pr_cdcatego
                   AND tar.inpessoa = pr_inpessoa;
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
            vr_tab_erro gene0001.typ_tab_erro;
        
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
        
            -- Variaveis Gerais
            vr_cdhistor INTEGER;
            vr_cdhisest INTEGER;
            vr_vltarifa NUMBER;
            vr_dtdivulg DATE;
            vr_dtvigenc DATE;
            vr_cdfvlcop INTEGER;
            vr_contador INTEGER := 0;
        
        BEGIN
            -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_nmeacao  => vr_nmeacao
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
            -- Criar cabecalho do XML
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Root'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Dados'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
        
            -- Cadastro das tarifas
            FOR rw_tar_inc IN cr_tar_inc(pr_cdcatego => pr_cdcatego, pr_inpessoa => pr_inpessoa) LOOP
                -- Busca o valor da tarifa
                tari0001.pc_carrega_dados_tarifa_cobr(pr_cdcooper => vr_cdcooper
                                                     ,pr_nrconven => pr_nrconven
                                                     ,pr_dsincide => rw_tar_inc.dsinctar
                                                     ,pr_cdocorre => rw_tar_inc.cdocorre
                                                     ,pr_cdmotivo => rw_tar_inc.cdmotivo
                                                     ,pr_inpessoa => pr_inpessoa
                                                     ,pr_vllanmto => 0.01 -- Usaremos o valor ficticio minimo
                                                     ,pr_cdprogra => 'ATENDA'
                                                     ,pr_flaputar => 0 -- Nao apurar
                                                     ,pr_cdhistor => vr_cdhistor
                                                     ,pr_cdhisest => vr_cdhisest
                                                     ,pr_vltarifa => vr_vltarifa
                                                     ,pr_dtdivulg => vr_dtdivulg
                                                     ,pr_dtvigenc => vr_dtvigenc
                                                     ,pr_cdfvlcop => vr_cdfvlcop
                                                     ,pr_cdcritic => vr_cdcritic
                                                     ,pr_dscritic => vr_dscritic);
                -- Se ocorrer erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    vr_vltarifa := 0;
                END IF;
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Dados'
                                      ,pr_posicao  => 0
                                      ,pr_tag_nova => 'tarifa'
                                      ,pr_tag_cont => NULL
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'tarifa'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'cdtarifa'
                                      ,pr_tag_cont => rw_tar_inc.cdtarifa
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'tarifa'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'dstarifa'
                                      ,pr_tag_cont => rw_tar_inc.dstarifa
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'tarifa'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'vltarifa'
                                      ,pr_tag_cont => vr_vltarifa
                                      ,pr_des_erro => vr_dscritic);
            
                vr_contador := vr_contador + 1;
            END LOOP;
        
        EXCEPTION
            WHEN vr_exc_saida THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
            
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;
            
                -- Carregar XML padrão para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
        END;
    
    END pc_busca_tarifa;

    PROCEDURE pc_verifica_apuracao(pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                                  ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                                  ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_verifica_apuracao
        Sistema : Ayllos Web
        Autor   : Jaison Fernando
        Data    : Abril/2016                 Ultima atualizacao: 
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para verificar se existe apuracao de reciprocidade.
        
        Alteracoes: 
        ..............................................................................*/
    
        DECLARE
        
            -- Verifica se possui apuracao em aberto
            CURSOR cr_apuracao(pr_cdcooper IN crapceb.cdcooper%TYPE
                              ,pr_nrdconta IN crapceb.nrdconta%TYPE
                              ,pr_nrconven IN crapceb.nrconven%TYPE) IS
                SELECT COUNT(1)
                  FROM tbrecip_apuracao apr
                 WHERE apr.cdcooper = pr_cdcooper
                   AND apr.nrdconta = pr_nrdconta
                   AND apr.cdchave_produto = pr_nrconven
                   AND apr.cdproduto = 6; -- Cobranca
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
        
            -- Variaveis
            vr_qtapurac NUMBER;
        
            -- Variaveis de log
            vr_cdcooper INTEGER;
            vr_cdoperad VARCHAR2(100);
            vr_nmdatela VARCHAR2(100);
            vr_nmeacao  VARCHAR2(100);
            vr_cdagenci VARCHAR2(100);
            vr_nrdcaixa VARCHAR2(100);
            vr_idorigem VARCHAR2(100);
        
        BEGIN
            -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_nmeacao  => vr_nmeacao
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
            -- Verifica se possui apuracao
            OPEN cr_apuracao(pr_cdcooper => vr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrconven => pr_nrconven);
            FETCH cr_apuracao
                INTO vr_qtapurac;
            -- Fecha cursor
            CLOSE cr_apuracao;
        
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
                                  ,pr_tag_nova => 'qtapurac'
                                  ,pr_tag_cont => vr_qtapurac
                                  ,pr_des_erro => vr_dscritic);
        
        EXCEPTION
            WHEN vr_exc_saida THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
            
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;
            
                -- Carregar XML padrão para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
            
        END;
    
    END pc_verifica_apuracao;

    PROCEDURE pc_gera_arq_ajuda(pr_xmllog   IN VARCHAR2 --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS
        --Erros do processo
        /* .............................................................................
        
          Programa: pc_gera_arq_ajuda
          Sistema : Ayllos Web
          Autor   : Jaison Fernando
          Data    : Abril/2016                 Ultima atualizacao: 
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Rotina para gerar o arquivo de ajuda.
        
          Alteracoes: 
        ..............................................................................*/
    
        --Variaveis do Clob
        vr_clobxml CLOB;
        vr_dstexto VARCHAR2(32767);
    
        --Variaveis Locais
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
        vr_nmdireto VARCHAR2(1000);
        vr_nmarqimp VARCHAR2(1000);
        vr_nmarquiv VARCHAR2(1000);
        vr_comando  VARCHAR2(1000);
    
        --Variaveis de Erro
        vr_cdcritic INTEGER;
        vr_dscritic VARCHAR2(4000);
        vr_des_reto VARCHAR2(3);
        vr_tab_erro gene0001.typ_tab_erro;
    
        --Variaveis de Excecao
        vr_exc_saida EXCEPTION;
    
    BEGIN
        --Inicializar Variavel
        vr_cdcritic := 0;
        vr_dscritic := NULL;
    
        -- Extrair dados do XML de requisição
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        -- Diretorio para salvar
        vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> usr/coop
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_nmsubdir => 'rl');
    
        -- Nome Arquivo
        vr_nmarqimp := dbms_random.string('X', 20) || '.pdf';
    
        -- Inicializar as informações do XML de dados para o relatório
        dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.call);
        dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
    
        --Escrever no arquivo XML
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_dstexto
                               ,'<?xml version="1.0" encoding="UTF-8"?><raiz></raiz>'
                               ,TRUE);
    
        -- Gera relatório
        gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper --> Cooperativa conectada
                                   ,pr_cdprogra  => 'IMPRES' --> Programa chamador
                                   ,pr_dtmvtolt  => NULL --> Data do movimento atual
                                   ,pr_dsxml     => vr_clobxml --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/raiz' --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'recipr_simcrp.jasper' --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL --> Sem parâmetros                                         
                                   ,pr_dsarqsaid => vr_nmdireto || '/' || vr_nmarqimp --> Arquivo final com o path
                                   ,pr_qtcoluna  => 132 --> Colunas do relatorio
                                   ,pr_flg_gerar => 'S' --> Geraçao na hora
                                   ,pr_flg_impri => 'N' --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => '132col' --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1 --> Número de cópias
                                   ,pr_cdrelato  => 73 --> Codigo do Relatorio
                                   ,pr_des_erro  => vr_dscritic); --> Saída com erro
        --Se ocorreu erro no relatorio
        IF vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_saida;
        END IF;
    
        --Fechar Clob e Liberar Memoria  
        dbms_lob.close(vr_clobxml);
        dbms_lob.freetemporary(vr_clobxml);
    
        -- Ayllos Web       
        IF vr_idorigem = 5 THEN
        
            --Enviar arquivo para Web
            gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                        ,pr_cdagenci => vr_cdagenci
                                        ,pr_nrdcaixa => vr_nrdcaixa
                                        ,pr_nmarqpdf => vr_nmdireto || '/' || vr_nmarqimp
                                        ,pr_des_reto => vr_des_reto
                                        ,pr_tab_erro => vr_tab_erro);
            --Se ocorreu erro
            IF vr_des_reto = 'NOK' THEN
                --Se tem erro na tabela 
                IF vr_tab_erro.count > 0 THEN
                    --Mensagem Erro
                    vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                    vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                ELSE
                    vr_dscritic := 'Erro ao enviar arquivo para web.';
                END IF;
                --Sair 
                RAISE vr_exc_saida;
            END IF;
        
            -- Comando para remover arquivo do rl
            vr_comando := 'rm ' || vr_nmdireto || '/' || vr_nmarqimp || ' 2>/dev/null';
        
            --Remover Arquivo pre-existente
            gene0001.pc_oscommand(pr_typ_comando => 'S'
                                 ,pr_des_comando => vr_comando
                                 ,pr_typ_saida   => vr_des_reto
                                 ,pr_des_saida   => vr_dscritic);
            --Se ocorreu erro dar RAISE
            IF vr_des_reto = 'ERR' THEN
                RAISE vr_exc_saida;
            END IF;
        
        END IF;
    
        -- Criar cabeçalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmarqpdf'
                              ,pr_tag_cont => vr_nmarqimp
                              ,pr_des_erro => vr_dscritic);
    
    EXCEPTION
        WHEN vr_exc_saida THEN
            IF vr_cdcritic <> 0 THEN
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            END IF;
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
        
            -- Carregar XML padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            ROLLBACK;
        
        WHEN OTHERS THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;
        
            -- Carregar XML padrão para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            ROLLBACK;
        
    END pc_gera_arq_ajuda;

    --> Rotina para ativar convenio
    PROCEDURE pc_ativar_convenio(pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                                ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                                ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE --> Ceb
                                ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS
        --> Erros do processo
    
        /* .............................................................................
        
          Programa: pc_ativar_convenio          
          Sistema : Ayllos Web
          Autor   : Odirlei Busana - AMcom
          Data    : Abril/2016                 Ultima atualizacao: 08/12/2017
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Rotina para ativar convenio.
        
          Alteracoes: 08/12/2017 - Inclusão de chamada da npcb0002.pc_libera_sessao_sqlserver_npc
                                   (SD#791193 - AJFink)
        
        ..............................................................................*/
    
        ------------> CURSORES <------------
    
        -- Cadastro de associados
        CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
            SELECT to_char(crapass.nrdconta) nrdconta
                  ,crapass.inpessoa
                  ,decode(crapass.inpessoa
                         ,1
                         ,lpad(crapass.nrcpfcgc, 11, '0')
                         ,lpad(crapass.nrcpfcgc, 14, '0')) dscpfcgc
                  ,decode(crapass.inpessoa, 1, 'F', 'J') dspessoa
                  ,crapass.nmprimtl
                  ,to_char(crapass.nrcpfcgc) nrcpfcgc
                  ,to_char(crapcop.cdagectl) cdagectl
              FROM crapass
                  ,crapcop
             WHERE crapass.cdcooper = crapcop.cdcooper
               AND crapass.cdcooper = pr_cdcooper
               AND crapass.nrdconta = pr_nrdconta;
        rw_crapass cr_crapass%ROWTYPE;
    
        -- Cadastro de Bloquetos
        CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                         ,pr_nrdconta IN crapceb.nrdconta%TYPE
                         ,pr_nrconven IN crapceb.nrconven%TYPE
                         ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE) IS
            SELECT crapceb.insitceb
              FROM crapceb
             WHERE crapceb.cdcooper = pr_cdcooper
               AND crapceb.nrdconta = pr_nrdconta
               AND crapceb.nrconven = pr_nrconven
               AND crapceb.nrcnvceb = pr_nrcnvceb
						 UNION ALL
						SELECT crapceb.insitceb
              FROM tbcobran_crapceb crapceb
             WHERE crapceb.cdcooper = pr_cdcooper
               AND crapceb.nrdconta = pr_nrdconta
               AND crapceb.nrconven = pr_nrconven
               AND crapceb.nrcnvceb = pr_nrcnvceb;
        rw_crapceb cr_crapceb%ROWTYPE;
    
        --> Cursor para verificar se ja existe o beneficiario na cip
        CURSOR cr_dda_benef(pr_dspessoa VARCHAR2
                           ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
            SELECT 1
              FROM cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql b
             WHERE b.ispb_if = '05463212'
               AND "TpPessoaBenfcrio" = pr_dspessoa
               AND "CNPJ_CPFBenfcrio" = pr_nrcpfcgc;
        rw_dda_benef cr_dda_benef%ROWTYPE;
    
        --> Cursor para verificar se ja existe o convenio na cip
        CURSOR cr_dda_conven(pr_dspessoa VARCHAR2
                            ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE
                            ,pr_nrconven VARCHAR2) IS
            SELECT 1
              FROM cecredleg.tbjdddabnf_convenio@jdnpcsql b
             WHERE b."ISPB_IF" = '05463212'
               AND b."TpPessoaBenfcrio" = pr_dspessoa
               AND b."CNPJ_CPFBenfcrio" = pr_nrcpfcgc
               AND b."CodCli_Conv" = pr_nrconven;
        rw_dda_conven cr_dda_conven%ROWTYPE;
    
        --> Buscar dados pessoa juridica
        CURSOR cr_crapjur(pr_cdcooper crapjur.cdcooper%TYPE
                         ,pr_nrdconta crapjur.nrdconta%TYPE) IS
            SELECT jur.nmfansia
              FROM crapjur jur
             WHERE jur.cdcooper = pr_cdcooper
               AND jur.nrdconta = pr_nrdconta;
        rw_crapjur cr_crapjur%ROWTYPE;
    
        -- Cursor generico de calendario
        rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
        ------------> VARIAVEIS <-----------  
        -- Variaveis de log
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variavel de criticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(2000);
    
        -- Tratamento de erros
        vr_exc_saida EXCEPTION;
    
        vr_nrdrowid ROWID;
        vr_dstransa VARCHAR2(1000);
        vr_dsdmesag VARCHAR2(1000);
        vr_flgimpri PLS_INTEGER;
    
        vr_dtativac VARCHAR2(8);
        vr_nrconven VARCHAR2(10);
        vr_sitifcnv VARCHAR2(10) := 'A';
        vr_dsdtmvto VARCHAR2(10);
        vr_insitif  VARCHAR2(10);
        vr_insitcip VARCHAR2(10);
        vr_dtfimrel VARCHAR2(10) := NULL;
    
    BEGIN
        -- Extrai os dados vindos do XML
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        -- Seta a descricao da transacao
        vr_dstransa := 'Ativar convenio de cobranca.';
    
        -- Cadastro de associados
        OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass
            INTO rw_crapass;
        -- Se NAO encontrou
        IF cr_crapass%NOTFOUND THEN
            vr_cdcritic := 9;
            CLOSE cr_crapass;
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapass;
    
        -- Verificacao do calendario
        OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
    
        -- Cadastro de bloquetos
        OPEN cr_crapceb(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrconven => pr_nrconven
                       ,pr_nrcnvceb => pr_nrcnvceb);
        FETCH cr_crapceb
            INTO rw_crapceb;
        CLOSE cr_crapceb;
    
        --> Atualizar convenio
        BEGIN
            UPDATE crapceb
               SET insitceb = 1 -- ATIVO
             WHERE cdcooper = vr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrconven = pr_nrconven
               AND nrcnvceb = pr_nrcnvceb;
        EXCEPTION
            WHEN OTHERS THEN
                vr_dscritic := 'Nao foi possivel atualizar crapceb: ' || SQLERRM;
                RAISE vr_exc_saida;
        END;
    
        --> Gravar o log de adesao ou bloqueio do convenio
        cobr0008.pc_gera_log_ceb(pr_idorigem     => vr_idorigem
                                ,pr_cdcooper     => vr_cdcooper
                                ,pr_cdoperad     => vr_cdoperad
                                ,pr_nrdconta     => pr_nrdconta
                                ,pr_nrconven     => pr_nrconven
                                ,pr_dstransa     => vr_dstransa
                                ,pr_insitceb_ant => nvl(rw_crapceb.insitceb, 0)
                                , --Antes de alterar
                                 pr_insitceb     => 1
                                , -- 'ATIVO'
                                 pr_dscritic     => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
        END IF;
    
        --> Verificar se ja existe o beneficiario na cip
        OPEN cr_dda_benef(pr_dspessoa => rw_crapass.dspessoa, pr_nrcpfcgc => rw_crapass.nrcpfcgc);
        FETCH cr_dda_benef
            INTO rw_dda_benef;
        IF cr_dda_benef%NOTFOUND THEN
            IF rw_crapass.inpessoa = 2 THEN
                --> Buscar dados pessoa juridica
                OPEN cr_crapjur(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
                FETCH cr_crapjur
                    INTO rw_crapjur;
                CLOSE cr_crapjur;
            END IF;
        
            vr_dsdtmvto := to_char(rw_crapdat.dtmvtolt, 'RRRRMMDD');
        
            BEGIN
                INSERT INTO cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
                    ("ISPB_IF"
                     ,"TpPessoaBenfcrio"
                     ,"CNPJ_CPFBenfcrio"
                     ,"Nom_RzSocBenfcrio"
                     ,"Nom_FantsBenfcrio"
                     ,"DtInicRelctPart"
                     ,"DtFimRelctPart")
                VALUES
                    ('05463212' -- ISPB_IF
                    ,rw_crapass.dspessoa -- TpPessoaBenfcrio
                    ,rw_crapass.dscpfcgc -- CNPJ_CPFBenfcrio
                    ,rw_crapass.nmprimtl -- Nom_RzSocBenfcrio 
                    ,rw_crapjur.nmfansia -- Nom_FantsBenfcrio 
                    ,vr_dsdtmvto -- DtInicRelctPart    
                    ,NULL); -- DtFimRelctPart    
            
            EXCEPTION
                WHEN OTHERS THEN
                    vr_dscritic := 'Nao foi possivel cadastrar Beneficiario na CIP: ' || SQLERRM;
                    RAISE vr_exc_saida;
            END;
        
        ELSE
        
            -- Atualizar convenio na CIP  
            BEGIN
                vr_dtativac := to_char(rw_crapdat.dtmvtolt, 'RRRRMMDD');
                vr_nrconven := to_char(pr_nrconven);
                UPDATE cecredleg.tbjdddabnf_convenio@jdnpcsql
                   SET TBJDDDABNF_Convenio."SitConvBenfcrioPar" = 'A'
                       ,TBJDDDABNF_Convenio."DtInicRelctConv"    = vr_dtativac
                 WHERE TBJDDDABNF_Convenio."ISPB_IF" = '05463212'
                   AND TBJDDDABNF_Convenio."TpPessoaBenfcrio" = rw_crapass.dspessoa
                   AND TBJDDDABNF_Convenio."CNPJ_CPFBenfcrio" = rw_crapass.dscpfcgc
                   AND TBJDDDABNF_Convenio."CodCli_Conv" = vr_nrconven
                   AND TBJDDDABNF_Convenio."AgDest" = rw_crapass.cdagectl
                   AND TBJDDDABNF_Convenio."CtDest" = rw_crapass.nrdconta;
            
            EXCEPTION
                WHEN OTHERS THEN
                    vr_dscritic := 'Nao foi possivel atualizar convenio na CIP: ' || SQLERRM;
                    RAISE vr_exc_saida;
            END;
        
        END IF;
    
        CLOSE cr_dda_benef;
    
        --> Verificar se ja existe o convenio na cip
        OPEN cr_dda_conven(pr_dspessoa => rw_crapass.dspessoa
                          ,pr_nrcpfcgc => rw_crapass.nrcpfcgc
                          ,pr_nrconven => to_char(pr_nrconven));
        FETCH cr_dda_conven
            INTO rw_dda_conven;
        IF cr_dda_conven%NOTFOUND THEN
            --> Gerar informação de adesão de convênio ao JDBNF                            
            BEGIN
                INSERT INTO cecredleg.tbjdddabnf_convenio@jdnpcsql
                    ("ISPB_IF"
                     ,"ISPBPartIncorpd"
                     ,"TpPessoaBenfcrio"
                     ,"CNPJ_CPFBenfcrio"
                     ,"CodCli_Conv"
                     ,"SitConvBenfcrioPar"
                     ,"DtInicRelctConv"
                     ,"DtFimRelctConv"
                     ,"TpAgDest"
                     ,"AgDest"
                     ,"TpCtDest"
                     ,"CtDest"
                     ,"TpProdtConv"
                     ,"TpCartConvCobr")
                VALUES
                    ('05463212'
                    , -- ISPB_IF
                     NULL
                    , -- ISPBPartIncorpd
                     rw_crapass.dspessoa
                    , -- TpPessoaBenfcrio
                     rw_crapass.dscpfcgc
                    , -- CNPJ_CPFBenfcrio
                     pr_nrconven
                    , -- CodCli_Conv
                     vr_sitifcnv
                    , -- SitConvBenfcrioPar
                     vr_dsdtmvto
                    , -- DtInicRelctConv
                     vr_dtfimrel
                    , -- DtFimRelctConv
                     'F'
                    , -- TpAgDest (F=Fisica)
                     rw_crapass.cdagectl
                    , -- AgDest
                     'CC'
                    , -- TpCtDest
                     rw_crapass.nrdconta
                    , -- CtDest
                     '01'
                    , -- boleto de cobranca             -- TpProdtConv
                     '1'); -- com registro                   -- TpCartConvCobr
            EXCEPTION
                WHEN OTHERS THEN
                    vr_dscritic := 'Nao foi possivel registrar convenio na CIP: ' || SQLERRM;
                    RAISE vr_exc_saida;
            END;
        ELSE
            BEGIN
                vr_nrconven := to_char(pr_nrconven);
                vr_dsdtmvto := to_char(rw_crapdat.dtmvtolt, 'RRRRMMDD');
                UPDATE cecredleg.tbjdddabnf_convenio@jdnpcsql a
                   SET a."SitConvBenfcrioPar" = vr_sitifcnv
                       ,a."DtInicRelctConv"    = vr_dsdtmvto
                       ,a."DtFimRelctConv"     = vr_dtfimrel
                 WHERE a."ISPB_IF" = '05463212'
                   AND a."TpPessoaBenfcrio" = rw_crapass.dspessoa
                   AND a."CNPJ_CPFBenfcrio" = rw_crapass.dscpfcgc
                   AND a."CodCli_Conv" = vr_nrconven;
            EXCEPTION
                WHEN OTHERS THEN
                    vr_dscritic := 'Nao foi possivel atualizar convenio na CIP: ' || SQLERRM;
                    RAISE vr_exc_saida;
            END;
        END IF;
        CLOSE cr_dda_conven;
    
        --> Tratar retorno
        vr_dsdmesag := gene0007.fn_acento_xml('Convênio ativado com sucesso.');
        -- sempre gerar impressao na ativacao
        vr_flgimpri := 1;
    
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
                              ,pr_tag_nova => 'flgimpri'
                              ,pr_tag_cont => vr_flgimpri
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsdmesag'
                              ,pr_tag_cont => vr_dsdmesag
                              ,pr_des_erro => vr_dscritic);
    
        IF cr_dda_benef%ISOPEN THEN
            CLOSE cr_dda_benef;
        END IF;
        IF cr_dda_conven%ISOPEN THEN
            CLOSE cr_dda_conven;
        END IF;
    
        COMMIT;
        npcb0002.pc_libera_sessao_sqlserver_npc('TELA_ATENDA_COBRAN_7');
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
            IF cr_dda_benef%ISOPEN THEN
                CLOSE cr_dda_benef;
            END IF;
            IF cr_dda_conven%ISOPEN THEN
                CLOSE cr_dda_conven;
            END IF;
        
            IF vr_cdcritic <> 0 THEN
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            END IF;
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
        
            -- Carregar XML padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            ROLLBACK;
            npcb0002.pc_libera_sessao_sqlserver_npc('TELA_ATENDA_COBRAN_8');
        
            -- Gerar informacoes do log
            gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic
                                ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                                ,pr_dstransa => vr_dstransa
                                ,pr_dttransa => trunc(SYSDATE)
                                ,pr_flgtrans => 0 --> FALSE
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => 'COBRANCA'
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
            COMMIT;
        
        WHEN OTHERS THEN
        
            IF cr_dda_benef%ISOPEN THEN
                CLOSE cr_dda_benef;
            END IF;
            IF cr_dda_conven%ISOPEN THEN
                CLOSE cr_dda_conven;
            END IF;
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina pc_ativar_convenio: ' || SQLERRM;
        
            -- Carregar XML padrão para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            ROLLBACK;
            npcb0002.pc_libera_sessao_sqlserver_npc('TELA_ATENDA_COBRAN_9');
    END pc_ativar_convenio;

    --> Retornar lista com os log do convenio ceb
    PROCEDURE pc_consulta_log_conv_web(pr_idrecipr IN crapceb.idrecipr%TYPE --> Nr. da Reciprocidade
                                      ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS
        --> Erros do processo
        /* .............................................................................
        
            Programa: pc_consulta_log_ceb_web
            Sistema : CECRED
            Sigla   : COBRAN
            Autor   : Odirlei Busana - AMcom
            Data    : Maio/16.                    Ultima atualizacao: --/--/----
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo  : Retornar lista com os log do convenio ceb
        
            Observacao: -----
        
            Alteracoes:
        ..............................................................................*/
        ---------> CURSORES <--------
        --> Buscar logs
        CURSOR cr_tbcobran_log_conv(pr_cdcooper crapceb.cdcooper%TYPE
                                   ,pr_idrecipr crapceb.idrecipr%TYPE) IS
        
            SELECT to_char(l.dthistorico, 'DD/MM/RRRR HH24:MI:SS') dthorlog
                  ,l.dshistorico
                  ,o.nmoperad
              FROM tbrecip_log_contrato l
                  ,crapope              o
             WHERE l.cdcooper = o.cdcooper
               AND l.cdoperador = o.cdoperad
               AND l.idcalculo_reciproci = pr_idrecipr
             ORDER BY dthorlog ASC;
    
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
    
        -- Variáveis para armazenar as informações em XML
        vr_des_xml CLOB;
        -- Variável para armazenar os dados do XML antes de incluir no CLOB
        vr_texto_completo VARCHAR2(32600);
    
        --------------------------- SUBROTINAS INTERNAS --------------------------
        -- Subrotina para escrever texto na variável CLOB do XML
        PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                                ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
        BEGIN
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
        END;
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
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
    
        -- Leitura da PL/Table e geração do arquivo XML
        -- Inicializar o CLOB
        vr_des_xml := NULL;
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informações do XML
        vr_texto_completo := NULL;
        pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
    
        --> buscar logs ceb
        FOR rw_log IN cr_tbcobran_log_conv(pr_cdcooper => vr_cdcooper, pr_idrecipr => pr_idrecipr) LOOP
            pc_escreve_xml('<inf>' || '<dthorlog>' || rw_log.dthorlog || '</dthorlog>' || '<dscdolog>' ||
                           rw_log.dshistorico || '</dscdolog>' || '<nmoperad>' || rw_log.nmoperad ||
                           '</nmoperad>' || '</inf>');
        END LOOP;
    
        pc_escreve_xml('</dados></root>', TRUE);
    
        pr_retxml := xmltype.createxml(vr_des_xml);
    
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
            ROLLBACK;
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            ROLLBACK;
        
    END pc_consulta_log_conv_web;

    --> Retornar lista com os log do convenio ceb
    PROCEDURE pc_consulta_log_negoc_web(pr_idrecipr crapceb.idrecipr%TYPE --> Nr. da Reciprocidade
                                       ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS
        --> Erros do processo
        /* .............................................................................
        
            Programa: pc_consulta_log_ceb_web
            Sistema : CECRED
            Sigla   : COBRAN
            Autor   : Augusto (Supero)
            Data    : Julho/2018.                    Ultima atualizacao: --/--/----
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo  : Retornar lista com os log da negociação
        
            Observacao: -----
        
            Alteracoes:
        ..............................................................................*/
        ---------> CURSORES <--------
        --> Buscar logs
        CURSOR cr_tbcobran_log_conv(pr_cdcooper crapceb.cdcooper%TYPE
                                   ,pr_idrecipr crapceb.idrecipr%TYPE) IS
            SELECT o.nmoperad
                  ,to_char(tc.dsjustificativa_desc_adic) dsjustificativa
                  ,to_char(c.dtinsori, 'DD/MM/RRRR HH24:MI:SS') dthorlog
                  ,'Solicitacao' AS dsstatus
                  ,1 nrlinha
              FROM tbrecip_calculo tc
                  ,crapope         o
                  ,crapceb         c
             WHERE tc.idcalculo_reciproci = pr_idrecipr
               AND tc.idcalculo_reciproci = c.idrecipr
               AND c.cdoperad = o.cdoperad
               AND c.cdcooper = o.cdcooper
               AND tc.dsjustificativa_desc_adic IS NOT NULL
						UNION ALL
						SELECT o.nmoperad
                  ,to_char(tc.dsjustificativa_desc_adic) dsjustificativa
                  ,to_char(c.dtinsori, 'DD/MM/RRRR HH24:MI:SS') dthorlog
                  ,'Solicitacao' AS dsstatus
                  ,1 nrlinha
              FROM tbrecip_calculo tc
                  ,crapope         o
                  ,tbcobran_crapceb c
             WHERE tc.idcalculo_reciproci = pr_idrecipr
               AND tc.idcalculo_reciproci = c.idrecipr
               AND c.cdoperad = o.cdoperad
               AND c.cdcooper = o.cdcooper
               AND tc.dsjustificativa_desc_adic IS NOT NULL
            UNION ALL
            SELECT nmoperad
                  ,dsjustificativa
                  ,dthorlog
                  ,dsstatus
                  ,nrlinha
              FROM (SELECT o.nmoperad
                          ,to_char(l.dsjustificativa) dsjustificativa
                          ,to_char(l.dtalteracao_status, 'DD/MM/RRRR HH24:MI:SS') dthorlog
                          ,decode(l.idstatus, 'A', 'Aprovado', 'Rejeitado') AS dsstatus
                          ,rownum + 1 nrlinha
                      FROM tbrecip_aprovador_calculo l
                          ,crapope                   o
                     WHERE l.cdcooper = pr_cdcooper
                       AND l.idcalculo_reciproci = pr_idrecipr
                       AND l.cdaprovador = o.cdoperad
                       AND l.cdcooper = o.cdcooper
                     ORDER BY l.dtalteracao_status DESC)
             ORDER BY nrlinha;
    
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
    
        -- Variáveis para armazenar as informações em XML
        vr_des_xml CLOB;
        -- Variável para armazenar os dados do XML antes de incluir no CLOB
        vr_texto_completo VARCHAR2(32600);
    
        --------------------------- SUBROTINAS INTERNAS --------------------------
        -- Subrotina para escrever texto na variável CLOB do XML
        PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                                ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
        BEGIN
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
        END;
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
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
    
        -- Leitura da PL/Table e geração do arquivo XML
        -- Inicializar o CLOB
        vr_des_xml := NULL;
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informações do XML
        vr_texto_completo := NULL;
        pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
    
        --> buscar logs ceb
        FOR rw_log IN cr_tbcobran_log_conv(pr_cdcooper => vr_cdcooper, pr_idrecipr => pr_idrecipr) LOOP
            pc_escreve_xml('<inf>' || '<dthorlog>' || rw_log.dthorlog || '</dthorlog>' || '<dscdolog>' ||
                           rw_log.dsjustificativa || '</dscdolog>' || '<nmoperad>' || rw_log.nmoperad ||
                           '</nmoperad>' || '<dsstatus>' || rw_log.dsstatus || '</dsstatus>' || '</inf>');
        END LOOP;
    
        pc_escreve_xml('</dados></root>', TRUE);
    
        pr_retxml := xmltype.createxml(vr_des_xml);
    
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
            ROLLBACK;
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            ROLLBACK;
        
    END pc_consulta_log_negoc_web;

    PROCEDURE pc_cancela_boletos(pr_cdcooper IN crapceb.cdcooper%TYPE --> Codigo da cooperativa
                                ,pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                                ,pr_nrconven IN crapceb.nrconven%TYPE --> Nro Convenio
                                ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS
        --> Erros do processo
    
        --> Buscar boletos
        CURSOR cr_boletos(pr_cdcooper crapceb.cdcooper%TYPE
                         ,pr_nrdconta crapceb.nrdconta%TYPE
                         ,pr_nrconven crapceb.nrconven%TYPE) IS
            SELECT nrdconta
                  ,nrcnvcob
                  ,nrdocmto
                  ,insitcrt
                  ,insrvprt
              FROM crapcob
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrcnvcob = pr_nrconven
               AND dtdpagto IS NULL
               AND dtdbaixa IS NULL
               AND (insitcrt = 0 OR insitcrt = 1)
			   AND flgdprot = decode(insitcrt,0,1,flgdprot); -- INC0011123 -> Condição incluída para que
			                                                 -- boletos que estão em negativação Serasa não
															 -- sejam selecionados, assim somente selecionando
															 -- os que estão protestados
															 -- (Holz - Mout´s      16/05/2019)
			   
        rw_boletos cr_boletos%ROWTYPE;
    
        -- Cria o registro de data
        rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
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
    
        -- Variáveis para armazenar as informações em XML
        vr_des_xml CLOB;
        -- Variável para armazenar os dados do XML antes de incluir no CLOB
        vr_texto_completo VARCHAR2(32600);
    
    BEGIN
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
    
        -- Abre o cursor de data
        OPEN btch0001.cr_crapdat(pr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
    
        FOR boleto IN cr_boletos(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrconven => pr_nrconven) LOOP
            --dbms_output.put_line('Doc Nro: ' || boleto.nrdocmto);
            cobr0010.pc_grava_instr_boleto(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Movimentacao
                                          ,pr_cdoperad => nvl(vr_cdoperad, '1') --Codigo Operador
                                          ,pr_cdinstru => 41 --Codigo Instrucao
                                          ,pr_nrdconta => pr_nrdconta --Nro Conta
                                          ,pr_nrcnvcob => pr_nrconven --Nro Convenio
                                          ,pr_nrdocmto => boleto.nrdocmto --Nro Documento
                                          ,pr_vlabatim => NULL --Valor Abatimento
                                          ,pr_dtvencto => NULL --Data Vencimento
                                          ,pr_qtdiaprt => NULL --Qtd dias
                                          ,pr_cdcritic => vr_cdcritic --Codigo Critica
                                          ,pr_dscritic => vr_dscritic); --Descricao Critica
        END LOOP;
    
        IF cr_boletos%ISOPEN THEN
            CLOSE cr_boletos;
        END IF;
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
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
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            ROLLBACK;
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            ROLLBACK;
        
    END pc_cancela_boletos;

    PROCEDURE pc_susta_boletos(pr_cdcooper IN crapceb.cdcooper%TYPE --> Codigo da cooperativa
                              ,pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                              ,pr_nrconven IN crapceb.nrconven%TYPE --> Nro Convenio
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS
        --> Erros do processo
    
        --> Buscar boletos
        CURSOR cr_boletos(pr_cdcooper crapceb.cdcooper%TYPE
                         ,pr_nrdconta crapceb.nrdconta%TYPE
                         ,pr_nrconven crapceb.nrconven%TYPE) IS
            SELECT nrdconta
                  ,nrcnvcob
                  ,nrdocmto
                  ,insitcrt
                  ,insrvprt
              FROM crapcob
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrcnvcob = pr_nrconven
               AND dtdpagto IS NULL
               AND dtdbaixa IS NULL
               AND (insitcrt = 2 OR insitcrt = 3)
			   AND flgdprot = decode(insitcrt,0,1,flgdprot); -- INC0011123 -> Condição incluída para que
			                                                 -- boletos que estão em negativação Serasa não
															 -- sejam selecionados, assim somente selecionando
															 -- os que estão protestados
															 -- (Holz - Mout´s      16/05/2019)
			   
        rw_boletos cr_boletos%ROWTYPE;
    
        -- Cria o registro de data
        rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
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
    
        -- Variáveis para armazenar as informações em XML
        vr_des_xml CLOB;
        -- Variável para armazenar os dados do XML antes de incluir no CLOB
        vr_texto_completo VARCHAR2(32600);
    
    BEGIN
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
    
        -- Abre o cursor de data
        OPEN btch0001.cr_crapdat(vr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
    
        FOR boleto IN cr_boletos(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrconven => pr_nrconven) LOOP
            --dbms_output.put_line('Doc Nro: ' || boleto.nrdocmto);
            cobr0010.pc_grava_instr_boleto(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Movimentacao
                                          ,pr_cdoperad => nvl(vr_cdoperad, '1') --Codigo Operador
                                          ,pr_cdinstru => 41 --Codigo Instrucao
                                          ,pr_nrdconta => pr_nrdconta --Nro Conta
                                          ,pr_nrcnvcob => pr_nrconven --Nro Convenio
                                          ,pr_nrdocmto => boleto.nrdocmto --Nro Documento
                                          ,pr_vlabatim => NULL --Valor Abatimento
                                          ,pr_dtvencto => NULL --Data Vencimento
                                          ,pr_qtdiaprt => NULL --Qtd dias
                                          ,pr_cdcritic => vr_cdcritic --Codigo Critica
                                          ,pr_dscritic => vr_dscritic); --Descricao Critica
        END LOOP;
    
        IF cr_boletos%ISOPEN THEN
            CLOSE cr_boletos;
        END IF;
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
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
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            ROLLBACK;
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            ROLLBACK;
        
    END pc_susta_boletos;

    ------------------CONVENIOS DE RECIPROCIDADE PARA DESCONTO ----------------------
    PROCEDURE pc_conv_recip_desc(pr_cdcooper IN crapcco.cdcooper%TYPE --> Codigo da Cooperativa
                                ,pr_nrdconta IN crapceb.nrdconta%TYPE --> Numero da Conta
                                ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2 --> Erros do processo
                                 ) IS
        /* .............................................................................
          Programa: pc_conv_recip_desc
          Sistema : CECRED
          Sigla   : COBRAN
          Autor   : Fabio Stein - Supero
          Data    : Julho/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Retornar lista as opções do domínio enviado
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        --> Buscar convenios de reciprocidade para desconto
        CURSOR cr_conv_recip_desc(pr_cdcooper crapcco.cdcooper%TYPE
                                 ,pr_nrdconta crapceb.nrdconta%TYPE) IS
            SELECT conv.cdcooper
                  ,conv.nrconven
                  ,conv.cdhistor
                  ,fn_idrecipr(conv.cdcooper
															,pr_nrdconta
															,conv.nrconven
															) idrecipr
                  ,conv.dsorgarq
                  ,CASE
                       WHEN substr(nrconven, -3) IN ('001', '003') THEN
                        'Registro'
                       WHEN substr(nrconven, -3) IN ('002', '004') THEN
                        'Liquidação'
                       ELSE
                        ''
                   END AS dstarifacao
                  ,(SELECT COUNT(1)
                      FROM crapcob
                     WHERE crapcob.cdcooper = pr_cdcooper
                       AND crapcob.nrdconta = pr_nrdconta
                       AND crapcob.nrcnvcob = conv.nrconven) AS qtbolcob
                  ,fn_sit_crapceb(conv.cdcooper
																 ,pr_nrdconta
																 ,conv.nrconven
																 ) AS situacao
              FROM crapcco conv
             WHERE 1 = 1
               AND conv.cdcooper = pr_cdcooper
               AND conv.flgativo = 1
               AND conv.flrecipr = 1
               AND conv.dsorgarq NOT IN ('PROTESTO');
    
        rw_conv_recip_desc cr_conv_recip_desc%ROWTYPE;
    
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
    
        -- Variáveis para armazenar as informações em XML
        vr_des_xml CLOB;
        -- Variável para armazenar os dados do XML antes de incluir no CLOB
        vr_texto_completo VARCHAR2(32600);
    
        -- Subrotina para escrever texto na variável CLOB do XML
        PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                                ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
        BEGIN
            --
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
            --
        END;
        --
    BEGIN
    
        --
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        /*gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic
                                );
        */
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
    
        -- Leitura da PL/Table e geração do arquivo XML
        -- Inicializar o CLOB
        vr_des_xml := NULL;
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informações do XML
        vr_texto_completo := NULL;
        pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
    
        --> buscar logs ceb
        FOR rw_conv_recip_desc IN cr_conv_recip_desc(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta) LOOP
            --
            pc_escreve_xml('<inf>' || '<cdcooper>' || rw_conv_recip_desc.cdcooper || '</cdcooper>' ||
                           '<nrconven>' || rw_conv_recip_desc.nrconven || '</nrconven>' || '<cdhistor>' ||
                           rw_conv_recip_desc.cdhistor || '</cdhistor>' || '<idrecipr>' ||
                           rw_conv_recip_desc.idrecipr || '</idrecipr>' || '<dsorgarq>' ||
                           rw_conv_recip_desc.dsorgarq || '</dsorgarq>' || '<dstarifacao>' ||
                           rw_conv_recip_desc.dstarifacao || '</dstarifacao>' || '<qtbolcob>' ||
                           rw_conv_recip_desc.qtbolcob || '</qtbolcob>' || '<situacao>' ||
                           rw_conv_recip_desc.situacao || '</situacao>' || '</inf>');
            --
        END LOOP;
        --
        --
        pc_escreve_xml('</dados></root>', TRUE);
        --
        pr_retxml := xmltype.createxml(vr_des_xml);
        --
    EXCEPTION
        WHEN vr_exc_saida THEN
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
            --
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            --
            ROLLBACK;
        WHEN OTHERS THEN
            --
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            ROLLBACK;
            --   
    END pc_conv_recip_desc;

    -- PRJ431
    FUNCTION fn_busca_data_corte RETURN crapprm.dsvlrprm%TYPE IS
        /* .............................................................................
          Programa: pc_busca_data_corte
          Sistema : CECRED
          Sigla   : COBRAN
          Autor   : Augusto (Supero)
          Data    : Agosto/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo: Retornar a data de corte dos contratos, usado para distinguir os contratos antigos dos novos
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    BEGIN
        RETURN gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                        ,pr_cdcooper => 0
                                        ,pr_cdacesso => 'DT_VIG_RECECIPR_V2');
    END fn_busca_data_corte;

    PROCEDURE pc_busca_dominio(pr_nmdominio IN tbcadast_dominio_campo.nmdominio%TYPE --> Nome do domínio
                              ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro  OUT VARCHAR2 --> Erros do processo
                               ) IS
        /* .............................................................................
          Programa: pc_busca_dominio
          Sistema : CECRED
          Sigla   : COBRAN
          Autor   : Adriano Nagasava - Supero
          Data    : Julho/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Retornar lista as opções do domínio enviado
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
        vr_dscritic VARCHAR2(4000); --> Desc. Erro
    
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
    
        -- Variáveis para armazenar as informações em XML
        vr_des_xml CLOB;
        -- Variável para armazenar os dados do XML antes de incluir no CLOB
        vr_texto_completo VARCHAR2(32600);
    
        -- Tabela que receberá as opções do domínio
        vr_tab_dominios gene0010.typ_tab_dominio;
    
        -- Subrotina para escrever texto na variável CLOB do XML
        PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                                ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
        BEGIN
            --
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
            --
        END;
        --
    BEGIN
        --
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
            RAISE vr_exc_saida;
        END IF;
    
        -- Leitura da PL/Table e geração do arquivo XML
        -- Inicializar o CLOB
        vr_des_xml := NULL;
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informações do XML
        vr_texto_completo := NULL;
    
        -- Busca as opções do domínio
        gene0010.pc_retorna_dominios(pr_nmmodulo     => 'COBRAN' --> Nome do modulo(CADAST, COBRAN, etc.)
                                    ,pr_nmdomini     => pr_nmdominio --> Nome do dominio
                                    ,pr_tab_dominios => vr_tab_dominios --> retorna os dados dos dominios
                                    ,pr_dscritic     => vr_dscritic --> retorna descricao da critica
                                     );
        --
        IF vr_tab_dominios.count > 0 THEN
            --
            pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
            --
            FOR i IN vr_tab_dominios.first .. vr_tab_dominios.last LOOP
                --
                dbms_output.put_line(vr_tab_dominios(i).cddominio || ' - ' || vr_tab_dominios(i).dscodigo);
                pc_escreve_xml('<inf>' || '<nmdominio>' || pr_nmdominio || '</nmdominio>' || '<cddominio>' || vr_tab_dominios(i)
                               .cddominio || '</cddominio>' || '<dscodigo>' || vr_tab_dominios(i).dscodigo ||
                               '</dscodigo>' || '</inf>');
                --
            END LOOP;
            --
            pc_escreve_xml('</dados></root>', TRUE);
            --
            pr_retxml := xmltype.createxml(vr_des_xml);
            --
        ELSE
            --
            vr_dscritic := 'Nenhuma opcao encontrada para o dominio informado: ' || pr_nmdominio;
            RAISE vr_exc_saida;
            --
        END IF;
        --
    EXCEPTION
        WHEN vr_exc_saida THEN
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
            --
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            --
            ROLLBACK;
        WHEN OTHERS THEN
            --
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            ROLLBACK;
            --
    END pc_busca_dominio;

    FUNCTION fn_busca_perdesconto(pr_tipo        NUMBER
                                 ,pr_perdesconto VARCHAR2 DEFAULT ''
                                 ,pr_vlrdesconto NUMBER) RETURN VARCHAR2 IS
        /* .............................................................................
          Programa: fn_busca_perdesconto
          Sistema : CECRED
          Sigla   : COBRAN
          Autor   : Andre Clemer (Supero)
          Data    : Novembro/18.                    Ultima atualizacao: --/--/----
                
          Dados referentes ao programa:
                
          Frequencia: Sempre que for chamado
                
          Objetivo: Retornar lista de percentual de desconto conforme tipo
                
          Observacao: -----
                
          Alteracoes:
        ..............................................................................*/
    
    BEGIN
        DECLARE
            vr_ls_perdesc     VARCHAR2(1000);
            vr_ls_perdesc_aux VARCHAR2(1000) DEFAULT '';
            vr_split_perc     gene0002.typ_split;
            vr_split_tari     gene0002.typ_split;
        BEGIN
            vr_split_perc := gene0002.fn_quebra_string(pr_perdesconto, '|');
        
            IF pr_tipo = 0 THEN
                -- passa para nova lista apenas registros que nao serao adicionados
                FOR i IN nvl(vr_split_perc.first, 0) .. nvl(vr_split_perc.last, -1) LOOP
                    vr_split_tari := gene0002.fn_quebra_string(vr_split_perc(i), '#');
                    IF to_number(vr_split_tari(1)) NOT IN (18, 20, 24) THEN
                        vr_ls_perdesc_aux := vr_ls_perdesc_aux || vr_split_tari(1) || '#' || vr_split_tari(2) || '|';
                    END IF;
                END LOOP;
            
                -- remove primeiro e ultimo delimitador, se existir
                vr_ls_perdesc_aux := TRIM(both '|' FROM vr_ls_perdesc_aux);
            
                vr_ls_perdesc := vr_ls_perdesc_aux || '|' || '18#' || to_char(pr_vlrdesconto) || '|' || '20#' ||
                                 to_char(pr_vlrdesconto) || '|' || '24#' || to_char(pr_vlrdesconto) || '|';
            ELSE
                -- passa para nova lista apenas registros que nao serao adicionados
                FOR i IN nvl(vr_split_perc.first, 0) .. nvl(vr_split_perc.last, -1) LOOP
                    vr_split_tari := gene0002.fn_quebra_string(vr_split_perc(i), '#');
                    IF to_number(vr_split_tari(1)) NOT IN (19, 23) THEN
                        vr_ls_perdesc_aux := vr_ls_perdesc_aux || vr_split_tari(1) || '#' || vr_split_tari(2) || '|';
                    END IF;
                END LOOP;
            
                -- remove primeiro e ultimo delimitador, se existir
                vr_ls_perdesc_aux := TRIM(both '|' FROM vr_ls_perdesc_aux);
            
                vr_ls_perdesc := vr_ls_perdesc_aux || '|' || '19#' || to_char(pr_vlrdesconto) || '|' || '23#' ||
                                 to_char(pr_vlrdesconto) || '|';
            END IF;
        
            -- remove primeiro e ultimo delimitador, se existir
            vr_ls_perdesc := TRIM(both '|' FROM vr_ls_perdesc);
        
            RETURN vr_ls_perdesc;
        END;
    END;

    PROCEDURE pc_consulta_descontos(pr_idcalculo_reciproci IN tbrecip_calculo.idcalculo_reciproci%TYPE
                                   ,pr_cdcooper            IN crapcop.cdcooper%TYPE
                                   ,pr_nrdconta            IN crapass.nrdconta%TYPE
                                   ,pr_xmllog              IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic            OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic            OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml              IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo            OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro            OUT VARCHAR2 --> Erros do processo
                                    ) IS
        /* .............................................................................
          Programa: pc_consulta_descontos
          Sistema : CECRED
          Sigla   : COBRAN
          Autor   : André Clemer (SUPERO)
          Data    : Julho/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Retornar informações sobre os descontos do cooperado
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
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
    
        -- Variaveis internas
        vr_contador                  INTEGER;
        vr_boletos_liquidados        INTEGER;
        vr_volume_liquidacao         VARCHAR2(40);
        vr_flgdebito_reversao        INTEGER;
        vr_qtdfloat                  INTEGER;
        vr_aplicacoes                VARCHAR2(40);
        vr_vldeposito                VARCHAR2(40);
        vr_qtdmes_retorno_reciproci  INTEGER;
        vr_vldesconto_adicional_coo  VARCHAR2(40);
        vr_idfim_desc_adicional_coo  VARCHAR2(40);
        vr_vldesconto_adicional_cee  VARCHAR2(40);
        vr_idfim_desc_adicional_cee  VARCHAR2(40);
        vr_dsjustificativa_desc_adic VARCHAR2(9999);
        vr_idvinculacao              INTEGER;
        vr_vldescontoconcedido_coo   VARCHAR2(40);
        vr_vldescontoconcedido_cee   VARCHAR2(40);
        vr_nmvinculacao              VARCHAR2(400);
    
    BEGIN
        -- Incluir nome do módulo logado
        gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_COBRAN', pr_action => NULL);
    
        -- Extrai os dados vindos do XML
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        -- Busca informação de Boletos Liquidados
        BEGIN
            SELECT tbrecip_indica_calculo.vlcontrata
              INTO vr_boletos_liquidados
              FROM tbrecip_indica_calculo
             WHERE tbrecip_indica_calculo.idindicador = 3
               AND tbrecip_indica_calculo.idcalculo_reciproci = pr_idcalculo_reciproci;
        EXCEPTION
            WHEN no_data_found THEN
                vr_boletos_liquidados := 0;
        END;
    
        -- Busca informação de Volume Liquidação
        BEGIN
            SELECT tbrecip_indica_calculo.vlcontrata
              INTO vr_volume_liquidacao
              FROM tbrecip_indica_calculo
             WHERE tbrecip_indica_calculo.idindicador = 2
               AND tbrecip_indica_calculo.idcalculo_reciproci = pr_idcalculo_reciproci;
        EXCEPTION
            WHEN no_data_found THEN
                vr_volume_liquidacao := 0;
        END;
    
        -- Busca informação de Aplicações
        BEGIN
            SELECT tbrecip_indica_calculo.vlcontrata
              INTO vr_aplicacoes
              FROM tbrecip_indica_calculo
             WHERE tbrecip_indica_calculo.idindicador = 21
               AND tbrecip_indica_calculo.idcalculo_reciproci = pr_idcalculo_reciproci;
        EXCEPTION
            WHEN no_data_found THEN
                vr_aplicacoes := 0;
        END;
    
        -- Busca informação de Aplicações
        BEGIN
            SELECT tbrecip_indica_calculo.vlcontrata
              INTO vr_vldeposito
              FROM tbrecip_indica_calculo
             WHERE tbrecip_indica_calculo.idindicador = 23
               AND tbrecip_indica_calculo.idcalculo_reciproci = pr_idcalculo_reciproci;
        EXCEPTION
            WHEN no_data_found THEN
                vr_vldeposito := 0;
        END;
    
        -- Buscar as informações gerais
        OPEN cr_info_desconto(pr_idcalculo_reciproci, vr_cdoperad);
        FETCH cr_info_desconto
            INTO rw_info_desconto;
    
        IF cr_info_desconto%FOUND THEN
            vr_qtdmes_retorno_reciproci  := rw_info_desconto.qtdmes_retorno_reciproci;
            vr_flgdebito_reversao        := rw_info_desconto.flgdebito_reversao;
            vr_qtdfloat                  := rw_info_desconto.qtdfloat;
            vr_vldesconto_adicional_coo  := rw_info_desconto.vldesconto_adicional_coo;
            vr_idfim_desc_adicional_coo  := rw_info_desconto.idfim_desc_adicional_coo;
            vr_vldesconto_adicional_cee  := rw_info_desconto.vldesconto_adicional_cee;
            vr_idfim_desc_adicional_cee  := rw_info_desconto.idfim_desc_adicional_cee;
            vr_dsjustificativa_desc_adic := rw_info_desconto.dsjustificativa_desc_adic;
            vr_idvinculacao              := rw_info_desconto.idvinculacao;
            vr_vldescontoconcedido_coo   := rw_info_desconto.vldesconto_concedido_coo;
            vr_vldescontoconcedido_cee   := rw_info_desconto.vldesconto_concedido_cee;
            vr_nmvinculacao              := rw_info_desconto.nmvinculacao;
        ELSE
            vr_qtdmes_retorno_reciproci  := 0;
            vr_flgdebito_reversao        := 0;
            vr_qtdfloat                  := 1;
            vr_vldesconto_adicional_coo  := 0;
            vr_idfim_desc_adicional_coo  := 0;
            vr_vldesconto_adicional_cee  := 0;
            vr_idfim_desc_adicional_cee  := 0;
            vr_dsjustificativa_desc_adic := '';
            vr_idvinculacao              := 0;
            vr_vldescontoconcedido_coo   := 0;
            vr_vldescontoconcedido_cee   := 0;
            vr_nmvinculacao              := '';
        END IF;
    
        -- Criar cabeçalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vr_boletos_liquidados'
                              ,pr_tag_cont => to_char(vr_boletos_liquidados, 'fm9G999G999G999G999')
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vr_volume_liquidacao'
                              ,pr_tag_cont => to_char(vr_volume_liquidacao, 'fm999G999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vr_flgdebito_reversao'
                              ,pr_tag_cont => vr_flgdebito_reversao
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vr_qtdfloat'
                              ,pr_tag_cont => vr_qtdfloat
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vr_aplicacoes'
                              ,pr_tag_cont => to_char(vr_aplicacoes, 'fm999G999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vr_vldeposito'
                              ,pr_tag_cont => to_char(vr_vldeposito, 'fm999G999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vr_dtfimcontrato'
                              ,pr_tag_cont => vr_qtdmes_retorno_reciproci
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vr_vldesconto_adicional_coo'
                              ,pr_tag_cont => to_char(vr_vldesconto_adicional_coo, 'fm999G999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vr_idfim_desc_adicional_coo'
                              ,pr_tag_cont => vr_idfim_desc_adicional_coo
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vr_vldesconto_adicional_cee'
                              ,pr_tag_cont => to_char(vr_vldesconto_adicional_cee, 'fm999G999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vr_idfim_desc_adicional_cee'
                              ,pr_tag_cont => vr_idfim_desc_adicional_cee
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vr_dsjustificativa_desc_adic'
                              ,pr_tag_cont => vr_dsjustificativa_desc_adic
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'insitceb'
                              ,pr_tag_cont => rw_info_desconto.insitceb
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'idvinculacao'
                              ,pr_tag_cont => rw_info_desconto.idvinculacao
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmvinculacao'
                              ,pr_tag_cont => rw_info_desconto.nmvinculacao
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vldesconto_concedido_coo'
                              ,pr_tag_cont => rw_info_desconto.vldesconto_concedido_coo
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vldesconto_concedido_cee'
                              ,pr_tag_cont => rw_info_desconto.vldesconto_concedido_cee
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'qtdaprov'
                              ,pr_tag_cont => rw_info_desconto.qtdaprov
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'insitapr'
                              ,pr_tag_cont => rw_info_desconto.insitapr
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Convenios'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
    
        vr_contador := 0;
    
        -- Se tiver id do calculo de reciprocidade
        IF pr_idcalculo_reciproci > 0 THEN
        
            -- Buscar convênios vinculados ao desconto
            FOR rw_convenios IN cr_convenios(pr_cdcooper, pr_idcalculo_reciproci, pr_nrdconta) LOOP
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Dados'
                                      ,pr_posicao  => 0
                                      ,pr_tag_nova => 'Convenios'
                                      ,pr_tag_cont => NULL
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenios'
                                      ,pr_posicao  => 0
                                      ,pr_tag_nova => 'Convenio'
                                      ,pr_tag_cont => NULL
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'convenio'
                                      ,pr_tag_cont => rw_convenios.nrconven
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'tipo'
                                      ,pr_tag_cont => rw_convenios.dsorgarq
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'insitceb'
                                      ,pr_tag_cont => rw_convenios.insitceb
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'flgregon'
                                      ,pr_tag_cont => rw_convenios.flgregon
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'flgpgdiv'
                                      ,pr_tag_cont => rw_convenios.flgpgdiv
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'flcooexp'
                                      ,pr_tag_cont => rw_convenios.flcooexp
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'flceeexp'
                                      ,pr_tag_cont => rw_convenios.flceeexp
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'qtdfloat'
                                      ,pr_tag_cont => rw_convenios.qtdfloat
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'flserasa'
                                      ,pr_tag_cont => rw_convenios.flserasa
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'flprotes'
                                      ,pr_tag_cont => rw_convenios.flprotes
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'insrvprt'
                                      ,pr_tag_cont => rw_convenios.insrvprt
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'qtlimmip'
                                      ,pr_tag_cont => rw_convenios.qtlimmip
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'qtlimaxp'
                                      ,pr_tag_cont => rw_convenios.qtlimaxp
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'qtdecprz'
                                      ,pr_tag_cont => rw_convenios.qtdecprz
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'inarqcbr'
                                      ,pr_tag_cont => rw_convenios.inarqcbr
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'inenvcob'
                                      ,pr_tag_cont => rw_convenios.inenvcob
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'cddemail'
                                      ,pr_tag_cont => rw_convenios.cddemail
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'divCnvHomol'
                                      ,pr_tag_cont => NULL
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'flgcebhm'
                                      ,pr_tag_cont => rw_convenios.flgcebhm
                                      ,pr_des_erro => vr_dscritic);


                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'qtbolcob'
                                      ,pr_tag_cont => rw_convenios.qtbolcob
                                      ,pr_des_erro => vr_dscritic);
                                      

                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Convenio'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'flgapihm'
                                      ,pr_tag_cont => rw_convenios.flgapihm
                                      ,pr_des_erro => vr_dscritic);
                                      
                -- Não alterar a ordem que estas Tags são gravadas, pois isso vai para um Array no PHP
                -- Se precisar adicionar Campos coloque no após este 
            
                vr_contador := vr_contador + 1;
            
            END LOOP;
        
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
            --
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            --
            ROLLBACK;
        WHEN OTHERS THEN
            --
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            ROLLBACK;
            --
    END pc_consulta_descontos;

    PROCEDURE pc_inclui_descontos(pr_cdcooper                IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                 ,pr_nrdconta                IN crapass.nrdconta%TYPE --> Número da conta cooperado
                                 ,pr_ls_convenios            IN VARCHAR2 --> Lista de convênios concatenados por vírg.
                                 ,pr_boletos_liquidados      IN INTEGER --> Qtde. boletos liquidados
                                 ,pr_volume_liquidacao       IN NUMBER --> Volume liquidação
                                 ,pr_qtdfloat                IN INTEGER --> Floating
                                 ,pr_vlaplicacoes            IN NUMBER --> Aplicações
                                 ,pr_vldeposito              IN NUMBER --> Depósito à Vista
                                 ,pr_dtfimcontrato           IN VARCHAR2 --> Data fim do contrato
                                 ,pr_flgdebito_reversao      IN INTEGER --> Débito reajuste da tarifa
                                 ,pr_vldesconto_coo          IN NUMBER --> Valor desconto adicional COO
                                 ,pr_dtfimadicional_coo      IN INTEGER --> Data fim desconto adicional COO
                                 ,pr_vldesconto_cee          IN NUMBER --> Valor desconto adicional CEE
                                 ,pr_dtfimadicional_cee      IN INTEGER --> Data fim desconto adicional CEE
                                 ,pr_txtjustificativa        IN VARCHAR2 --> Justificativa do desconto adicional
                                 ,pr_idvinculacao            IN INTEGER --> Vinculação do cooperado
                                 ,pr_perdesconto             IN VARCHAR2 --> Lista dos descontos de tarifa
                                 ,pr_vldescontoconcedido_coo IN NUMBER --> Valor desconto concedido COO
                                 ,pr_vldescontoconcedido_cee IN NUMBER --> Valor desconto concedido CEE
                                 ,pr_cdoperad                IN crapope.cdoperad%TYPE --> Operador que realizou a operação
                                 ,pr_idcalculo_reciproci     OUT INTEGER --> Código da reciprocidade
                                 ,pr_retxml                  IN xmltype --> Arquivo de retorno do XML
                                 ,pr_des_erro                OUT VARCHAR2 --> Erros do processo
                                  ) IS
        /* .............................................................................
          Programa: pc_inclui_descontos
          Sistema : CECRED
          Sigla   : COBRAN
          Autor   : André Clemer (SUPERO)
          Data    : Julho/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Incluir descontos referente às cobranças do cooperado
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        -- Busca informações do convênio
        CURSOR cr_crapcco(pr_cdcooper crapcco.cdcooper%TYPE
                         ,pr_nrconven crapcco.nrconven%TYPE) IS
            SELECT idprmrec
                  ,flserasa
                  ,flprotes
                  ,qtdecini
                  ,insrvprt
              FROM crapcco
             WHERE crapcco.cdcooper = pr_cdcooper
               AND crapcco.nrconven = pr_nrconven;
        rw_crapcco cr_crapcco%ROWTYPE;
    
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
        vr_dscritic VARCHAR2(1000); --> Desc. Erro
        vr_dsdmesag VARCHAR2(1000);
    
        -- Tratamento de erros
        vr_exc_saida EXCEPTION;
    
        -- Variaveis internas
        vr_convenios          gene0002.typ_split;
        vr_convenio           gene0002.typ_split;
        vr_coo                INTEGER;
        vr_cee                INTEGER;
        vr_boletos_liquidados INTEGER;
        vr_volume_liquidacao  VARCHAR(40);
        vr_flgdebito_reversao INTEGER;
        vr_qtdfloat           INTEGER;
        vr_flgimpri           INTEGER;
        vr_flgcebhm           INTEGER := 0;
        vr_flgapihm           INTEGER := 0;
        vr_qtccoceb           NUMBER;
        vr_insitceb           INTEGER := 1; -- Ativo
        vr_perdesconto        VARCHAR2(1000);
        vr_total_cee          NUMBER;
        vr_total_coo          NUMBER;
        vr_qtalcadas_ativas   NUMBER;
        
    
        vr_idcalculo_reciproci tbrecip_calculo.idcalculo_reciproci%TYPE;
    
        -- calendário
        rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
        CURSOR cr_crapceb(pr_cdcooper crapceb.cdcooper%TYPE
                         ,pr_nrdconta crapceb.nrdconta%TYPE) IS
        
            SELECT COUNT(1)
							FROM(
							SELECT COUNT(1)
              FROM crapceb
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND insitceb IN (1, 3, 5)
               AND nrconven IN (SELECT nrconven
                                  FROM crapcco
                                 WHERE cdcooper = pr_cdcooper
                                   AND flgativo = 1
                                   AND flrecipr = 1
																		 AND dsorgarq <> 'PROTESTO')
							 UNION ALL
							SELECT COUNT(1)
								FROM tbcobran_crapceb crapceb
							 WHERE cdcooper = pr_cdcooper
								 AND nrdconta = pr_nrdconta
								 AND insitceb IN (1, 3, 5)
								 AND nrconven IN (SELECT nrconven
																		FROM crapcco
																	 WHERE cdcooper = pr_cdcooper
																		 AND flgativo = 1
																		 AND flrecipr = 1
																		 AND dsorgarq <> 'PROTESTO'));
    
    BEGIN
        -- Busca do calendário
        OPEN btch0001.cr_crapdat(pr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
    
        vr_convenios := gene0002.fn_quebra_string(pr_ls_convenios, ';');
    
        -- Valida se selecionou pelo menos um convênio
        IF NOT vr_convenios.count > 0 THEN
            pr_des_erro := 'Deve ser selecionado pelo menos um convênio!';
            RAISE vr_exc_saida;
        END IF;
    
        -- Valida se o contrato foi preenchido
        IF TRIM(pr_dtfimcontrato) IS NULL THEN
            pr_des_erro := 'Data fim do contrato é obrigatória!';
            RAISE vr_exc_saida;
        END IF;
    
        -- Valida se foi preenchido o valor de float
        IF TRIM(pr_qtdfloat) IS NULL THEN
            pr_des_erro := 'Floating é obrigatório!';
            RAISE vr_exc_saida;
        END IF;
        
    
        -- Efetiva a reciprocidade e retorna o ID gerado
        BEGIN
            INSERT INTO tbrecip_calculo
                (qtdmes_retorno_reciproci
                ,flgreversao_tarifa
                ,flgdebito_reversao
                ,dtinicio_vigencia_contrato
                ,dtfim_vigencia_contrato
                ,vldesconto_adicional_coo
                ,idfim_desc_adicional_coo
                ,vldesconto_adicional_cee
                ,idfim_desc_adicional_cee
                ,dsjustificativa_desc_adic
                ,idvinculacao
                ,vldesconto_concedido_coo
                ,vldesconto_concedido_cee)
            VALUES
                (pr_dtfimcontrato
                ,1
                ,pr_flgdebito_reversao
                ,to_date(rw_crapdat.dtmvtolt + 1, 'DD/MM/RRRR')
                ,to_date(add_months(rw_crapdat.dtmvtolt, pr_dtfimcontrato), 'DD/MM/RRRR')
                ,pr_vldesconto_coo
                ,pr_dtfimadicional_coo
                ,pr_vldesconto_cee
                ,pr_dtfimadicional_cee
                ,pr_txtjustificativa
                ,pr_idvinculacao
                ,pr_vldescontoconcedido_coo
                ,pr_vldescontoconcedido_cee)
            RETURNING idcalculo_reciproci INTO vr_idcalculo_reciproci;
        
        EXCEPTION
            WHEN OTHERS THEN
                pr_des_erro := 'Erro ao inserir configuracao para calculo de Reciprocidade. ' || SQLERRM;
                RAISE vr_exc_saida;
        END;
    
        pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                        ,pr_idcalculo_reciproci => vr_idcalculo_reciproci
                        ,pr_cdoperador          => pr_cdoperad
                        ,pr_dshistorico         => 'Início da vigência.'
                        ,pr_cdcritic            => vr_cdcritic
                        ,pr_dscritic            => pr_des_erro);
    
        IF TRIM(pr_des_erro) IS NOT NULL THEN
            RAISE vr_exc_saida;
        END IF;
    
        -- Salva as informações dos indicadores vinculando à reciprocidade gerada acima
        BEGIN
            INSERT INTO tbrecip_indica_calculo
                (idcalculo_reciproci, idindicador, vlcontrata)
            VALUES
                (vr_idcalculo_reciproci, 3, pr_boletos_liquidados);
        EXCEPTION
            WHEN OTHERS THEN
                pr_des_erro := 'Erro ao inserir indicadores de calculo de Reciprocidade. ' || SQLERRM;
                RAISE vr_exc_saida;
        END;
    
        BEGIN
            INSERT INTO tbrecip_indica_calculo
                (idcalculo_reciproci, idindicador, vlcontrata)
            VALUES
                (vr_idcalculo_reciproci, 2, pr_volume_liquidacao);
        EXCEPTION
            WHEN OTHERS THEN
                pr_des_erro := 'Erro ao inserir indicadores de calculo de Reciprocidade. ' || SQLERRM;
                RAISE vr_exc_saida;
        END;
    
        BEGIN
            INSERT INTO tbrecip_indica_calculo
                (idcalculo_reciproci, idindicador, vlcontrata)
            VALUES
                (vr_idcalculo_reciproci, 21, pr_vlaplicacoes);
        EXCEPTION
            WHEN OTHERS THEN
                pr_des_erro := 'Erro ao inserir indicadores de calculo de Reciprocidade. ' || SQLERRM;
                RAISE vr_exc_saida;
        END;
    
        BEGIN
            INSERT INTO tbrecip_indica_calculo
                (idcalculo_reciproci, idindicador, vlcontrata)
            VALUES
                (vr_idcalculo_reciproci, 23, pr_vldeposito);
        EXCEPTION
            WHEN OTHERS THEN
                pr_des_erro := 'Erro ao inserir indicadores de calculo de Reciprocidade. ' || SQLERRM;
                RAISE vr_exc_saida;
        END;
    
        -- Verifica se tem desconto adicional ou precisa de aprovacao
        IF TRIM(pr_txtjustificativa) IS NOT NULL THEN
            SELECT COUNT(1)
              INTO vr_qtalcadas_ativas
              FROM tbrecip_param_workflow tpw
                  ,tbcobran_dominio_campo tdc
             WHERE tpw.cdalcada_aprovacao = tdc.cddominio
               AND tdc.nmdominio = 'IDALCADA_RECIPR'
               AND tpw.flregra_aprovacao = 1 -- Ativo
               AND tpw.cdcooper = pr_cdcooper;
        
            -- Se tiver alcadas ativas para aprovacao, vai para pendente (pendente de aprovacao)
            IF vr_qtalcadas_ativas > 0 THEN
                vr_insitceb := 3; -- Pendente
            END IF;
        END IF;
    
        -- Verifica se tem convênio ativo
        OPEN cr_crapceb(pr_cdcooper, pr_nrdconta);
        FETCH cr_crapceb
            INTO vr_qtccoceb;
    
        CLOSE cr_crapceb;
    
        -- tem registros na ceb
        IF vr_qtccoceb > 0 THEN
            BEGIN
                -- se contrato esta pendente de aprovacao
                IF vr_insitceb = 3 THEN
							--
							BEGIN
								--
                    UPDATE crapceb
                       SET insitceb = 2
                     WHERE cdcooper = pr_cdcooper
                       AND nrdconta = pr_nrdconta
                       AND insitceb = 3
                       AND nrconven IN (SELECT nrconven
                                          FROM crapcco
                                         WHERE cdcooper = pr_cdcooper
                                           AND flgativo = 1
                                           AND flrecipr = 1
                                           AND dsorgarq <> 'PROTESTO');
							--
							END;
							--
							BEGIN
								--
								UPDATE tbcobran_crapceb
									 SET insitceb = 2
								 WHERE cdcooper = pr_cdcooper
									 AND nrdconta = pr_nrdconta
									 AND insitceb = 3
									 AND nrconven IN (SELECT nrconven
																			FROM crapcco
																		 WHERE cdcooper = pr_cdcooper
																			 AND flgativo = 1
																			 AND flrecipr = 1
																			 AND dsorgarq <> 'PROTESTO');
								--	
							END;
							--
                ELSE
							--
							BEGIN
								--
                    UPDATE crapceb
                       SET insitceb = 2
                     WHERE cdcooper = pr_cdcooper
                       AND nrdconta = pr_nrdconta
                       AND insitceb IN (1, 3, 5)
                       AND nrconven IN (SELECT nrconven
                                          FROM crapcco
                                         WHERE cdcooper = pr_cdcooper
                                           AND flgativo = 1
                                           AND flrecipr = 1
                                           AND dsorgarq <> 'PROTESTO');
								--
							END;
							--
							BEGIN
								--
								UPDATE tbcobran_crapceb
									 SET insitceb = 2
								 WHERE cdcooper = pr_cdcooper
									 AND nrdconta = pr_nrdconta
									 AND insitceb IN (1, 3, 5)
									 AND nrconven IN (SELECT nrconven
																			FROM crapcco
																		 WHERE cdcooper = pr_cdcooper
																			 AND flgativo = 1
																			 AND flrecipr = 1
																			 AND dsorgarq <> 'PROTESTO');
								--
							END;
							--
                END IF;
						--
            EXCEPTION
                WHEN OTHERS THEN
                    pr_des_erro := 'Erro ao inativar convenios antigos: ' || SQLERRM;
                    RAISE vr_exc_saida;
            END;
        END IF;
    
        FOR ind_registro IN vr_convenios.first .. vr_convenios.last LOOP
            vr_convenio := gene0002.fn_quebra_string(vr_convenios(ind_registro));
            OPEN cr_crapcco(pr_cdcooper, vr_convenio(1));
            FETCH cr_crapcco
                INTO rw_crapcco;
        
            IF cr_crapcco%FOUND THEN
            
                FOR conv_registro IN vr_convenio.first .. vr_convenio.last LOOP
                    IF vr_convenio(conv_registro) = 'yes' OR vr_convenio(conv_registro) = 'on' THEN
                        vr_convenio(conv_registro) := 1;
                    ELSIF vr_convenio(conv_registro) = 'no' OR vr_convenio(conv_registro) = 'off' THEN
                        vr_convenio(conv_registro) := 0;
                    END IF;
                END LOOP;
            
                vr_perdesconto := nvl(pr_perdesconto, '');
            
                -- soma descontos
                vr_total_cee := to_number(nvl(pr_vldescontoconcedido_cee, 0)) + nvl(pr_vldesconto_cee, 0);
                vr_total_coo := to_number(nvl(pr_vldescontoconcedido_coo, 0)) + nvl(pr_vldesconto_coo, 0);
            
                -- cooperativa emite expede
                IF vr_total_cee > 0 AND vr_convenio(7) = 1 THEN
                    vr_perdesconto := fn_busca_perdesconto(1, vr_perdesconto, vr_total_cee);
                END IF;
            
                -- cooperado emite expede
                IF vr_total_coo > 0 AND vr_convenio(6) = 1 THEN
                    vr_perdesconto := fn_busca_perdesconto(0, vr_perdesconto, vr_total_coo);
                END IF;
                
                    
                pc_habilita_convenio(pr_nrdconta    => pr_nrdconta
                                    ,pr_nrconven    => vr_convenio(1)
                                    ,pr_insitceb    => vr_insitceb
                                    ,pr_inarqcbr    => vr_convenio(15)
                                    ,pr_cddemail    => vr_convenio(17)
                                    ,pr_flgcruni    => 1 -- 1=SIM
                                    ,pr_flgcebhm    => vr_convenio(19)
                                    ,pr_idseqttl    => 1 -- padrao
                                    ,pr_flgregon    => vr_convenio(4)
                                    ,pr_flgpgdiv    => vr_convenio(5)
                                    ,pr_flcooexp    => vr_convenio(6)
                                    ,pr_flceeexp    => vr_convenio(7)
                                    ,pr_flserasa    => vr_convenio(9)
                                    ,pr_qtdfloat    => pr_qtdfloat
                                    ,pr_flprotes    => vr_convenio(10)
                                    ,pr_insrvprt    => vr_convenio(11)
                                    ,pr_qtlimaxp    => nvl(vr_convenio(13), 0)
                                    ,pr_qtlimmip    => nvl(vr_convenio(12), 0)
                                    ,pr_qtdecprz    => nvl(TRIM(vr_convenio(14)), 0)
                                    ,pr_idrecipr    => vr_idcalculo_reciproci
                                    ,pr_idreciprold => NULL
                                    ,pr_perdesconto => vr_perdesconto
                                    ,pr_inenvcob    => vr_convenio(16)
                                    ,pr_flgapihm	=> nvl(vr_convenio(21), 0)
                                    ,pr_blnewreg    => TRUE
                                    ,pr_retxml      => pr_retxml
                                     -- OUT
                                    ,pr_flgimpri => vr_flgimpri
                                    ,pr_dsdmesag => vr_dsdmesag
                                    ,pr_des_erro => pr_des_erro);
                                    
            
                IF TRIM(pr_des_erro) IS NOT NULL THEN
                    RAISE vr_exc_saida;
                END IF;
            
            END IF;
            CLOSE cr_crapcco;
        END LOOP;
    
        /*
        -- Valida se existe valor de desconto adiconal COO e data de fim não foi setada
        IF TRIM(pr_vldesconto_coo) IS NOT NULL
           AND TRIM(pr_dtfimdesconto_coo) IS NULL
        THEN
          pr_dscritic := 'Data fim desconto adicional COO é obrigatório quando informado algum desconto adicional!';
          RAISE vr_exc_saida;
        END IF;
        
        -- Valida se existe valor de desconto adiconal CEE e data de fim não foi setada
        IF TRIM(pr_vldesconto_cee) IS NOT NULL
           AND TRIM(pr_dtfimdesconto_cee) IS NULL
        THEN
          pr_dscritic := 'Data fim desconto adicional CEE é obrigatório quando informado algum desconto adicional!';
          RAISE vr_exc_saida;
        END IF;
        
        -- Valida data do contrato
        IF vr_coo > 0 THEN
            IF pr_dtfimcontrato < pr_dtfimdesconto_coo THEN
               pr_dscritic := 'Data fim desconto adicional COO não pode ser maior que a Data fim do contrato!';
               RAISE vr_exc_saida;
            END IF;
        ELSIF vr_cee > 0 THEN
            IF pr_dtfimcontrato < pr_dtfimdesconto_cee THEN
               pr_dscritic := 'Data fim desconto adicional CEE não pode ser maior que a Data fim do contrato!';
               RAISE vr_exc_saida;
            END IF;
        END IF;
        */
        IF vr_insitceb = 3 THEN -- Pendente
            CECRED.TELA_CADRES.pc_envia_email_alcada(pr_cdcooper
                                                ,vr_idcalculo_reciproci
                                                ,vr_cdcritic
                                                ,pr_des_erro);
        
        IF TRIM(pr_des_erro) IS NOT NULL THEN
            RAISE vr_exc_saida;
            END IF;
        END IF;

        
    
        -- Criar cabeçalho do XML
        pr_idcalculo_reciproci := vr_idcalculo_reciproci;
    
    EXCEPTION
        WHEN vr_exc_saida THEN
            IF vr_cdcritic <> 0 THEN
                pr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            END IF;
            --
        
            IF cr_crapcco%ISOPEN THEN
                CLOSE cr_crapcco;
            END IF;
        
            IF cr_crapceb%ISOPEN THEN
                CLOSE cr_crapceb;
            END IF;
        
            ROLLBACK;
        WHEN OTHERS THEN
            --
            pr_des_erro := 'Erro geral na rotina pc_inclui_descontos ' || SQLERRM;
            --
        
            IF cr_crapcco%ISOPEN THEN
                CLOSE cr_crapcco;
            END IF;
        
            ROLLBACK;
    END pc_inclui_descontos;

    PROCEDURE pc_inclui_descontos_web(pr_cdcooper                IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                     ,pr_nrdconta                IN crapass.nrdconta%TYPE --> Número da conta cooperado
                                     ,pr_ls_convenios            IN VARCHAR2 --> Lista de convênios concatenados por vírg.
                                     ,pr_boletos_liquidados      IN INTEGER --> Qtde. boletos liquidados
                                     ,pr_volume_liquidacao       IN VARCHAR2 --> Volume liquidação
                                     ,pr_qtdfloat                IN INTEGER --> Floating
                                     ,pr_vlaplicacoes            IN VARCHAR2 --> Aplicações
                                     ,pr_vldeposito              IN VARCHAR2 --> Depósito à Vista
                                     ,pr_dtfimcontrato           IN VARCHAR2 --> Data fim do contrato
                                     ,pr_flgdebito_reversao      IN INTEGER --> Débito reajuste da tarifa
                                     ,pr_vldesconto_coo          IN VARCHAR2 --> Valor desconto adicional COO
                                     ,pr_dtfimadicional_coo      IN INTEGER --> Data fim desconto adicional COO
                                     ,pr_vldesconto_cee          IN VARCHAR2 --> Valor desconto adicional CEE
                                     ,pr_dtfimadicional_cee      IN INTEGER --> Data fim desconto adicional CEE
                                     ,pr_txtjustificativa        IN VARCHAR2 --> Justificativa do desconto adicional
                                     ,pr_idvinculacao            IN INTEGER --> Vinculação do cooperado
                                     ,pr_perdesconto             IN VARCHAR2 --> Lista dos descontos de tarifa
                                     ,pr_vldescontoconcedido_coo IN VARCHAR2 --> Valor desconto concedido COO
                                     ,pr_vldescontoconcedido_cee IN VARCHAR2 --> Valor desconto concedido CEE
                                     ,pr_xmllog                  IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic                OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic                OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml                  IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo                OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro                OUT VARCHAR2 --> Erros do processo
                                      ) IS
        /* .............................................................................
          Programa: pc_inclui_descontos_web
          Sistema : CECRED
          Sigla   : COBRAN
          Autor   : André Clemer (SUPERO)
          Data    : Julho/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Incluir descontos referente às cobranças do cooperado
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
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
    
        -- Variaveis internas
        vr_convenios          gene0002.typ_split;
        vr_coo                INTEGER;
        vr_cee                INTEGER;
        vr_boletos_liquidados INTEGER;
        vr_flgdebito_reversao INTEGER;
        vr_qtdfloat           INTEGER;
        vr_vldesconto_coo     NUMBER;
        vr_vldesconto_cee     NUMBER;
        vr_volume_liquidacao  NUMBER;
        vr_vlaplicacoes       NUMBER;
        vr_vldeposito         NUMBER;
    
        vr_idcalculo_reciproci tbrecip_calculo.idcalculo_reciproci%TYPE;
    
    BEGIN
    
        -- Extrai os dados vindos do XML
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        vr_vldesconto_coo := to_number(nvl(pr_vldesconto_coo, 0));
        vr_vldesconto_cee := to_number(nvl(pr_vldesconto_cee, 0));
    
        vr_volume_liquidacao := to_number(nvl(pr_volume_liquidacao, 0));
        vr_vlaplicacoes      := to_number(nvl(pr_vlaplicacoes, 0));
        vr_vldeposito        := to_number(nvl(pr_vldeposito, 0));
    
        pc_inclui_descontos(pr_cdcooper                => pr_cdcooper
                           ,pr_nrdconta                => pr_nrdconta
                           ,pr_ls_convenios            => pr_ls_convenios
                           ,pr_boletos_liquidados      => pr_boletos_liquidados
                           ,pr_volume_liquidacao       => vr_volume_liquidacao
                           ,pr_qtdfloat                => pr_qtdfloat
                           ,pr_vlaplicacoes            => vr_vlaplicacoes
                           ,pr_vldeposito              => vr_vldeposito
                           ,pr_dtfimcontrato           => pr_dtfimcontrato
                           ,pr_flgdebito_reversao      => pr_flgdebito_reversao
                           ,pr_vldesconto_coo          => pr_vldesconto_coo
                           ,pr_dtfimadicional_coo      => pr_dtfimadicional_coo
                           ,pr_vldesconto_cee          => pr_vldesconto_cee
                           ,pr_dtfimadicional_cee      => pr_dtfimadicional_cee
                           ,pr_txtjustificativa        => pr_txtjustificativa
                           ,pr_idvinculacao            => pr_idvinculacao
                           ,pr_perdesconto             => pr_perdesconto
                           ,pr_vldescontoconcedido_coo => pr_vldescontoconcedido_coo
                           ,pr_vldescontoconcedido_cee => pr_vldescontoconcedido_cee
                           ,pr_cdoperad                => vr_cdoperad
                           ,pr_idcalculo_reciproci     => vr_idcalculo_reciproci
                           ,pr_retxml                  => pr_retxml
                           ,pr_des_erro                => vr_dscritic);
    
        IF NOT TRIM(vr_dscritic) IS NULL THEN
            RAISE vr_exc_saida;
        END IF;
    
        -- Criar cabeçalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'idcalculo_reciproci'
                              ,pr_tag_cont => vr_idcalculo_reciproci
                              ,pr_des_erro => vr_dscritic);
    
    EXCEPTION
        WHEN vr_exc_saida THEN
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_dscritic := vr_dscritic;
                pr_des_erro := pr_dscritic;
            END IF;
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            --
            ROLLBACK;
        WHEN OTHERS THEN
            --
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
            pr_des_erro := vr_dscritic;
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            ROLLBACK;
            --
    END pc_inclui_descontos_web;

    PROCEDURE pc_gera_logs(pr_idcalculo_reciproci IN tbrecip_calculo.idcalculo_reciproci%TYPE --> Id da reciprocidade
                          ,pr_cdcooper            IN crapcop.cdcooper%TYPE --> Código da cooperativa
                          ,pr_nrdconta            IN crapass.nrdconta%TYPE --> Número da conta cooperado
                          ,pr_ls_convenios        IN VARCHAR2 --> Lista de convênios concatenados por vírg.
                          ,pr_boletos_liquidados  IN INTEGER --> Qtde. boletos liquidados
                          ,pr_volume_liquidacao   IN NUMBER --> Volume liquidação
                          ,pr_qtdfloat            IN INTEGER --> Floating
                          ,pr_vlaplicacoes        IN NUMBER --> Aplicações
                          ,pr_vldeposito          IN NUMBER --> Deposito à Vista
                          ,pr_dtfimcontrato       IN VARCHAR2 --> Data fim do contrato
                          ,pr_flgdebito_reversao  IN INTEGER --> Débito reajuste da tarifa
                          ,pr_vldesconto_coo      IN NUMBER --> Valor desconto adicional COO
                          ,pr_dtfimadicional_coo  IN INTEGER --> Data fim desconto adicional COO
                          ,pr_vldesconto_cee      IN NUMBER --> Valor desconto adicional CEE
                          ,pr_dtfimadicional_cee  IN INTEGER --> Data fim desconto adicional CEE
                          ,pr_txtjustificativa    IN VARCHAR2 --> Justificativa do desconto adicional    
                          ,pr_cdoperad            IN crapope.cdoperad%TYPE --> Operador que realizou a operação
                           ) IS
    
        -- Busca dos convenios do contrato
        CURSOR cr_recip_convenio(pr_cdcooper            crapceb.cdcooper%TYPE
                                ,pr_idcalculo_reciproci tbrecip_calculo.idcalculo_reciproci%TYPE
                                ,pr_nrdconta            crapass.nrdconta%TYPE
                                ,pr_nrconven            crapceb.nrconven%TYPE) IS
        
            SELECT crapceb.nrconven
                  ,crapcco.dsorgarq
                  ,crapceb.insitceb
                  ,crapceb.flgregon
                  ,crapceb.flgpgdiv
                  ,crapceb.flcooexp
                  ,crapceb.flceeexp
                  ,crapceb.qtdfloat
                  ,crapceb.flserasa
                  ,crapceb.flprotes
                  ,crapceb.insrvprt
                  ,crapceb.qtlimmip
                  ,crapceb.qtlimaxp
                  ,crapceb.qtdecprz
                  ,crapceb.inarqcbr
                  ,crapceb.inenvcob
                  ,crapceb.cddemail
                  ,crapceb.flgcebhm
              FROM crapceb
                  ,crapcco
             WHERE crapcco.cdcooper = crapceb.cdcooper
               AND crapcco.nrconven = crapceb.nrconven
               AND crapceb.idrecipr = pr_idcalculo_reciproci
               AND crapceb.cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND crapceb.nrconven = pr_nrconven
						 UNION ALL
						SELECT crapceb.nrconven
                  ,crapcco.dsorgarq
                  ,crapceb.insitceb
                  ,crapceb.flgregon
                  ,crapceb.flgpgdiv
                  ,crapceb.flcooexp
                  ,crapceb.flceeexp
                  ,crapceb.qtdfloat
                  ,crapceb.flserasa
                  ,crapceb.flprotes
                  ,crapceb.insrvprt
                  ,crapceb.qtlimmip
                  ,crapceb.qtlimaxp
                  ,crapceb.qtdecprz
                  ,crapceb.inarqcbr
                  ,crapceb.inenvcob
                  ,crapceb.cddemail
                  ,crapceb.flgcebhm
              FROM tbcobran_crapceb crapceb
                  ,crapcco
             WHERE crapcco.cdcooper = crapceb.cdcooper
               AND crapcco.nrconven = crapceb.nrconven
               AND crapceb.idrecipr = pr_idcalculo_reciproci
               AND crapceb.cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND crapceb.nrconven = pr_nrconven;
        rw_recip_convenio cr_recip_convenio%ROWTYPE;
    
        -- Variaveis internas
        vr_old_boletos_liquidados   INTEGER;
        vr_old_volume_liquidacao    NUMBER;
        vr_old_qtdfloat             INTEGER;
        vr_old_vlaplicacoes         NUMBER;
        vr_old_vldeposito           NUMBER;
        vr_old_qtdmes_reciprocidade INTEGER;
        vr_old_dtfimcontrato        VARCHAR2(40);
        vr_old_flgdebito_reversao   INTEGER;
        vr_old_vldesconto_coo       NUMBER;
        vr_old_dtfimadicional_coo   INTEGER;
        vr_old_vldesconto_cee       NUMBER;
        vr_old_dtfimadicional_cee   VARCHAR2(40);
        vr_old_txtjustificativa     VARCHAR2(9999);
        vr_convenios                gene0002.typ_split;
        vr_convenio                 gene0002.typ_split;
        vr_dsconvl                  VARCHAR2(9999);
        vr_flgfound                 BOOLEAN;
    
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
        vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
        -- Tratamento de erros
        vr_exc_saida EXCEPTION;
    
        FUNCTION fn_busca_arquivo_retorno(tipo NUMBER) RETURN VARCHAR2 IS
        BEGIN
            RETURN CASE tipo WHEN 1 THEN 'OUTROS' WHEN 2 THEN 'FEBRABAN 240' WHEN 3 THEN 'CNAB 400' ELSE 'NÃO RECEBE' END;
        END fn_busca_arquivo_retorno;
    
        FUNCTION fn_busca_forma_envio(tipo NUMBER) RETURN VARCHAR2 IS
        BEGIN
            RETURN CASE tipo WHEN 1 THEN 'INTERNET BANK' WHEN 2 THEN 'FTP' END;
        END fn_busca_forma_envio;
    
        FUNCTION fn_busca_flag(flag NUMBER) RETURN VARCHAR2 IS
        BEGIN
            RETURN CASE flag WHEN 1 THEN 'SIM' ELSE 'NÃO' END;
        END fn_busca_flag;
    
    BEGIN
        -- Busca informação de Boletos Liquidados
        BEGIN
            SELECT tbrecip_indica_calculo.vlcontrata
              INTO vr_old_boletos_liquidados
              FROM tbrecip_indica_calculo
             WHERE tbrecip_indica_calculo.idindicador = 3
               AND tbrecip_indica_calculo.idcalculo_reciproci = pr_idcalculo_reciproci;
        EXCEPTION
            WHEN no_data_found THEN
                vr_old_boletos_liquidados := 0;
        END;
    
        -- Busca informação de Volume Liquidação
        BEGIN
            SELECT tbrecip_indica_calculo.vlcontrata
              INTO vr_old_volume_liquidacao
              FROM tbrecip_indica_calculo
             WHERE tbrecip_indica_calculo.idindicador = 2
               AND tbrecip_indica_calculo.idcalculo_reciproci = pr_idcalculo_reciproci;
        EXCEPTION
            WHEN no_data_found THEN
                vr_old_volume_liquidacao := 0;
        END;
    
        -- Busca informação de Aplicações
        BEGIN
            SELECT tbrecip_indica_calculo.vlcontrata
              INTO vr_old_vlaplicacoes
              FROM tbrecip_indica_calculo
             WHERE tbrecip_indica_calculo.idindicador = 21
               AND tbrecip_indica_calculo.idcalculo_reciproci = pr_idcalculo_reciproci;
        EXCEPTION
            WHEN no_data_found THEN
                vr_old_vlaplicacoes := 0;
        END;
    
        -- Busca informação de Aplicações
        BEGIN
            SELECT tbrecip_indica_calculo.vlcontrata
              INTO vr_old_vldeposito
              FROM tbrecip_indica_calculo
             WHERE tbrecip_indica_calculo.idindicador = 23
               AND tbrecip_indica_calculo.idcalculo_reciproci = pr_idcalculo_reciproci;
        EXCEPTION
            WHEN no_data_found THEN
                vr_old_vldeposito := 0;
        END;
    
        -- Buscar as informações do antigo contrato
        OPEN cr_info_desconto(pr_idcalculo_reciproci, NULL);
        FETCH cr_info_desconto
            INTO rw_info_desconto;
    
        IF cr_info_desconto%FOUND THEN
            vr_old_qtdfloat             := rw_info_desconto.qtdfloat;
            vr_old_flgdebito_reversao   := rw_info_desconto.flgdebito_reversao;
            vr_old_vldesconto_coo       := rw_info_desconto.vldesconto_adicional_coo;
            vr_old_dtfimadicional_coo   := rw_info_desconto.idfim_desc_adicional_coo;
            vr_old_vldesconto_cee       := rw_info_desconto.vldesconto_adicional_cee;
            vr_old_dtfimadicional_cee   := rw_info_desconto.idfim_desc_adicional_cee;
            vr_old_txtjustificativa     := rw_info_desconto.dsjustificativa_desc_adic;
            vr_old_qtdmes_reciprocidade := rw_info_desconto.qtdmes_retorno_reciproci;
        ELSE
            vr_dscritic := 'Erro ao atualizar configuracao para calculo de Reciprocidade, o contrato não foi encontrado. ' ||
                           SQLERRM;
            RAISE vr_exc_saida;
        END IF;
    
        vr_convenios := gene0002.fn_quebra_string(pr_ls_convenios, ';');
        -- Vamos percorrer cada convenio vindo da interface (pr_ls_convenios)
        FOR ind_registro IN vr_convenios.first .. vr_convenios.last LOOP
            vr_convenio := gene0002.fn_quebra_string(vr_convenios(ind_registro));
            -- Vamos verificar se o convenio em questão já estava atrelado ao contrato
            OPEN cr_recip_convenio(pr_cdcooper, pr_idcalculo_reciproci, pr_nrdconta, vr_convenio(1));
            FETCH cr_recip_convenio
                INTO rw_recip_convenio;
        
            vr_dsconvl := NULL;
            -- Caso o convenio em questão ainda não estar atrelado, significa que acabamos de atrelar um novo
            IF NOT cr_recip_convenio%FOUND THEN
                pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                                ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                                ,pr_cdoperador          => pr_cdoperad
                                ,pr_dshistorico         => 'Convênio ' || vr_convenio(1) ||
                                                           ' [b]habilitado[/b].'
                                ,pr_cdcritic            => vr_cdcritic
                                ,pr_dscritic            => vr_dscritic);
            ELSE
                -- Caso o convenio em questão já esteja atrelado, não houve habilitação/desabilitação, resta saber se houve mudança de parametro
                IF (rw_recip_convenio.flgregon <> vr_convenio(4)) THEN
                    IF vr_convenio(4) = 0 THEN
                        vr_dsconvl := vr_dsconvl || 'Registro Online na CIP [b]desativado[/b].[br]';
                    ELSE
                        vr_dsconvl := vr_dsconvl || 'Registro Online na CIP [b]ativado[/b].[br]';
                    END IF;
                END IF;
                --
                IF (rw_recip_convenio.flgpgdiv <> vr_convenio(5)) THEN
                    IF vr_convenio(5) = 0 THEN
                        vr_dsconvl := vr_dsconvl || 'Autorizar Pagamento Divergente [b]desativado[/b].[br]';
                    ELSE
                        vr_dsconvl := vr_dsconvl || 'Autorizar Pagamento Divergente [b]ativado[/b].[br]';
                    END IF;
                END IF;
                --
                IF (rw_recip_convenio.flcooexp <> vr_convenio(6)) THEN
                    IF vr_convenio(6) = 0 THEN
                        vr_dsconvl := vr_dsconvl || 'Cooperado Emite e Expede [b]desativado[/b].[br]';
                    ELSE
                        vr_dsconvl := vr_dsconvl || 'Cooperado Emite e Expede [b]ativado[/b].[br]';
                    END IF;
                END IF;
                --
                IF (rw_recip_convenio.flceeexp <> vr_convenio(7)) THEN
                    IF vr_convenio(7) = 0 THEN
                        vr_dsconvl := vr_dsconvl || 'Cooperativa Emite e Expede [b]desativado[/b].[br]';
                    ELSE
                        vr_dsconvl := vr_dsconvl || 'Cooperativa Emite e Expede [b]ativado[/b].[br]';
                    END IF;
                END IF;
                --
                IF (rw_recip_convenio.flserasa <> vr_convenio(9)) THEN
                    IF vr_convenio(9) = 0 THEN
                        vr_dsconvl := vr_dsconvl || 'Negativação via Serasa [b]desativada[/b].[br]';
                    ELSE
                        vr_dsconvl := vr_dsconvl || 'Negativação via Serasa [b]ativada[/b].[br]';
                    END IF;
                END IF;
                --
                IF (rw_recip_convenio.flprotes <> vr_convenio(10)) THEN
                    IF vr_convenio(10) = 0 THEN
                        vr_dsconvl := vr_dsconvl || 'Envio de Protesto [b]desativado[/b].[br]';
                    ELSE
                        vr_dsconvl := vr_dsconvl || 'Envio de Protesto [b]ativado[/b].[br]';
                    END IF;
                END IF;
                --
                IF (rw_recip_convenio.qtlimmip <> to_number(nvl(vr_convenio(13), 0))) THEN
                    vr_dsconvl := vr_dsconvl || 'Intervalo de Protesto Inicial de [b]' ||
                                  rw_recip_convenio.qtlimmip || '[/b] para [b]' || vr_convenio(13) ||
                                  '[/b].[br]';
                END IF;
                --
                IF (rw_recip_convenio.qtlimaxp <> to_number(nvl(vr_convenio(12), 0))) THEN
                    vr_dsconvl := vr_dsconvl || 'Intervalo de Protesto Final de [b]' ||
                                  rw_recip_convenio.qtlimaxp || '[/b] para [b]' || vr_convenio(12) ||
                                  '[/b].[br]';
                END IF;
                --
                IF (rw_recip_convenio.qtdecprz <> to_number(nvl(vr_convenio(14), 0))) THEN
                    vr_dsconvl := vr_dsconvl || 'Descurso de Prazo de [b]' || rw_recip_convenio.qtdecprz ||
                                  '[/b] para [b]' || vr_convenio(14) || '[/b].[br]';
                END IF;
                --
                IF (rw_recip_convenio.inarqcbr <> vr_convenio(15)) THEN
                    vr_dsconvl := vr_dsconvl || 'Recebe Arquivo Retorno de [b]' ||
                                  fn_busca_arquivo_retorno(rw_recip_convenio.inarqcbr) || '[/b] para [b]' ||
                                  fn_busca_arquivo_retorno(vr_convenio(15)) || '[/b].[br]';
                END IF;
                --
                IF (rw_recip_convenio.inenvcob <> vr_convenio(16)) THEN
                    vr_dsconvl := vr_dsconvl || 'Forma Envio Arquivo de [b]' ||
                                  fn_busca_forma_envio(rw_recip_convenio.inenvcob) || '[/b] para [b]' ||
                                  fn_busca_forma_envio(vr_convenio(16)) || '[/b].[br]';
                END IF;
                --
                IF (rw_recip_convenio.cddemail <> vr_convenio(17)) THEN
                    vr_dsconvl := vr_dsconvl || 'E-mail Arquivo Retorno de [b]' || rw_recip_convenio.cddemail ||
                                  '[/b] para [b]' || vr_convenio(17) || '[/b].[br]';
                END IF;
                --
                IF (rw_recip_convenio.flgcebhm <> vr_convenio(19)) THEN
                    vr_dsconvl := vr_dsconvl || 'Convênio Homologado alterado de [b]' ||
                                  fn_busca_flag(rw_recip_convenio.flgcebhm) || '[/b] para [b]' ||
                                  fn_busca_flag(vr_convenio(19)) || '[/b].';
                END IF;
            END IF;
        
            -- Gera LOG
            IF vr_dsconvl IS NOT NULL THEN
                pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                                ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                                ,pr_cdoperador          => pr_cdoperad
                                ,pr_dshistorico         => 'Alteração no convênio ' ||
                                                           rw_recip_convenio.nrconven || ':[br]' || vr_dsconvl
                                ,pr_cdcritic            => vr_cdcritic
                                ,pr_dscritic            => vr_dscritic);
            
            END IF;
            CLOSE cr_recip_convenio;
        END LOOP;
    
        -- Vamos percorrer cada convenio já atrelado ao contrato
        FOR rw_convenios IN cr_convenios(pr_cdcooper, pr_idcalculo_reciproci, pr_nrdconta) LOOP
            vr_flgfound := FALSE;
            FOR ind_registro IN vr_convenios.first .. vr_convenios.last LOOP
                vr_convenio := gene0002.fn_quebra_string(vr_convenios(ind_registro));
                -- Se encontrarmos o convenio em questão significa que nada aconteceu com ele
                IF (vr_convenio(1) = rw_convenios.nrconven) THEN
                    vr_flgfound := TRUE;
                    EXIT;
                END IF;
            END LOOP;
            -- No entanto, se não encontrarmos significa que ele foi removido do contrato
            IF NOT vr_flgfound THEN
                pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                                ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                                ,pr_cdoperador          => pr_cdoperad
                                ,pr_dshistorico         => 'Convênio ' || rw_convenios.nrconven ||
                                                           ' [b]desabilitado[/b].'
                                ,pr_cdcritic            => vr_cdcritic
                                ,pr_dscritic            => vr_dscritic);
            END IF;
        END LOOP;
    
        IF nvl(pr_boletos_liquidados, 0) <> nvl(vr_old_boletos_liquidados, 0) THEN
            pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                            ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                            ,pr_cdoperador          => pr_cdoperad
                            ,pr_dshistorico         => 'Alteração do campo quantidade de boletos de [b]' ||
                                                       vr_old_boletos_liquidados || '[/b] para [b]' ||
                                                       pr_boletos_liquidados || '[/b].'
                            ,pr_cdcritic            => vr_cdcritic
                            ,pr_dscritic            => vr_dscritic);
        END IF;
    
        IF nvl(pr_volume_liquidacao, 0) <> nvl(vr_old_volume_liquidacao, 0) THEN
            pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                            ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                            ,pr_cdoperador          => pr_cdoperad
                            ,pr_dshistorico         => 'Alteração do campo volume de liquidação de [b]R$ ' ||
                                                       to_char(vr_old_volume_liquidacao
                                                              ,'FM999G999G990D90'
                                                              ,'NLS_NUMERIC_CHARACTERS = '',.''') ||
                                                       '[/b] para [b]R$ ' ||
                                                       to_char(pr_volume_liquidacao
                                                              ,'FM999G999G990D90'
                                                              ,'NLS_NUMERIC_CHARACTERS = '',.''') || '[/b].'
                            ,pr_cdcritic            => vr_cdcritic
                            ,pr_dscritic            => vr_dscritic);
        END IF;
    
        IF nvl(pr_qtdfloat, 0) <> nvl(vr_old_qtdfloat, 0) THEN
            pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                            ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                            ,pr_cdoperador          => pr_cdoperad
                            ,pr_dshistorico         => 'Alteração do campo quantidade de float de [b]' ||
                                                       vr_old_qtdfloat || '[/b] para [b]' || pr_qtdfloat ||
                                                       '[/b].'
                            ,pr_cdcritic            => vr_cdcritic
                            ,pr_dscritic            => vr_dscritic);
        END IF;
    
        IF nvl(pr_vlaplicacoes, 0) <> nvl(vr_old_vlaplicacoes, 0) THEN
            pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                            ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                            ,pr_cdoperador          => pr_cdoperad
                            ,pr_dshistorico         => 'Alteração do campo de aplicações de [b]R$ ' ||
                                                       to_char(vr_old_vlaplicacoes
                                                              ,'FM999G999G990D90'
                                                              ,'NLS_NUMERIC_CHARACTERS = '',.''') ||
                                                       '[/b] para [b]R$ ' ||
                                                       to_char(pr_vlaplicacoes
                                                              ,'FM999G999G990D90'
                                                              ,'NLS_NUMERIC_CHARACTERS = '',.''') || '[/b].'
                            ,pr_cdcritic            => vr_cdcritic
                            ,pr_dscritic            => vr_dscritic);
        END IF;
    
        IF nvl(pr_vldeposito, 0) <> nvl(vr_old_vldeposito, 0) THEN
            pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                            ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                            ,pr_cdoperador          => pr_cdoperad
                            ,pr_dshistorico         => 'Alteração do campo de depósito à vista de [b]R$ ' ||
                                                       to_char(vr_old_vldeposito
                                                              ,'FM999G999G990D90'
                                                              ,'NLS_NUMERIC_CHARACTERS = '',.''') ||
                                                       '[/b] para [b]R$ ' ||
                                                       to_char(pr_vldeposito
                                                              ,'FM999G999G990D90'
                                                              ,'NLS_NUMERIC_CHARACTERS = '',.''') || '[/b].'
                            ,pr_cdcritic            => vr_cdcritic
                            ,pr_dscritic            => vr_dscritic);
        END IF;
    
        IF pr_dtfimcontrato <> vr_old_qtdmes_reciprocidade THEN
            pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                            ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                            ,pr_cdoperador          => pr_cdoperad
                            ,pr_dshistorico         => 'Alteração do campo data fim do contrato de [b]' ||
                                                       vr_old_qtdmes_reciprocidade || '[/b] para [b]' ||
                                                       pr_dtfimcontrato || '[/b].'
                            ,pr_cdcritic            => vr_cdcritic
                            ,pr_dscritic            => vr_dscritic);
        END IF;
    
        IF pr_flgdebito_reversao <> vr_old_flgdebito_reversao THEN
            IF pr_flgdebito_reversao = 0 THEN
                pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                                ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                                ,pr_cdoperador          => pr_cdoperad
                                ,pr_dshistorico         => 'Débito reajuste da tarifa [b]desativado[/b].'
                                ,pr_cdcritic            => vr_cdcritic
                                ,pr_dscritic            => vr_dscritic);
            ELSE
                pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                                ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                                ,pr_cdoperador          => pr_cdoperad
                                ,pr_dshistorico         => 'Débito reajuste da tarifa [b]ativado[/b].'
                                ,pr_cdcritic            => vr_cdcritic
                                ,pr_dscritic            => vr_dscritic);
            
            END IF;
        END IF;
    
        IF nvl(pr_vldesconto_coo, 0) <> nvl(vr_old_vldesconto_coo, 0) THEN
            pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                            ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                            ,pr_cdoperador          => pr_cdoperad
                            ,pr_dshistorico         => 'Alteração do campo de valor do desconto adicional COO de [b]R$ ' ||
                                                       to_char(vr_old_vldesconto_coo
                                                              ,'FM999G999G990D90'
                                                              ,'NLS_NUMERIC_CHARACTERS = '',.''') ||
                                                       '[/b] para [b]R$ ' ||
                                                       to_char(pr_vldesconto_coo
                                                              ,'FM999G999G990D90'
                                                              ,'NLS_NUMERIC_CHARACTERS = '',.''') || '[/b].'
                            ,pr_cdcritic            => vr_cdcritic
                            ,pr_dscritic            => vr_dscritic);
        END IF;
    
        IF pr_dtfimadicional_coo <> vr_old_dtfimadicional_coo THEN
            pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                            ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                            ,pr_cdoperador          => pr_cdoperad
                            ,pr_dshistorico         => 'Alteração do campo da data do fim do desconto adicional COO de [b]' ||
                                                       vr_old_dtfimadicional_coo || '[/b] para [b]' ||
                                                       pr_dtfimadicional_coo || '[/b].'
                            ,pr_cdcritic            => vr_cdcritic
                            ,pr_dscritic            => vr_dscritic);
        END IF;
    
        IF nvl(pr_vldesconto_cee, 0) <> nvl(vr_old_vldesconto_cee, 0) THEN
            pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                            ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                            ,pr_cdoperador          => pr_cdoperad
                            ,pr_dshistorico         => 'Alteração do campo de valor do desconto adicional CEE de [b]R$ ' ||
                                                       to_char(vr_old_vldesconto_cee
                                                              ,'FM999G999G990D90'
                                                              ,'NLS_NUMERIC_CHARACTERS = '',.''') ||
                                                       '[/b] para [b]R$ ' ||
                                                       to_char(pr_vldesconto_cee
                                                              ,'FM999G999G990D90'
                                                              ,'NLS_NUMERIC_CHARACTERS = '',.''') || '[/b].'
                            ,pr_cdcritic            => vr_cdcritic
                            ,pr_dscritic            => vr_dscritic);
        END IF;
    
        IF pr_dtfimadicional_cee <> vr_old_dtfimadicional_cee THEN
            pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                            ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                            ,pr_cdoperador          => pr_cdoperad
                            ,pr_dshistorico         => 'Alteração do campo da data do fim do desconto adicional CEE de [b]' ||
                                                       vr_old_dtfimadicional_cee || '[/b] para [b]' ||
                                                       pr_dtfimadicional_cee || '[/b].'
                            ,pr_cdcritic            => vr_cdcritic
                            ,pr_dscritic            => vr_dscritic);
        END IF;
    
        IF pr_txtjustificativa <> vr_old_txtjustificativa THEN
            pc_gera_log_conv(pr_cdcooper            => pr_cdcooper
                            ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
                            ,pr_cdoperador          => pr_cdoperad
                            ,pr_dshistorico         => 'Alteração do campo de motivo do desconto adicional de [b]' ||
                                                       vr_old_txtjustificativa || '[/b] para [b]' ||
                                                       pr_txtjustificativa || '[/b].'
                            ,pr_cdcritic            => vr_cdcritic
                            ,pr_dscritic            => vr_dscritic);
        END IF;
    
    END pc_gera_logs;

    PROCEDURE pc_altera_descontos(pr_idcalculo_reciproci     IN tbrecip_calculo.idcalculo_reciproci%TYPE --> Id da reciprocidade
                                 ,pr_cdcooper                IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                 ,pr_nrdconta                IN crapass.nrdconta%TYPE --> Número da conta cooperado
                                 ,pr_ls_convenios            IN VARCHAR2 --> Lista de convênios concatenados por vírg.
                                 ,pr_boletos_liquidados      IN INTEGER --> Qtde. boletos liquidados
                                 ,pr_volume_liquidacao       IN VARCHAR2 --> Volume liquidação
                                 ,pr_qtdfloat                IN INTEGER --> Floating
                                 ,pr_vlaplicacoes            IN VARCHAR2 --> Aplicações
                                 ,pr_vldeposito              IN VARCHAR2 --> Depósito à Vista
                                 ,pr_dtfimcontrato           IN VARCHAR2 --> Data fim do contrato
                                 ,pr_flgdebito_reversao      IN INTEGER --> Débito reajuste da tarifa
                                 ,pr_vldesconto_coo          IN VARCHAR2 --> Valor desconto adicional COO
                                 ,pr_dtfimadicional_coo      IN INTEGER --> Data fim desconto adicional COO
                                 ,pr_vldesconto_cee          IN VARCHAR2 --> Valor desconto adicional CEE
                                 ,pr_dtfimadicional_cee      IN INTEGER --> Data fim desconto adicional CEE
                                 ,pr_txtjustificativa        IN VARCHAR2 --> Justificativa do desconto adicional
                                 ,pr_idvinculacao            IN INTEGER --> Vinculação do cooperado
                                 ,pr_perdesconto             IN VARCHAR2 --> Lista dos descontos de tarifa
                                 ,pr_vldescontoconcedido_coo IN VARCHAR2 --> Valor desconto concedido COO
                                 ,pr_vldescontoconcedido_cee IN VARCHAR2 --> Valor desconto concedido CEE
                                 ,pr_xmllog                  IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic                OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic                OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml                  IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo                OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro                OUT VARCHAR2 --> Erros do processo
                                  ) IS
        /* .............................................................................
          Programa: pc_altera_descontos
          Sistema : CECRED
          Sigla   : COBRAN
          Autor   : André Clemer (SUPERO)
          Data    : Julho/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Alterar descontos referente às cobranças do cooperado
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        -- Busca informações do convênio
        CURSOR cr_crapcco(pr_cdcooper crapcco.cdcooper%TYPE
                         ,pr_nrconven crapcco.nrconven%TYPE) IS
            SELECT idprmrec
                  ,flserasa
                  ,flprotes
                  ,qtdecini
                  ,insrvprt
              FROM crapcco
             WHERE crapcco.cdcooper = pr_cdcooper
               AND crapcco.nrconven = pr_nrconven;
        rw_crapcco cr_crapcco%ROWTYPE;
    
        CURSOR cr_recipr IS
            SELECT crapceb.nrconven
						  FROM crapceb
						 WHERE crapceb.idrecipr = pr_idcalculo_reciproci
						 UNION ALL
						SELECT crapceb.nrconven
						  FROM tbcobran_crapceb crapceb
						 WHERE crapceb.idrecipr = pr_idcalculo_reciproci;
        rw_recipr cr_recipr%ROWTYPE;
    
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
        vr_dscritic VARCHAR2(1000); --> Desc. Erro
        vr_dsdmesag VARCHAR2(1000); --> Desc. Erro
    
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
    
        -- Variaveis internas
        vr_convenios               gene0002.typ_split;
        vr_convenio                gene0002.typ_split;
        vr_flgimpri                INTEGER;
        vr_blnfound                BOOLEAN;
        vr_volume_liquidacao       NUMBER;
        vr_vlaplicacoes            NUMBER;
        vr_vldeposito              NUMBER;
        vr_vldesconto_coo          NUMBER;
        vr_vldesconto_cee          NUMBER;
        vr_vldescontoconcedido_coo NUMBER;
        vr_vldescontoconcedido_cee NUMBER;
        vr_perdesconto             VARCHAR2(1000);
        vr_total_cee               NUMBER;
        vr_total_coo               NUMBER;
    
        -- calendário
        rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    BEGIN
        -- Extrai os dados vindos do XML
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        -- Busca do calendário
        OPEN btch0001.cr_crapdat(vr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
    
        vr_volume_liquidacao       := to_number(nvl(pr_volume_liquidacao, 0), '9999999999999.99');
        vr_vlaplicacoes            := to_number(nvl(pr_vlaplicacoes, 0), '9999999999999.99');
        vr_vldeposito              := to_number(nvl(pr_vldeposito, 0), '9999999999999.99');
        vr_vldescontoconcedido_coo := to_number(nvl(pr_vldescontoconcedido_coo, 0), '9999999999999.99');
        vr_vldescontoconcedido_cee := to_number(nvl(pr_vldescontoconcedido_cee, 0), '9999999999999.99');
        vr_vldesconto_coo          := to_number(nvl(pr_vldesconto_coo, 0), '9999999999999.99');
        vr_vldesconto_cee          := to_number(nvl(pr_vldesconto_cee, 0), '9999999999999.99');
    
        -- Efetiva a atualizacao de reciprocidade
        BEGIN
            UPDATE tbrecip_calculo
               SET qtdmes_retorno_reciproci  = pr_dtfimcontrato
                  ,flgdebito_reversao        = pr_flgdebito_reversao
                  ,vldesconto_adicional_coo  = vr_vldesconto_coo
                  ,idfim_desc_adicional_coo  = pr_dtfimadicional_coo
                  ,vldesconto_adicional_cee  = vr_vldesconto_cee
                  ,idfim_desc_adicional_cee  = pr_dtfimadicional_cee
                  ,dsjustificativa_desc_adic = pr_txtjustificativa
                  ,idvinculacao              = pr_idvinculacao
                  ,vldesconto_concedido_coo  = vr_vldescontoconcedido_coo
                  ,vldesconto_concedido_cee  = vr_vldescontoconcedido_cee
             WHERE idcalculo_reciproci = pr_idcalculo_reciproci;
        
        EXCEPTION
            WHEN OTHERS THEN
                pr_des_erro := 'Erro ao atualizar configuracao para calculo de Reciprocidade. ' || SQLERRM;
                RAISE vr_exc_saida;
        END;
    
        pc_gera_logs(pr_idcalculo_reciproci => pr_idcalculo_reciproci
                    ,pr_cdcooper            => pr_cdcooper
                    ,pr_nrdconta            => pr_nrdconta
                    ,pr_ls_convenios        => pr_ls_convenios
                    ,pr_boletos_liquidados  => pr_boletos_liquidados
                    ,pr_volume_liquidacao   => vr_volume_liquidacao
                    ,pr_qtdfloat            => pr_qtdfloat
                    ,pr_vlaplicacoes        => vr_vlaplicacoes
                    ,pr_vldeposito          => vr_vldeposito
                    ,pr_dtfimcontrato       => pr_dtfimcontrato
                    ,pr_flgdebito_reversao  => pr_flgdebito_reversao
                    ,pr_vldesconto_coo      => vr_vldesconto_coo
                    ,pr_dtfimadicional_coo  => pr_dtfimadicional_coo
                    ,pr_vldesconto_cee      => vr_vldesconto_cee
                    ,pr_dtfimadicional_cee  => pr_dtfimadicional_cee
                    ,pr_txtjustificativa    => pr_txtjustificativa
                    ,pr_cdoperad            => vr_cdoperad);
    
        vr_convenios := gene0002.fn_quebra_string(pr_ls_convenios, ';');
    
        -- Valida se selecionou pelo menos um convênio
        IF NOT vr_convenios.count > 0 THEN
            pr_des_erro := 'Deve ser selecionado pelo menos um convênio!';
            RAISE vr_exc_saida;
        END IF;
    
        -- Salva as informações dos indicadores vinculando à reciprocidade gerada acima
        BEGIN
            UPDATE tbrecip_indica_calculo
               SET vlcontrata = pr_boletos_liquidados
             WHERE idcalculo_reciproci = pr_idcalculo_reciproci
               AND idindicador = 3;
        EXCEPTION
            WHEN OTHERS THEN
                pr_des_erro := 'Erro ao atualizar indicadores de calculo de Reciprocidade. ' || SQLERRM;
                RAISE vr_exc_saida;
        END;
    
        BEGIN
            UPDATE tbrecip_indica_calculo
               SET vlcontrata = vr_volume_liquidacao
             WHERE idcalculo_reciproci = pr_idcalculo_reciproci
               AND idindicador = 2;
        EXCEPTION
            WHEN OTHERS THEN
                pr_des_erro := 'Erro ao atualizar indicadores de calculo de Reciprocidade. ' || SQLERRM;
                RAISE vr_exc_saida;
        END;
    
        BEGIN
            UPDATE tbrecip_indica_calculo
               SET vlcontrata = vr_vlaplicacoes
             WHERE idcalculo_reciproci = pr_idcalculo_reciproci
               AND idindicador = 21;
        EXCEPTION
            WHEN OTHERS THEN
                pr_des_erro := 'Erro ao atualizar indicadores de calculo de Reciprocidade. ' || SQLERRM;
                RAISE vr_exc_saida;
        END;
    
        BEGIN
            UPDATE tbrecip_indica_calculo
               SET vlcontrata = vr_vldeposito
             WHERE idcalculo_reciproci = pr_idcalculo_reciproci
               AND idindicador = 23;
        EXCEPTION
            WHEN OTHERS THEN
                pr_des_erro := 'Erro ao atualizar indicadores de calculo de Reciprocidade. ' || SQLERRM;
                RAISE vr_exc_saida;
        END;
    
        -- Busca os convenios atuais
        FOR rw_recipr IN cr_recipr LOOP
        
            vr_blnfound := FALSE;
        
            -- Varre os convenios passados como parametro
            FOR indice IN vr_convenios.first .. vr_convenios.last LOOP
                vr_convenio := gene0002.fn_quebra_string(vr_convenios(indice));
                IF vr_convenio(1) = rw_recipr.nrconven THEN
                    vr_blnfound := TRUE;
                    EXIT;
                END IF;
            END LOOP;
        
            IF vr_blnfound = FALSE THEN
                -- exclui convenio
                BEGIN
                    DELETE FROM crapceb
                     WHERE crapceb.cdcooper = vr_cdcooper
                       AND crapceb.nrdconta = pr_nrdconta
                       AND crapceb.nrconven = rw_recipr.nrconven
                       AND crapceb.idrecipr = pr_idcalculo_reciproci;
                EXCEPTION
                    WHEN OTHERS THEN
                        vr_dscritic := '1.Problema ao excluir convenio: ' || SQLERRM;
                        RAISE vr_exc_saida;
                END;
								-- exclui convenio 2
                BEGIN
                    DELETE FROM tbcobran_crapceb crapceb
                     WHERE crapceb.cdcooper = vr_cdcooper
                       AND crapceb.nrdconta = pr_nrdconta
                       AND crapceb.nrconven = rw_recipr.nrconven
                       AND crapceb.idrecipr = pr_idcalculo_reciproci;
                EXCEPTION
                    WHEN OTHERS THEN
                        vr_dscritic := '2.Problema ao excluir convenio: ' || SQLERRM;
                        RAISE vr_exc_saida;
                END;
								--
            END IF;
        
        END LOOP;
    
        FOR ind_registro IN vr_convenios.first .. vr_convenios.last LOOP
            vr_convenio := gene0002.fn_quebra_string(vr_convenios(ind_registro));
            OPEN cr_crapcco(pr_cdcooper, vr_convenio(1));
            FETCH cr_crapcco
                INTO rw_crapcco;
        
            IF cr_crapcco%FOUND THEN
            
                FOR conv_registro IN vr_convenio.first .. vr_convenio.last LOOP
                    IF vr_convenio(conv_registro) = 'yes' OR vr_convenio(conv_registro) = 'on' THEN
                        vr_convenio(conv_registro) := 1;
                    ELSIF vr_convenio(conv_registro) = 'no' OR vr_convenio(conv_registro) = 'off' THEN
                        vr_convenio(conv_registro) := 0;
                    END IF;
                END LOOP;
            
                vr_perdesconto := nvl(pr_perdesconto, '');
            
                vr_total_cee := vr_vldescontoconcedido_cee + vr_vldesconto_cee;
                vr_total_coo := vr_vldescontoconcedido_coo + vr_vldesconto_coo;
            
                IF vr_total_cee > 0 THEN
                    vr_perdesconto := fn_busca_perdesconto(1, vr_perdesconto, vr_total_cee);
                END IF;
            
                IF vr_total_coo > 0 THEN
                    vr_perdesconto := fn_busca_perdesconto(0, vr_perdesconto, vr_total_coo);
                END IF;
            
                pc_habilita_convenio(pr_nrdconta    => pr_nrdconta
                                    ,pr_nrconven    => vr_convenio(1)
                                    ,pr_insitceb    => vr_convenio(3)
                                    ,pr_inarqcbr    => vr_convenio(15)
                                    ,pr_cddemail    => vr_convenio(17)
                                    ,pr_flgcruni    => 1 -- 1=SIM
                                    ,pr_flgcebhm    => vr_convenio(19)
                                    ,pr_idseqttl    => 1 -- padrao
                                    ,pr_flgregon    => vr_convenio(4)
                                    ,pr_flgpgdiv    => vr_convenio(5)
                                    ,pr_flcooexp    => vr_convenio(6)
                                    ,pr_flceeexp    => vr_convenio(7)
                                    ,pr_flserasa    => vr_convenio(9)
                                    ,pr_qtdfloat    => pr_qtdfloat
                                    ,pr_flprotes    => vr_convenio(10)
                                    ,pr_insrvprt    => vr_convenio(11)
                                    ,pr_qtlimaxp    => nvl(vr_convenio(13), 0)
                                    ,pr_qtlimmip    => nvl(vr_convenio(12), 0)
                                    ,pr_qtdecprz    => nvl(TRIM(vr_convenio(14)), 0)
                                    ,pr_idrecipr    => pr_idcalculo_reciproci
                                    ,pr_idreciprold => NULL
                                    ,pr_perdesconto => vr_perdesconto
                                    ,pr_inenvcob    => vr_convenio(16)
                                    ,pr_flgapihm => nvl(vr_convenio(21), 0)
                                    ,pr_blnewreg    => FALSE
                                    ,pr_retxml      => pr_retxml
                                     -- OUT
                                    ,pr_flgimpri => vr_flgimpri
                                    ,pr_dsdmesag => vr_dsdmesag
                                    ,pr_des_erro => vr_dscritic);
            
                IF TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_saida;
                END IF;
            
            END IF;
            CLOSE cr_crapcco;
        END LOOP;
    
        IF NOT TRIM(vr_dscritic) IS NULL THEN
            RAISE vr_exc_saida;
        END IF;
    
        -- Criar cabeçalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'idcalculo_reciproci'
                              ,pr_tag_cont => pr_idcalculo_reciproci
                              ,pr_des_erro => vr_dscritic);
    
    EXCEPTION
        WHEN vr_exc_saida THEN
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            END IF;
            --
            pr_des_erro := vr_dscritic;
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_des_erro || '</Erro></Root>');
            --
            ROLLBACK;
        WHEN OTHERS THEN
            --
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
            pr_des_erro := vr_dscritic;
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_des_erro || '</Erro></Root>');
            ROLLBACK;
            --
    END pc_altera_descontos;

    /* Trazer o cadastro de Regionais sendo possível a busca por nome */
    PROCEDURE pc_busca_operadores_reg(pr_nmoperad IN crapope.nmoperad%TYPE DEFAULT NULL -->Codigo da opcao
                                     ,pr_nriniseq IN INTEGER -->Quantidade inicial
                                     ,pr_nrregist IN INTEGER -->Quantidade de registros 
                                     ,pr_xmllog   IN VARCHAR2 DEFAULT NULL -->XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER -->Código da crítica
                                     ,pr_dscritic OUT VARCHAR2 -->Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype -->Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 -->Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS
    
        /*---------------------------------------------------------------------------------------------------------------
        
          Programa: pc_busca_crapreg_nome_web      Antiga: 
          Sistema : Conta-Corrente - Cooperativa de Credito
          Sigla   : CRED
        
          Autor   : André Clemer - Supero
          Data    : 02/08/2018                        Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
          Objetivo  : Trazer o cadastro de Regionais sendo possível a busca por nome
        
          Alteracoes: 
                       
        ---------------------------------------------------------------------------------------------------------------*/
    
        -- Busca dos dados da cooperativa
        CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
            SELECT cop.nmrescop
                  ,cop.nmextcop
                  ,cop.cdcooper
                  ,cop.dsdircop
                  ,cop.cdagesic
              FROM crapcop cop
             WHERE cop.cdcooper = pr_cdcooper;
        rw_crapcop cr_crapcop%ROWTYPE;
    
        -- Cursor sobre a tabela de regionais
        CURSOR cr_crapreg(pr_cdcooper IN crapreg.cdcooper%TYPE) IS
            SELECT cddregio
                  ,dsdregio
                  ,cdopereg
                  ,cdcooper
                  ,dsdemail
              FROM crapreg
             WHERE crapreg.cdcooper = pr_cdcooper;
        rw_crapreg cr_crapreg%ROWTYPE;
    
        -- Cursor para seleciona operador
        CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                         ,pr_cdoperad IN crapope.cdoperad%TYPE
                         ,pr_nmoperad IN crapope.nmoperad%TYPE) IS
            SELECT nmoperad
                  ,cdoperad
              FROM crapope
             WHERE crapope.cdcooper = pr_cdcooper
               AND upper(crapope.cdoperad) = upper(pr_cdoperad)
               AND (TRIM(pr_nmoperad) IS NULL OR upper(crapope.nmoperad) LIKE '%' || upper(pr_nmoperad) || '%');
        rw_crapope cr_crapope%ROWTYPE;
    
        --Variaveis de Criticas
        vr_cdcritic INTEGER;
        vr_dscritic VARCHAR2(4000);
        vr_des_reto VARCHAR2(3);
    
        --Tabela de Erros
        vr_tab_erro gene0001.typ_tab_erro;
    
        --Tabela de contratos
        vr_tab_crapreg rreg0001.typ_tab_crapreg;
    
        -- Variaveis de log
        vr_cdcooper crapcop.cdcooper%TYPE;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        --Variaveis Arquivo Dados
        vr_dtmvtolt DATE;
    
        --Variaveis de Indice
        vr_index    PLS_INTEGER := 0;
        vr_auxconta PLS_INTEGER := 0;
    
        --Variaveis auxiliares
        vr_qtregist INTEGER := 0;
    
        --Variaveis de Excecoes
        vr_exc_ok   EXCEPTION;
        vr_exc_erro EXCEPTION;
    
    BEGIN
    
        --limpar tabela erros
        vr_tab_erro.delete;
    
        --Limpar tabela dados
        vr_tab_crapreg.delete;
    
        --Inicializar Variaveis
        vr_cdcritic := 0;
        vr_dscritic := NULL;
    
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
            RAISE vr_exc_erro;
        END IF;
    
        --Inicializar Variaveis
        vr_qtregist := pr_nrregist;
    
        -- Verifica se a cooperativa esta cadastrada
        OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
    
        FETCH cr_crapcop
            INTO rw_crapcop;
    
        -- Se não encontrar
        IF cr_crapcop%NOTFOUND THEN
        
            -- Fechar o cursor pois haverá raise
            CLOSE cr_crapcop;
        
            -- Montar mensagem de critica
            vr_cdcritic := 651;
            -- Busca critica
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        
            RAISE vr_exc_erro;
        
        ELSE
            CLOSE cr_crapcop;
        END IF;
    
        --Leitura no cadastro de regionais
        FOR rw_crapreg IN cr_crapreg(vr_cdcooper) LOOP
        
            --Incrementar contador
            vr_qtregist := nvl(vr_qtregist, 0) + 1;
        
            -- controles da paginacao 
            IF (vr_qtregist < pr_nriniseq) OR (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
            
                --Proximo
                continue;
            
            END IF;
        
            IF vr_qtregist >= 1 THEN
            
                -- Verifica se o operador esta cadastrada
                OPEN cr_crapope(pr_cdcooper => rw_crapreg.cdcooper
                               ,pr_cdoperad => rw_crapreg.cdopereg
                               ,pr_nmoperad => pr_nmoperad);
            
                FETCH cr_crapope
                    INTO rw_crapope;
            
                -- Se encontrar
                IF cr_crapope%FOUND THEN
                
                    vr_index := vr_index + 1;
                
                    vr_tab_crapreg(vr_index).cddsregi := to_char(rw_crapreg.cddregio) || ' - ' ||
                                                         rw_crapreg.dsdregio;
                    vr_tab_crapreg(vr_index).dsdemail := rw_crapreg.dsdemail;
                    vr_tab_crapreg(vr_index).dsdregio := rw_crapreg.dsdregio;
                    vr_tab_crapreg(vr_index).cdopereg := rw_crapreg.cdopereg;
                    vr_tab_crapreg(vr_index).cddregio := rw_crapreg.cddregio;
                    vr_tab_crapreg(vr_index).cdcooper := rw_crapreg.cdcooper;
                
                    -- Fechar o cursor
                    CLOSE cr_crapope;
                    vr_tab_crapreg(vr_index).nmoperad := rw_crapope.nmoperad;
                    vr_tab_crapreg(vr_index).dsoperad := rw_crapreg.cdopereg || ' - ' || rw_crapope.nmoperad;
                
                ELSE
                    CLOSE cr_crapope;
                END IF;
            
            END IF;
        
            --Diminuir registros
            vr_qtregist := nvl(vr_qtregist, 0) - 1;
        
        END LOOP;
    
        vr_index := 0;
    
        --Montar CLOB
        IF vr_tab_crapreg.count > 0 THEN
        
            -- Criar cabeçalho do XML
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        
            --Buscar Primeira regional
            vr_index := vr_tab_crapreg.first;
        
            --Percorrer todos os contratos
            WHILE vr_index IS NOT NULL LOOP
            
                -- Insere as tags dos campos da PLTABLE de regionais
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Dados'
                                      ,pr_posicao  => 0
                                      ,pr_tag_nova => 'inf'
                                      ,pr_tag_cont => NULL
                                      ,pr_des_erro => vr_dscritic);
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_auxconta
                                      ,pr_tag_nova => 'nmoperad'
                                      ,pr_tag_cont => to_char(vr_tab_crapreg(vr_index).nmoperad)
                                      ,pr_des_erro => vr_dscritic);
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_auxconta
                                      ,pr_tag_nova => 'dsoperad'
                                      ,pr_tag_cont => to_char(vr_tab_crapreg(vr_index).dsoperad)
                                      ,pr_des_erro => vr_dscritic);
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_auxconta
                                      ,pr_tag_nova => 'cddsregi'
                                      ,pr_tag_cont => to_char(vr_tab_crapreg(vr_index).cddsregi)
                                      ,pr_des_erro => vr_dscritic);
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_auxconta
                                      ,pr_tag_nova => 'dsdemail'
                                      ,pr_tag_cont => to_char(vr_tab_crapreg(vr_index).dsdemail)
                                      ,pr_des_erro => vr_dscritic);
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_auxconta
                                      ,pr_tag_nova => 'dsdregio'
                                      ,pr_tag_cont => to_char(vr_tab_crapreg(vr_index).dsdregio)
                                      ,pr_des_erro => vr_dscritic);
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_auxconta
                                      ,pr_tag_nova => 'cddregio'
                                      ,pr_tag_cont => to_char(vr_tab_crapreg(vr_index).cddregio)
                                      ,pr_des_erro => vr_dscritic);
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_auxconta
                                      ,pr_tag_nova => 'cdopereg'
                                      ,pr_tag_cont => to_char(vr_tab_crapreg(vr_index).cdopereg)
                                      ,pr_des_erro => vr_dscritic);
            
                -- Incrementa contador p/ posicao no XML
                vr_auxconta := vr_auxconta + 1;
            
                --Proximo Registro
                vr_index := vr_tab_crapreg.next(vr_index);
            
            END LOOP;
        
        ELSE
            -- Criar cabeçalho do XML
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        
        END IF;
    
        -- Insere atributo na tag Dados com a quantidade de registros
        gene0007.pc_gera_atributo(pr_xml      => pr_retxml --> XML que irá receber o novo atributo
                                 ,pr_tag      => 'Dados' --> Nome da TAG XML
                                 ,pr_atrib    => 'qtregist' --> Nome do atributo
                                 ,pr_atval    => vr_qtregist --> Valor do atributo
                                 ,pr_numva    => 0 --> Número da localização da TAG na árvore XML
                                 ,pr_des_erro => vr_dscritic); --> Descrição de erros
    
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
        END IF;
    
        --Retorno
        pr_des_erro := 'OK';
    
    EXCEPTION
        WHEN vr_exc_erro THEN
            -- Retorno não OK
            pr_des_erro := 'NOK';
        
            -- Erro
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
        
            -- Existe para satisfazer exigência da interface. 
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');
        
        WHEN OTHERS THEN
            -- Retorno não OK
            pr_des_erro := 'NOK';
        
            -- Erro
            pr_cdcritic := 0;
            pr_dscritic := 'Erro na RREG0001.pc_busca_crapreg_web --> ' || SQLERRM;
        
            -- Existe para satisfazer exigência da interface. 
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_cdcritic || '-' || pr_dscritic || '</Erro></Root>');
        
    END pc_busca_operadores_reg;

    PROCEDURE pc_valida_exclusao_conven(pr_nrdconta IN crapceb.nrdconta%TYPE --> Conta
                                       ,pr_nrconven IN crapceb.nrconven%TYPE --> Convenio
                                       ,pr_idrecipr IN crapceb.idrecipr%TYPE --> Id Reciprocidade
                                       ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_valida_exclusao_conven
        Sistema : Ayllos Web
        Autor   : Andre Clemer - Supero
        Data    : Agosto/2018                 Ultima atualizacao: --/--/----
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para validar possibilidade de exclusão/inativação do convenio.
        
        Alteracoes: 
        
        ..............................................................................*/
        DECLARE
        
            -- Cursor generico de calendario
            rw_crapdat btch0001.cr_crapdat%ROWTYPE;
        
            -- Variavel de criticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
        
            -- Variaveis
            vr_insitceb crapceb.insitceb%TYPE;
            vr_qtbolcob NUMBER;
            vr_qtcebati NUMBER;
            vr_nrdrowid ROWID;
            vr_dstransa VARCHAR2(1000);
            vr_dtfimrel VARCHAR2(8);
            vr_nrconven VARCHAR2(10);
        
            -- Variaveis de log
            vr_cdcooper INTEGER;
            vr_cdoperad VARCHAR2(100);
            vr_nmdatela VARCHAR2(100);
            vr_nmeacao  VARCHAR2(100);
            vr_cdagenci VARCHAR2(100);
            vr_nrdcaixa VARCHAR2(100);
            vr_idorigem VARCHAR2(100);
        
        BEGIN
            -- Extrai os dados vindos do XML
            gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_nmeacao  => vr_nmeacao
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
            -- Verificacao do calendario
            OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
            FETCH btch0001.cr_crapdat
                INTO rw_crapdat;
            CLOSE btch0001.cr_crapdat;
        
            BEGIN
                SELECT crapceb.insitceb
                      ,(SELECT COUNT(1)
                          FROM crapcob
                         WHERE crapcob.cdcooper = vr_cdcooper
                           AND crapcob.nrdconta = pr_nrdconta
                           AND crapcob.nrcnvcob = crapceb.nrconven) AS qtbolcob
                      ,(SELECT COUNT(1)
                          FROM crapceb
                         WHERE crapceb.cdcooper = vr_cdcooper
                           AND crapceb.nrdconta = pr_nrdconta
                           AND crapceb.insitceb IN (1, 5)
                           AND crapceb.idrecipr = pr_idrecipr
                           AND crapceb.nrconven <> pr_nrconven) AS qtcebati
                  INTO vr_insitceb
                      ,vr_qtbolcob
                      ,vr_qtcebati
                  FROM crapceb
                      ,crapcco
                 WHERE crapcco.cdcooper = crapceb.cdcooper
                   AND crapcco.nrconven = crapceb.nrconven
                   AND crapceb.cdcooper = vr_cdcooper
                   AND crapceb.nrdconta = pr_nrdconta
                   AND crapceb.nrconven = pr_nrconven
                   AND crapceb.idrecipr = pr_idrecipr;
            
            EXCEPTION
							  WHEN no_data_found THEN
									BEGIN
										SELECT crapceb.insitceb
													,(SELECT COUNT(1)
															FROM crapcob
														 WHERE crapcob.cdcooper = vr_cdcooper
															 AND crapcob.nrdconta = pr_nrdconta
															 AND crapcob.nrcnvcob = crapceb.nrconven) AS qtbolcob
													,(SELECT COUNT(1)
															FROM tbcobran_crapceb crapceb
														 WHERE crapceb.cdcooper = vr_cdcooper
															 AND crapceb.nrdconta = pr_nrdconta
															 AND crapceb.insitceb IN (1, 5)
															 AND crapceb.idrecipr = pr_idrecipr
															 AND crapceb.nrconven <> pr_nrconven) AS qtcebati
											INTO vr_insitceb
													,vr_qtbolcob
													,vr_qtcebati
											FROM tbcobran_crapceb crapceb
													,crapcco
										 WHERE crapcco.cdcooper = crapceb.cdcooper
											 AND crapcco.nrconven = crapceb.nrconven
											 AND crapceb.cdcooper = vr_cdcooper
											 AND crapceb.nrdconta = pr_nrdconta
											 AND crapceb.nrconven = pr_nrconven
											 AND crapceb.idrecipr = pr_idrecipr;
		            
								EXCEPTION
                WHEN OTHERS THEN
												vr_dscritic := '2.Erro ao buscar informacoes: ' || SQLERRM;
												RAISE vr_exc_saida;
								END;
                WHEN OTHERS THEN
                    vr_dscritic := '1.Erro ao buscar informacoes: ' || SQLERRM;
                    RAISE vr_exc_saida;
            END;
        
            -- Criar cabeçalho do XML
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'insitceb'
                                  ,pr_tag_cont => vr_insitceb
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'qtbolcob'
                                  ,pr_tag_cont => vr_qtbolcob
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'qtcebati'
                                  ,pr_tag_cont => vr_qtcebati
                                  ,pr_des_erro => vr_dscritic);
        
        EXCEPTION
            WHEN vr_exc_saida THEN
                IF vr_cdcritic <> 0 THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                END IF;
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrao para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;
            
                -- Carregar XML padrão para variavel de retorno
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        END;
    
    END pc_valida_exclusao_conven;

    PROCEDURE pc_busca_contratos(pr_cdcooper crapceb.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta crapceb.nrdconta%TYPE --> Número da conta
                                ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2 --> Erros do processo
                                 ) IS
        /* .............................................................................
          Programa: pc_busca_contratos
          Sistema : CECRED
          Sigla   : COBRAN
          Autor   : Augusto (Supero)
          Data    : Julho/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Retornar lista as opções do domínio enviado
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        CURSOR cr_lista_contratos(pr_cdcooper   crapceb.cdcooper%TYPE
                                 ,pr_nrdconta   crapceb.nrdconta%TYPE
                                 ,pr_data_corte crapprm.dsvlrprm%TYPE
                                 ,pr_cdoperad   tbrecip_aprovador_calculo.cdoperador%TYPE) IS
            SELECT DISTINCT ceb.list_cnv
                           ,ceb.idrecipr
                           ,ceb.dtcadast
                           ,ceb.insitceb
                           ,tac.dtalteracao_status dtultima_aprovacao
                           ,cal.dtinicio_vigencia_contrato
                           ,cal.dtfim_vigencia_contrato
                           ,add_months(cal.dtinicio_vigencia_contrato
                                      ,(SELECT to_number(dscodigo)
                                         FROM tbcobran_dominio_campo
                                        WHERE cddominio = cal.idfim_desc_adicional_coo
                                          AND nmdominio = 'TPMESES_RECIPRO')) AS dtfimdesc
                           ,CASE
                                WHEN (SELECT COUNT(1)
                                        FROM tbrecip_param_workflow    tpw
                                            ,tbrecip_aprovador_calculo tac
                                       WHERE tpw.cdcooper = tac.cdcooper
                                         AND tpw.cdalcada_aprovacao = tac.cdalcada_aprovacao
                                         AND tpw.cdcooper = pr_cdcooper
                                         AND tac.idcalculo_reciproci = ceb.idrecipr
                                         AND tac.idstatus = 'R'
                                         AND tpw.flregra_aprovacao = 1) > 0 THEN
                                 'Rejeitado'
                                WHEN (SELECT COUNT(1)
                                        FROM tbrecip_param_workflow tpw
                                       WHERE tpw.cdcooper = pr_cdcooper
                                         AND tpw.flregra_aprovacao = 1) > 0 AND
                                     (SELECT COUNT(1)
                                        FROM tbrecip_param_workflow tpw
                                       WHERE tpw.cdcooper = pr_cdcooper
                                         AND tpw.flregra_aprovacao = 1) =
                                     (SELECT COUNT(1)
                                        FROM tbrecip_param_workflow    tpw
                                            ,tbrecip_aprovador_calculo tac
                                            ,crapceb                   crapceb2
                                       WHERE tpw.cdcooper = tac.cdcooper
                                         AND tpw.cdalcada_aprovacao = tac.cdalcada_aprovacao
                                         AND tpw.cdcooper = pr_cdcooper
                                         AND tac.idcalculo_reciproci = ceb.idrecipr
                                         AND tac.idstatus = 'A'
                                         AND tac.cdcooper = crapceb2.cdcooper
                                         AND tac.idcalculo_reciproci = crapceb2.idrecipr
                                         AND crapceb2.insitceb = 1 -- Ativo
                                         AND tpw.flregra_aprovacao = 1) THEN
                                 'Aprovado'
                                ELSE
                                 CASE ceb.insitceb
                                     WHEN 1 THEN
                                      'Aprovado'
                                     WHEN 2 THEN
                                      'Inativo'
                                     WHEN 3 THEN
                                      'Em aprovação'
                                     WHEN 4 THEN
                                      'Rejeitado'
                                     WHEN 5 THEN
                                      'Aprovado'
                                     WHEN 6 THEN
                                      'Em aprovação'
                                     ELSE
                                      'Em aprovação'
                                 END
                            END idstatus
                           ,(SELECT COUNT(apr.idcalculo_reciproci)
                               FROM tbrecip_aprovador_calculo apr
                              WHERE apr.idcalculo_reciproci = ceb.idrecipr) qtdaprov
                           ,(SELECT COUNT(apr.idcalculo_reciproci)
                               FROM tbrecip_aprovador_calculo apr
                              WHERE apr.idcalculo_reciproci = ceb.idrecipr
                                AND apr.cdoperador = pr_cdoperad
                                 OR pr_cdoperad = NULL) insitapr
              FROM (SELECT listagg(crapceb.nrconven, ', ') within GROUP(ORDER BY crapceb.nrconven) list_cnv
                          ,crapceb.idrecipr
                          ,crapceb.dtcadast
																	 ,trunc(crapceb.dtinsori) dtinsori
                          ,CASE
                               WHEN (SELECT COUNT(1)
                                       FROM crapceb crapceb2
                                      WHERE crapceb2.nrdconta = crapceb.nrdconta
                                        AND crapceb2.cdcooper = crapceb.cdcooper
                                        AND crapceb2.insitceb = 1
                                        AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
                                1 -- Aprovado
                               WHEN (SELECT COUNT(1)
                                       FROM crapceb crapceb2
                                      WHERE crapceb2.nrdconta = crapceb.nrdconta
                                        AND crapceb2.cdcooper = crapceb.cdcooper
                                        AND crapceb2.insitceb = 2
                                        AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
                                2 -- Inativo
                               WHEN (SELECT COUNT(1)
                                       FROM crapceb crapceb2
                                      WHERE crapceb2.nrdconta = crapceb.nrdconta
                                        AND crapceb2.cdcooper = crapceb.cdcooper
                                        AND crapceb2.insitceb = 3
                                        AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
                                3 -- Em aprovação
                               WHEN (SELECT COUNT(1)
                                       FROM crapceb crapceb2
                                      WHERE crapceb2.nrdconta = crapceb.nrdconta
                                        AND crapceb2.cdcooper = crapceb.cdcooper
                                        AND crapceb2.insitceb = 4
                                        AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
                                4 -- Rejeitado
                               WHEN (SELECT COUNT(1)
                                       FROM crapceb crapceb2
                                      WHERE crapceb2.nrdconta = crapceb.nrdconta
                                        AND crapceb2.cdcooper = crapceb.cdcooper
                                        AND crapceb2.insitceb = 5
                                        AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
                                5 -- Aprovado
                               WHEN (SELECT COUNT(1)
                                       FROM crapceb crapceb2
                                      WHERE crapceb2.nrdconta = crapceb.nrdconta
                                        AND crapceb2.cdcooper = crapceb.cdcooper
                                        AND crapceb2.insitceb = 6
                                        AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
                                6 -- Em aprovação
                               ELSE
                                6 -- Em aprovação
                           END insitceb
                      FROM crapceb
                     WHERE crapceb.nrdconta = pr_nrdconta
                       AND crapceb.cdcooper = pr_cdcooper
                       AND crapceb.idrecipr > 0
                          /**/
                       AND crapceb.nrconven IN (SELECT nrconven
                                                  FROM crapcco
                                                 WHERE cdcooper = pr_cdcooper
                                                   AND flgativo = 1
                                                   AND flrecipr = 1
                                                   AND dsorgarq <> 'PROTESTO') /*verificar se este bloco esta ok*/
                     GROUP BY crapceb.idrecipr
                             ,crapceb.dtcadast
																	 ,trunc(crapceb.dtinsori)
                             ,crapceb.nrdconta
                             ,crapceb.cdcooper
													 UNION ALL
														 SELECT listagg(crapceb.nrconven, ', ') within GROUP(ORDER BY crapceb.nrconven) list_cnv
                          ,crapceb.idrecipr
                          ,crapceb.dtcadast
																	 ,trunc(crapceb.dtinsori) dtinsori
                          ,CASE
                               WHEN (SELECT COUNT(1)
																							FROM tbcobran_crapceb crapceb2
                                      WHERE crapceb2.nrdconta = crapceb.nrdconta
                                        AND crapceb2.cdcooper = crapceb.cdcooper
                                        AND crapceb2.insitceb = 1
                                        AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
                                1 -- Aprovado
                               WHEN (SELECT COUNT(1)
																							FROM tbcobran_crapceb crapceb2
                                      WHERE crapceb2.nrdconta = crapceb.nrdconta
                                        AND crapceb2.cdcooper = crapceb.cdcooper
                                        AND crapceb2.insitceb = 2
                                        AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
                                2 -- Inativo
                               WHEN (SELECT COUNT(1)
																						 FROM tbcobran_crapceb crapceb2
                                      WHERE crapceb2.nrdconta = crapceb.nrdconta
                                        AND crapceb2.cdcooper = crapceb.cdcooper
                                        AND crapceb2.insitceb = 3
                                        AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
                                3 -- Em aprovação
                               WHEN (SELECT COUNT(1)
																							FROM tbcobran_crapceb crapceb2
                                      WHERE crapceb2.nrdconta = crapceb.nrdconta
                                        AND crapceb2.cdcooper = crapceb.cdcooper
                                        AND crapceb2.insitceb = 4
                                        AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
                                4 -- Rejeitado
                               WHEN (SELECT COUNT(1)
																							FROM tbcobran_crapceb crapceb2
                                      WHERE crapceb2.nrdconta = crapceb.nrdconta
                                        AND crapceb2.cdcooper = crapceb.cdcooper
                                        AND crapceb2.insitceb = 5
                                        AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
                                5 -- Aprovado
                               WHEN (SELECT COUNT(1)
																							FROM tbcobran_crapceb crapceb2
                                      WHERE crapceb2.nrdconta = crapceb.nrdconta
                                        AND crapceb2.cdcooper = crapceb.cdcooper
                                        AND crapceb2.insitceb = 6
                                        AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
                                6 -- Em aprovação
                               ELSE
                                6 -- Em aprovação
																		END insitceb
															 FROM tbcobran_crapceb crapceb
															WHERE crapceb.nrdconta = pr_nrdconta
																AND crapceb.cdcooper = pr_cdcooper
																AND crapceb.idrecipr > 0
															 /**/
																AND crapceb.nrconven IN (SELECT nrconven
																													 FROM crapcco
																													WHERE cdcooper = pr_cdcooper
																														AND flgativo = 1
																														AND flrecipr = 1
																														AND dsorgarq <> 'PROTESTO') /*verificar se este bloco esta ok*/
													 GROUP BY crapceb.idrecipr
																	 ,crapceb.dtcadast
																	 ,trunc(crapceb.dtinsori)
																	 ,crapceb.nrdconta
																	 ,crapceb.cdcooper
                           -- Rafael Ferreira (Mouts) - INC0021997. Data: 14/08/19
                           /* Conforme alinhado com George Maicon Kruger (Ailos) a tela nova de
                              reciprocidade só deve mostrar Convenios que tenham idrecipr > 0*/
                           /*
													 UNION ALL
														 SELECT to_char(crapceb.nrconven)
																	 ,crapceb.idrecipr
																	 ,crapceb.dtcadast
																	 ,trunc(crapceb.dtinsori) dtinsori
																	 ,CASE
																			WHEN (SELECT COUNT(1)
																							FROM crapceb crapceb2
																						 WHERE crapceb2.nrdconta = crapceb.nrdconta
																							 AND crapceb2.cdcooper = crapceb.cdcooper
																							 AND crapceb2.insitceb = 1
																							 AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
																				1 -- Aprovado
																			WHEN (SELECT COUNT(1)
																							FROM crapceb crapceb2
																						 WHERE crapceb2.nrdconta = crapceb.nrdconta
																							 AND crapceb2.cdcooper = crapceb.cdcooper
																							 AND crapceb2.insitceb = 2
																							 AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
																				2 -- Inativo
																			WHEN (SELECT COUNT(1)
																							FROM crapceb crapceb2
																						 WHERE crapceb2.nrdconta = crapceb.nrdconta
																							 AND crapceb2.cdcooper = crapceb.cdcooper
																							 AND crapceb2.insitceb = 3
																							 AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
																				3 -- Em aprovação
																			WHEN (SELECT COUNT(1)
																							FROM crapceb crapceb2
																						 WHERE crapceb2.nrdconta = crapceb.nrdconta
																							 AND crapceb2.cdcooper = crapceb.cdcooper
																							 AND crapceb2.insitceb = 4
																							 AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
																				4 -- Rejeitado
																			WHEN (SELECT COUNT(1)
																							FROM crapceb crapceb2
																						 WHERE crapceb2.nrdconta = crapceb.nrdconta
																							 AND crapceb2.cdcooper = crapceb.cdcooper
																							 AND crapceb2.insitceb = 5
																							 AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
																				5 -- Aprovado
																			WHEN (SELECT COUNT(1)
																							FROM crapceb crapceb2
																						 WHERE crapceb2.nrdconta = crapceb.nrdconta
																							 AND crapceb2.cdcooper = crapceb.cdcooper
																							 AND crapceb2.insitceb = 6
																							 AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
																				6 -- Em aprovação
																			ELSE
																				6 -- Em aprovação
                           END
                      FROM crapceb
																	WHERE crapceb.nrdconta = pr_nrdconta
																		AND crapceb.cdcooper = pr_cdcooper
																		AND crapceb.idrecipr = 0
																	 --
																		AND crapceb.nrconven IN (SELECT nrconven
																															FROM crapcco
																														 WHERE cdcooper = pr_cdcooper
																															 AND flgativo = 1
																															 AND flrecipr = 1
																															 AND dsorgarq <> 'PROTESTO') --verificar se este bloco esta ok
													 UNION ALL
														 SELECT to_char(crapceb.nrconven)
																	 ,crapceb.idrecipr
																	 ,crapceb.dtcadast
																	 ,trunc(crapceb.dtinsori) dtinsori
																	 ,CASE
																			WHEN (SELECT COUNT(1)
																							FROM tbcobran_crapceb crapceb2
																						 WHERE crapceb2.nrdconta = crapceb.nrdconta
																							 AND crapceb2.cdcooper = crapceb.cdcooper
																							 AND crapceb2.insitceb = 1
																							 AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
																				1 -- Aprovado
																			WHEN (SELECT COUNT(1)
																							FROM tbcobran_crapceb crapceb2
																						 WHERE crapceb2.nrdconta = crapceb.nrdconta
																							 AND crapceb2.cdcooper = crapceb.cdcooper
																							 AND crapceb2.insitceb = 2
																							 AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
																				2 -- Inativo
																			WHEN (SELECT COUNT(1)
																							FROM tbcobran_crapceb crapceb2
																						 WHERE crapceb2.nrdconta = crapceb.nrdconta
																							 AND crapceb2.cdcooper = crapceb.cdcooper
																							 AND crapceb2.insitceb = 3
																							 AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
																				3 -- Em aprovação
																			WHEN (SELECT COUNT(1)
																							FROM tbcobran_crapceb crapceb2
																						 WHERE crapceb2.nrdconta = crapceb.nrdconta
																							 AND crapceb2.cdcooper = crapceb.cdcooper
																							 AND crapceb2.insitceb = 4
																							 AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
																				4 -- Rejeitado
																			WHEN (SELECT COUNT(1)
																							FROM tbcobran_crapceb crapceb2
																						 WHERE crapceb2.nrdconta = crapceb.nrdconta
																							 AND crapceb2.cdcooper = crapceb.cdcooper
																							 AND crapceb2.insitceb = 5
																							 AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
																				5 -- Aprovado
																			WHEN (SELECT COUNT(1)
																							FROM tbcobran_crapceb crapceb2
																						 WHERE crapceb2.nrdconta = crapceb.nrdconta
																							 AND crapceb2.cdcooper = crapceb.cdcooper
																							 AND crapceb2.insitceb = 6
																							 AND crapceb2.idrecipr = crapceb.idrecipr) >= 1 THEN
																				6 -- Em aprovação
																			ELSE
																				6 -- Em aprovação
																		END
																	 FROM tbcobran_crapceb crapceb
                     WHERE crapceb.nrdconta = pr_nrdconta
                       AND crapceb.cdcooper = pr_cdcooper
                       AND crapceb.idrecipr = 0
                          --
                       AND crapceb.nrconven IN (SELECT nrconven
                                                  FROM crapcco
                                                 WHERE cdcooper = pr_cdcooper
                                                   AND flgativo = 1
                                                   AND flrecipr = 1
                                                   AND dsorgarq <> 'PROTESTO') --verificar se este bloco esta ok
                                                   */
                    ) ceb
                  ,tbrecip_aprovador_calculo tac
                  ,tbrecip_calculo cal
             WHERE ceb.idrecipr = tac.idcalculo_reciproci(+)
               AND ceb.idrecipr = cal.idcalculo_reciproci(+)
               AND ceb.dtinsori >= to_date(pr_data_corte, 'DD/MM/RRRR')
               AND (tac.dtalteracao_status IS NULL OR
                   tac.dtalteracao_status = (SELECT MAX(tac2.dtalteracao_status)
                                                FROM tbrecip_aprovador_calculo tac2
                                               WHERE tac2.idcalculo_reciproci = tac.idcalculo_reciproci
                                                 AND tac2.idstatus IN ('A','R')))
             ORDER BY CASE ceb.insitceb
                          WHEN 3 THEN
                           0
                          ELSE
                           ceb.insitceb
                      END
                     ,CASE
                          WHEN dtinicio_vigencia_contrato IS NULL THEN
                           to_date('31/12/1969', 'DD/MM/RRRR')
                          ELSE
                           dtinicio_vigencia_contrato
                      END DESC;
        rw_lista_contratos cr_lista_contratos%ROWTYPE;
    
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
    
        -- Variáveis para armazenar as informações em XML
        vr_des_xml CLOB;
        -- Variável para armazenar os dados do XML antes de incluir no CLOB
        vr_texto_completo VARCHAR2(32600);
        -- Subrotina para escrever texto na variável CLOB do XML
        PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                                ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
        BEGIN
            --
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
            --
        END;
        --
    
    BEGIN
        -- Extrai os dados vindos do XML
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        -- Inicializar o CLOB
        vr_des_xml := NULL;
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informações do XML
        vr_texto_completo := NULL;
    
        pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1"?><root><dados>');
        --
        FOR rw_lista_contratos IN cr_lista_contratos(pr_cdcooper   => pr_cdcooper
                                                    ,pr_nrdconta   => pr_nrdconta
                                                    ,pr_data_corte => fn_busca_data_corte
                                                    ,pr_cdoperad   => vr_cdoperad) LOOP
            --
            pc_escreve_xml('<inf>' || '<list_cnv>' || rw_lista_contratos.list_cnv || '</list_cnv>' ||
                           '<status>' || rw_lista_contratos.idstatus || '</status>' || '<dtcadast>' ||
                           to_char(rw_lista_contratos.dtcadast, 'DD/MM/RRRR') || '</dtcadast>' ||
                           '<dtultaprov>' || to_char(rw_lista_contratos.dtultima_aprovacao, 'DD/MM/RRRR') ||
                           '</dtultaprov>' || '<dtinivig>' ||
                           to_char(rw_lista_contratos.dtinicio_vigencia_contrato, 'DD/MM/RRRR') ||
                           '</dtinivig>' || '<dtfimvig>' ||
                           to_char(rw_lista_contratos.dtfim_vigencia_contrato, 'DD/MM/RRRR') || '</dtfimvig>' ||
                           '<dtfimdesc>' || to_char(rw_lista_contratos.dtfimdesc, 'DD/MM/RRRR') ||
                           '</dtfimdesc>' || '<idrecipr>' || rw_lista_contratos.idrecipr || '</idrecipr>' ||
                           '<insitceb>' || rw_lista_contratos.insitceb || '</insitceb>' || '<qtdaprov>' ||
                           rw_lista_contratos.qtdaprov || '</qtdaprov>' || '<insitapr>' ||
                           rw_lista_contratos.insitapr || '</insitapr>' || '</inf>');
            --
        END LOOP;
        --
        pc_escreve_xml('</dados></root>', TRUE);
        --
        pr_retxml := xmltype.createxml(vr_des_xml);
        --
    EXCEPTION
        WHEN vr_exc_saida THEN
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
            --
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            --
            ROLLBACK;
        WHEN OTHERS THEN
            --
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina' || ': ' || SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
            ROLLBACK;
            --
    END pc_busca_contratos;

    PROCEDURE pc_busca_vinculacao(pr_nrdconta IN crapceb.idrecipr%TYPE --> Nr. da Reciprocidade
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS
        /* .............................................................................
          Programa: pc_busca_data_corte
          Sistema : CECRED
          Sigla   : COBRAN
          Autor   : Augusto (Supero)
          Data    : Agosto/18.                    Ultima atualizacao: 27/08/2019
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo: Retornar a data de corte dos contratos, usado para distinguir os contratos antigos dos novos
        
          Observacao: -----
        
          Alteracoes: 27/08/2019 - Rafael Ferreira (Mouts) - INC0023442 - Alterada tabela crapass para tbcc_associados
        ..............................................................................*/
    
        -- Vinculação
        vr_nmvinculacao tbrecip_vinculacao.nmvinculacao%TYPE;
        vr_idvinculacao tbrecip_vinculacao.idvinculacao%TYPE;
    
        -- Variaveis de log
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variavel de criticas
        vr_dscritic VARCHAR2(10000);
    
    BEGIN
        -- Extrai os dados vindos do XML
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        BEGIN
            SELECT v.nmvinculacao
                  ,v.idvinculacao
              INTO vr_nmvinculacao
                  ,vr_idvinculacao
              FROM tbcc_associados    s
                  ,tbrecip_vinculacao v
             WHERE s.cdcooper = vr_cdcooper
               AND s.nrdconta = pr_nrdconta
               AND v.idvinculacao = s.cdvinculacao; /* FIXME */
        EXCEPTION
            WHEN no_data_found THEN
							  BEGIN
								--
								SELECT tv.nmvinculacao
								      ,tv.idvinculacao
								  INTO vr_nmvinculacao
                      ,vr_idvinculacao
									FROM tbrecip_vinculacao tv
								 WHERE tv.idvinculacao = 4;
								--
							EXCEPTION 
								WHEN no_data_found THEN
									vr_idvinculacao := 0;
									vr_nmvinculacao := '';
							END;
        END;
    
        -- Criar cabecalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmvinculacao'
                              ,pr_tag_cont => vr_nmvinculacao
                              ,pr_des_erro => vr_dscritic);
        --
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'idvinculacao'
                              ,pr_tag_cont => vr_idvinculacao
                              ,pr_des_erro => vr_dscritic);
    
    END pc_busca_vinculacao;

    PROCEDURE pc_gera_log_conv(pr_cdcooper            IN tbrecip_log_contrato.cdcooper%TYPE
                              ,pr_idcalculo_reciproci IN tbrecip_log_contrato.idcalculo_reciproci%TYPE
                              ,pr_cdoperador          IN tbrecip_log_contrato.cdoperador%TYPE
                              ,pr_dshistorico         IN VARCHAR2
                              ,pr_cdcritic            OUT PLS_INTEGER --> Codigo da critica
                              ,pr_dscritic            OUT VARCHAR2 --> Descricao da critica
                               ) IS
        /* .............................................................................
          Programa: pc_gera_log_conv
          Sistema : CECRED
          Sigla   : COBRAN
          Autor   : Augusto (Supero)
          Data    : Agosto/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Gera log de alteração de convênio.
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        -- Cursor generico de calendario
        --rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
        -- Variavel de criticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
    
        -- Tratamento de erros
        vr_exc_saida EXCEPTION;
    
        -- Busca o operador
        CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                         ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
            SELECT 1
              FROM crapope
             WHERE crapope.cdcooper = pr_cdcooper
               AND crapope.cdoperad = pr_cdoperad;
        rw_crapope cr_crapope%ROWTYPE;
    
    BEGIN
        --
        /*OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;*/
        gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_COBRAN');
        --
        IF pr_cdcooper IS NULL THEN
            pr_dscritic := 'A cooperativa é obrigatória. ' || SQLERRM;
            RAISE vr_exc_saida;
        END IF;
        --
        IF pr_dshistorico IS NULL THEN
            pr_dscritic := 'A descrição do log é obrigatória. ' || SQLERRM;
            RAISE vr_exc_saida;
        END IF;
        --
        IF pr_idcalculo_reciproci IS NULL THEN
            pr_dscritic := 'A reciprocidade do log é obrigatória. ' || SQLERRM;
            RAISE vr_exc_saida;
        END IF;
        --
        IF pr_cdoperador IS NULL THEN
            pr_dscritic := 'O operador é obrigatório. ' || SQLERRM;
            RAISE vr_exc_saida;
        END IF;
        --
        OPEN cr_crapope(pr_cdcooper => pr_cdcooper, pr_cdoperad => pr_cdoperador);
        FETCH cr_crapope
            INTO rw_crapope;
        --
        IF NOT cr_crapope%FOUND THEN
            vr_cdcritic := 67;
            RAISE vr_exc_saida;
        END IF;
        --
        CLOSE cr_crapope;
        --
        INSERT INTO tbrecip_log_contrato
            (cdcooper, idcalculo_reciproci, cdoperador, dshistorico, dthistorico)
        VALUES
            (pr_cdcooper, pr_idcalculo_reciproci, pr_cdoperador, pr_dshistorico, SYSDATE);
        --
    
    EXCEPTION
        WHEN vr_exc_saida THEN
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            END IF;
        WHEN OTHERS THEN
            --
            pr_cdcritic := vr_cdcritic;
            --
    END pc_gera_log_conv;

    PROCEDURE pc_valida_convenio(pr_cdcooper IN crapceb.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta IN crapceb.nrdconta%TYPE --> Número da conta
                                ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2 --> Erros do processo
                                 ) IS
        /* .............................................................................
          Programa: pc_valida_convenio
          Sistema : CECRED
          Sigla   : COBRAN
          Autor   : Augusto (Supero)
          Data    : Julho/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Retornar lista as opções do domínio enviado
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        CURSOR cr_lista_contratos(pr_cdcooper crapceb.cdcooper%TYPE
                                 ,pr_nrdconta crapceb.nrdconta%TYPE) IS
        
            SELECT listagg(crapceb.nrconven, '; ') within GROUP(ORDER BY crapceb.nrconven) list_cnv
                  ,crapceb.idrecipr
                  ,crapceb.dtcadast
              FROM crapceb
             WHERE crapceb.nrdconta = pr_nrdconta
               AND crapceb.cdcooper = pr_cdcooper
               AND crapceb.idrecipr > 0
             GROUP BY crapceb.idrecipr
                     ,crapceb.dtcadast
					 UNION ALL
            SELECT to_char(crapceb.nrconven)
                  ,crapceb.idrecipr
                  ,crapceb.dtcadast
              FROM crapceb
					 WHERE crapceb.nrdconta = pr_nrdconta
						 AND crapceb.cdcooper = pr_cdcooper
						 AND crapceb.idrecipr = 0
					 UNION ALL
					SELECT listagg(crapceb.nrconven, '; ') within GROUP(ORDER BY crapceb.nrconven) list_cnv
								,crapceb.idrecipr
								,crapceb.dtcadast
						FROM tbcobran_crapceb crapceb
					 WHERE crapceb.nrdconta = pr_nrdconta
						 AND crapceb.cdcooper = pr_cdcooper
						 AND crapceb.idrecipr > 0
					 GROUP BY crapceb.idrecipr
									 ,crapceb.dtcadast
					UNION ALL
					SELECT to_char(crapceb.nrconven)
								,crapceb.idrecipr
								,crapceb.dtcadast
						FROM tbcobran_crapceb crapceb
             WHERE crapceb.nrdconta = pr_nrdconta
               AND crapceb.cdcooper = pr_cdcooper
               AND crapceb.idrecipr = 0;
        rw_lista_contratos cr_lista_contratos%ROWTYPE;
    BEGIN
        -- Criar XML de retorno para uso na Web
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><nmcartorio>' || '' ||
                                       '</nmcartorio>');
    END pc_valida_convenio;

    PROCEDURE pc_cancela_descontos(pr_idcalculo_reciproci IN tbrecip_calculo.idcalculo_reciproci%TYPE --> Id da reciprocidade
			                            ,pr_nrdconta            IN crapceb.nrdconta%TYPE --> Numero da conta
                                  ,pr_xmllog              IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic            OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic            OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml              IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo            OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro            OUT VARCHAR2 --> Erros do processo
                                   ) IS
        /* .............................................................................
          Programa: pc_cancela_descontos
          Sistema : CECRED
          Sigla   : COBRAN
          Autor   : Augusto Conceição (SUPERO)
          Data    : Agosto/18.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Cancelar contratos de reciprocidade
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
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
    vr_qtdboltos INTEGER;

    -- Calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  			
        -- Variaveis
        vr_dtfimrel VARCHAR2(8);
        vr_nrdconta crapceb.nrdconta%TYPE;
        vr_nrconven VARCHAR2(10);

    CURSOR cr_crapceb(pr_cdcooper            IN crapceb.cdcooper%TYPE
			                 ,pr_nrdconta            IN crapceb.nrdconta%TYPE
                       ,pr_idcalculo_reciproci IN crapceb.idrecipr%TYPE
											 ) IS
        SELECT nrdconta
					FROM crapceb
				 WHERE cdcooper = pr_cdcooper
				   AND nrdconta = pr_nrdconta
					 AND idrecipr = pr_idcalculo_reciproci
				 UNION ALL
				SELECT nrdconta
					FROM tbcobran_crapceb
				 WHERE cdcooper = pr_cdcooper
				   AND nrdconta = pr_nrdconta
					 AND idrecipr = pr_idcalculo_reciproci;
  						 
    CURSOR cr_convenios(pr_cdcooper            IN crapceb.cdcooper%TYPE
			                   ,pr_nrdconta            IN crapceb.nrdconta%TYPE
								         ,pr_idcalculo_reciproci IN crapceb.idrecipr%TYPE
												 ) IS
      SELECT ceb.nrconven
        FROM crapceb ceb
       WHERE ceb.cdcooper = pr_cdcooper
				   AND ceb.nrdconta = pr_nrdconta
					 AND ceb.idrecipr = pr_idcalculo_reciproci
		 UNION ALL
		    SELECT ceb.nrconven
					FROM tbcobran_crapceb ceb
				 WHERE ceb.cdcooper = pr_cdcooper
				   AND ceb.nrdconta = pr_nrdconta
         AND ceb.idrecipr = pr_idcalculo_reciproci;
        rw_convenios cr_convenios%ROWTYPE;
  			
        --> Busca associado
        CURSOR cr_crapass(pr_cdcooper IN crapcco.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
            SELECT ass.inpessoa
                  ,to_char(ass.nrcpfcgc) nrcpfcgc
                  ,to_char(ass.nrdconta) nrdconta
                  ,decode(ass.inpessoa, 1, lpad(ass.nrcpfcgc, 11, '0'), lpad(ass.nrcpfcgc, 14, '0')) dscpfcgc
                  ,decode(ass.inpessoa, 1, 'F', 'J') dspessoa
                  ,to_char(cop.cdagectl) cdagectl
              FROM crapass ass
                  ,crapcop cop
             WHERE ass.cdcooper = cop.cdcooper
               AND ass.cdcooper = pr_cdcooper
               AND ass.nrdconta = pr_nrdconta;
        rw_crapass cr_crapass%ROWTYPE;
        
			CURSOR c_qtdBoleto(pr_cdcooper            IN crapcco.cdcooper%TYPE
			                  ,pr_nrdconta            IN crapass.nrdconta%TYPE
                       ,pr_idcalculo_reciproci IN crapceb.idrecipr%TYPE
												) IS
				SELECT COUNT(1)
              FROM crapcob
             WHERE crapcob.cdcooper = pr_cdcooper
               AND crapcob.nrdconta = pr_nrdconta
					 AND crapcob.nrcnvcob IN(SELECT a.nrconven
																		 FROM crapceb a
                                         where a.idrecipr = pr_idcalculo_reciproci
																			AND a.cdcooper = crapcob.cdcooper
																			AND a.nrdconta = crapcob.nrdconta 
																			AND a.insitceb = 1
																		UNION ALL
																	 SELECT a.nrconven
																		 FROM tbcobran_crapceb a
																		where a.idrecipr = pr_idcalculo_reciproci
																			AND a.cdcooper = crapcob.cdcooper
																			AND a.nrdconta = crapcob.nrdconta 
																			AND a.insitceb = 1
																	);
      --
  BEGIN
    -- Extrai os dados vindos do XML
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                ,pr_cdcooper => vr_cdcooper
                ,pr_nmdatela => vr_nmdatela
                ,pr_nmeacao  => vr_nmeacao
                ,pr_cdagenci => vr_cdagenci
                ,pr_nrdcaixa => vr_nrdcaixa
                ,pr_idorigem => vr_idorigem
                ,pr_cdoperad => vr_cdoperad
                ,pr_dscritic => vr_dscritic);

    IF TRIM(pr_idcalculo_reciproci) IS NULL OR pr_idcalculo_reciproci = 0 THEN
            vr_dscritic := 'Contrato informado nao encontrado.';
      RAISE vr_exc_saida;
    END IF;

    pc_gera_log_conv(pr_cdcooper            => vr_cdcooper
            ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
            ,pr_cdoperador          => vr_cdoperad
                        ,pr_dshistorico         => 'Fim da vigencia devido ao cancelamento.'
            ,pr_cdcritic            => vr_cdcritic
            ,pr_dscritic            => vr_dscritic);

        OPEN cr_crapceb(pr_cdcooper            => vr_cdcooper
				               ,pr_nrdconta            => pr_nrdconta
				               ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
											 );
    FETCH cr_crapceb INTO vr_nrdconta;
        -- Alimenta a booleana se achou ou nao
    IF cr_crapceb%NOTFOUND THEN
          CLOSE cr_crapceb;
          vr_dscritic := 'Contrato informado nao encontrado.';
          RAISE vr_exc_saida;
    END IF;
    -- Fecha cursor
    CLOSE cr_crapceb;
  			
        --> Busca associado
        OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
											 );
  			
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
            CLOSE cr_crapass;
            vr_cdcritic := 9;
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapass;
        
        -- Valida a quantidade de boletos emitidos pelo contrato, 
        --caso haja, não poderá cancelar o contrato
      OPEN c_qtdBoleto(pr_cdcooper => vr_cdcooper
                       ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
												,pr_nrdconta            => pr_nrdconta
												);
      FETCH c_qtdBoleto INTO vr_qtdboltos;  
      
      IF c_qtdBoleto%NOTFOUND or vr_qtdboltos <> 0 THEN
            CLOSE c_qtdBoleto;
            vr_dscritic := 'Contrato possui boletos emitidos.';
            RAISE vr_exc_saida;
        END IF;
        CLOSE c_qtdBoleto;

    -- Busca do calendário
    OPEN btch0001.cr_crapdat(vr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    BEGIN
      UPDATE crapceb
         SET insitceb = 2
       WHERE cdcooper = vr_cdcooper
						   AND nrdconta = pr_nrdconta
         AND idrecipr = pr_idcalculo_reciproci;
    EXCEPTION
					WHEN no_data_found THEN
						BEGIN
							UPDATE tbcobran_crapceb
								 SET insitceb = 2
							 WHERE cdcooper = vr_cdcooper
							   AND nrdconta = pr_nrdconta
								 AND idrecipr = pr_idcalculo_reciproci;
						EXCEPTION
      WHEN OTHERS THEN
								vr_dscritic := '2.Erro ao atualizar situacao na ceb. ' || SQLERRM;
								RAISE vr_exc_saida;
						END;
							WHEN OTHERS THEN
								vr_dscritic := '1.Erro ao atualizar situacao na ceb. ' || SQLERRM;
        RAISE vr_exc_saida;
    END;

    BEGIN
      UPDATE tbrecip_calculo
         SET dtfim_vigencia_contrato = rw_crapdat.dtmvtolt
       WHERE idcalculo_reciproci = pr_idcalculo_reciproci;
    EXCEPTION
      WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar data fim do calculo. ' || SQLERRM;
        RAISE vr_exc_saida;
    END;

    IF NOT TRIM(vr_dscritic) IS NULL THEN
      RAISE vr_exc_saida;
    END IF;
  			
				FOR rw_convenios IN cr_convenios(pr_cdcooper            => vr_cdcooper
					                              ,pr_nrdconta            => pr_nrdconta
					                              ,pr_idcalculo_reciproci => pr_idcalculo_reciproci
																				) LOOP
          BEGIN
						--
              vr_dtfimrel := to_char(rw_crapdat.dtmvtolt, 'RRRRMMDD');						
              vr_nrconven := to_char(rw_convenios.nrconven);
						--
              UPDATE cecredleg.tbjdddabnf_convenio@jdnpcsql
                 SET TBJDDDABNF_Convenio."SitConvBenfcrioPar" = 'E'
                     ,TBJDDDABNF_Convenio."DtFimRelctConv"     = vr_dtfimrel
               WHERE TBJDDDABNF_Convenio."ISPB_IF" = '05463212'
                 AND TBJDDDABNF_Convenio."TpPessoaBenfcrio" = rw_crapass.dspessoa
                 AND TBJDDDABNF_Convenio."CNPJ_CPFBenfcrio" = rw_crapass.dscpfcgc
                 AND TBJDDDABNF_Convenio."CodCli_Conv" = vr_nrconven
                 AND TBJDDDABNF_Convenio."AgDest" = rw_crapass.cdagectl
                 AND TBJDDDABNF_Convenio."CtDest" = rw_crapass.nrdconta;
  			    --
          EXCEPTION
              WHEN OTHERS THEN
                  vr_dscritic := 'Nao foi possivel atualizar convenio na CIP: ' || SQLERRM;
                  RAISE vr_exc_saida;
          END;
        END LOOP;
  	
        COMMIT;
        npcb0002.pc_libera_sessao_sqlserver_npc('TELA_ATENDA_COBRAN_1');

    -- Criar cabeçalho do XML
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados><retorno>1</retorno></Dados>');

  EXCEPTION
        WHEN vr_exc_saida THEN
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
						ELSE
							--
							pr_dscritic := vr_dscritic; 
							--
            END IF;
            --
            pr_des_erro := vr_dscritic;
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           vr_dscritic || '</Erro></Root>');
            --
            ROLLBACK;
        WHEN OTHERS THEN
            --
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
            pr_des_erro := vr_dscritic;
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           vr_dscritic || '</Erro></Root>');
            ROLLBACK;
            --
    END pc_cancela_descontos;
    -- PRJ431

    -- Rafael Ferreira Mouts - INC0020100 - Situac 3
    PROCEDURE pc_consulta_convenio(pr_cdcooper    IN crapcop.cdcooper%TYPE
                                   ,pr_nrdconta   IN crapass.nrdconta%TYPE
                                   ,pr_nrconven   IN crapceb.nrconven%TYPE
                                   ,pr_xmllog     IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro   OUT VARCHAR2 --> Erros do processo
                                    ) IS
        /* .............................................................................
          Programa: pc_consulta_convenio
          Sistema : CECRED
          Sigla   : TELA_ATENDA_COBRAN
          Autor   : Rafael Ferreira (Mouts)
          Data    : Agosto/19.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Retornar informações do convenio do Cooperado.
        
          Observacao: Esta procedure foi criada devido
                      a necessidade de pesquisar o convenio existente do Cooperado no momento da INCLUSAO na nova
                      tela de reciprocidade. Na estrutura atual o sistema usa o idrecipr para fazer a busca dos 
                      convenios existentes, porém isso não atende para pesquisar convenios antigos. Neste sentido
                      foi necessário criar esta procedure para pesquisar buscando pelo numero do convenio SOMENTE
                      na INCLUSAO da tela de Cobrança.
                      ServiceNow: INC0020100
        
          Alteracoes:
        ..............................................................................*/
    
        -- Cursores
        -- Busca o Convenio crapceb
        CURSOR cr_convenio(pr_cdcooper   crapceb.cdcooper%TYPE
                           ,pr_nrdconta  crapass.nrdconta%TYPE
                           ,pr_nrconven  crapceb.nrconven%TYPE) IS
        
            SELECT crapceb.nrconven
                  ,crapcco.dsorgarq
                  ,crapceb.insitceb
                  ,crapceb.flgregon
                  ,crapceb.flgpgdiv
                  ,crapceb.flcooexp
                  ,crapceb.flceeexp
                  ,crapceb.qtdfloat
                  ,crapceb.flserasa
                  ,crapceb.flprotes
                  ,crapceb.insrvprt
                  ,crapceb.qtlimmip
                  ,crapceb.qtlimaxp
                  ,crapceb.qtdecprz
                  ,crapceb.inarqcbr
                  ,crapceb.inenvcob
                  ,crapceb.cddemail
                  ,crapceb.flgcebhm
                  ,crapceb.flgapihm
                  ,(SELECT COUNT(1)
                      FROM crapcob
                     WHERE crapcob.cdcooper = pr_cdcooper
                       AND crapcob.nrdconta = pr_nrdconta
                       AND crapcob.nrcnvcob = crapceb.nrconven) AS qtbolcob
              FROM crapceb
                  ,crapcco
             WHERE crapcco.cdcooper = crapceb.cdcooper
               AND crapcco.nrconven = crapceb.nrconven
               AND crapceb.cdcooper = pr_cdcooper
               AND crapceb.nrdconta = pr_nrdconta
               and crapceb.nrconven = pr_nrconven
               /*Conforme alinhado com George, o Convenio antigo precisa ser desativado para incluir o novo
               Nesse caso não deve filtrar situação do convenio*/
               --and crapceb.insitceb = 1
               ;
        rw_convenio cr_convenio%ROWTYPE;
    
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
        vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
        -- Tratamento de erros
        vr_exc_saida EXCEPTION;
        vr_nrdrowid rowid;
    
        -- Variaveis de log
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis internas
        vr_convfound BOOLEAN;
        

    
    BEGIN
        -- Incluir nome do módulo logado
        gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_COBRAN', pr_action => NULL);
    
        -- Extrai os dados vindos do XML
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        
    
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    

        -- Busca o cadastro de convenio
        OPEN cr_convenio(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta, pr_nrconven => pr_nrconven);
        FETCH cr_convenio
            INTO rw_convenio;
            
        -- Alimenta a booleana se achou ou nao
        vr_convfound := cr_convenio%FOUND;
        -- Fecha cursor
        CLOSE cr_convenio;
        
        -- Se NAO encontrou
        IF NOT vr_convfound THEN
            vr_cdcritic := 563;
            RAISE vr_exc_saida;
        END IF;

            
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Convenio'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
            
                                  
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'convenio'
                                  ,pr_tag_cont => rw_convenio.nrconven
                                  ,pr_des_erro => vr_dscritic);
                                  
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'tipo'
                                  ,pr_tag_cont => rw_convenio.dsorgarq
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'insitceb'
                                  ,pr_tag_cont => rw_convenio.insitceb
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flgregon'
                                  ,pr_tag_cont => rw_convenio.flgregon
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flgpgdiv'
                                  ,pr_tag_cont => rw_convenio.flgpgdiv
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flcooexp'
                                  ,pr_tag_cont => rw_convenio.flcooexp
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flceeexp'
                                  ,pr_tag_cont => rw_convenio.flceeexp
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'qtdfloat'
                                  ,pr_tag_cont => rw_convenio.qtdfloat
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flserasa'
                                  ,pr_tag_cont => rw_convenio.flserasa
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flprotes'
                                  ,pr_tag_cont => rw_convenio.flprotes
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'insrvprt'
                                  ,pr_tag_cont => rw_convenio.insrvprt
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'qtlimmip'
                                  ,pr_tag_cont => rw_convenio.qtlimmip
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'qtlimaxp'
                                  ,pr_tag_cont => rw_convenio.qtlimaxp
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'qtdecprz'
                                  ,pr_tag_cont => rw_convenio.qtdecprz
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'inarqcbr'
                                  ,pr_tag_cont => rw_convenio.inarqcbr
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'inenvcob'
                                  ,pr_tag_cont => rw_convenio.inenvcob
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'cddemail'
                                  ,pr_tag_cont => rw_convenio.cddemail
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'divCnvHomol'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
                
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flgcebhm'
                                  ,pr_tag_cont => rw_convenio.flgcebhm
                                  ,pr_des_erro => vr_dscritic);


            gene0007.pc_insere_tag(pr_xml       => pr_retxml
                                   ,pr_tag_pai  => 'Convenio'
                                   ,pr_posicao  => 0
                                   ,pr_tag_nova => 'qtbolcob'
                                   ,pr_tag_cont => rw_convenio.qtbolcob
                                   ,pr_des_erro => vr_dscritic);
                                   

            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Convenio'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'flgapihm'
                                  ,pr_tag_cont => rw_convenio.flgapihm
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
            --
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            --
            ROLLBACK;
        WHEN OTHERS THEN
            --
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
            pr_des_erro := 'NOK';

            -- Carregar XML padrão para variável de retorno.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            --
            ROLLBACK;
            --
    END pc_consulta_convenio;


END tela_atenda_cobran;
/
