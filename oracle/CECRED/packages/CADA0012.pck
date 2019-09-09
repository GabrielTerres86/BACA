CREATE OR REPLACE PACKAGE CECRED.cada0012 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0012
  --  Sistema  : Rotinas para cadastros de Pessoas. Chamada pela SOA
  --  Sigla    : CADA
  --  Autor    : Andrino Carlos de Souza Junior (Mouts)
  --  Data     : Julho/2017.                   Ultima atualizacao: 29/04/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: OnLine
  -- Objetivo  :
  --
  ---------------------------------------------------------------------------------------------------------------
  FUNCTION fn_busca_contas_atualizar RETURN CLOB;

  -- Rotina para cadastro de bens
  PROCEDURE pc_cadast_pessoa_bem(pr_idpessoa        IN NUMBER -- identificador unico da pessoa (fk tbcadast_pessoa)
                                ,pr_nrseq_bem       IN OUT NUMBER -- numero sequencial do bem
                                ,pr_dsbem           IN VARCHAR2 -- descricao do bem
                                ,pr_pebem           IN NUMBER -- percentual do bem livre de onus
                                ,pr_qtparcela_bem   IN NUMBER
                                ,pr_vlbem           IN NUMBER
                                ,pr_vlparcela_bem   IN NUMBER
                                ,pr_dtalteracao     IN DATE
                                ,pr_cdoperad_altera IN VARCHAR2
                                ,pr_dscritic        OUT VARCHAR2);

  -- Rotina para excluir bem
  PROCEDURE pc_exclui_pessoa_bem(pr_idpessoa        IN NUMBER   -- Identificador de pessoa
															  ,pr_nrseq_bem       IN NUMBER   -- Nr. de sequência de bem
															  ,pr_cdoperad_altera IN VARCHAR2 -- Operador que esta efetuando a exclusao
															  ,pr_cdcritic        OUT INTEGER                             -- Codigo de erro
															  ,pr_dscritic        OUT VARCHAR2);                          -- Retorno de Erro

  -- Rotina para retorno de bens
  PROCEDURE pc_retorna_pessoa_bem(pr_idpessoa IN NUMBER -- Registro de bens
                                 ,pr_retorno  OUT xmltype -- XML de retorno
                                 ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro

  -- Verifica se o operador possui acesso ao sistema
  PROCEDURE pc_valida_acesso_operador(pr_cdcooper IN NUMBER, -- Codigo da cooperativa
                                      pr_cdoperad IN VARCHAR2, -- Codigo do operador
                                      pr_cdagenci IN NUMBER, -- Codigo da agencia
                                      pr_fltoken  IN VARCHAR2 DEFAULT 'S', -- Flag se deve ser alterado o token
                                      pr_tpcanal_sistema  IN NUMBER DEFAULT 10, -- Sistema que esta solicitando acesso 10-CRM, 13-Ibracred
                                      pr_dstoken  OUT VARCHAR2, -- Token de retorno nos casos de sucesso na validacao
                                      pr_dscritic OUT VARCHAR2);  -- Retorno de Erro

  -- ROtina para mesclar duas pessoas em uma unica pessoa
  PROCEDURE pc_mesclar_pessoa(pr_idpessoa_origem  IN NUMBER -- Identificador unico da pessoa de origem (que sera desativado)
                             ,pr_idpessoa_destino IN NUMBER -- Identificador unico da pessoa de destino (pessoa que sera migrado as informacoes)
                             ,pr_dscritic        OUT VARCHAR2);    -- Retorno de Erro



  -- Rotina para cadastro de pessoa fisica
  PROCEDURE pc_cadast_pessoa_fisica(pr_idpessoa               IN OUT NUMBER -- Identificador unico da pessoa
                                   ,pr_nrcpfcgc               IN NUMBER -- Numero do documento CPF ou CNPJ
                                   ,pr_nmpessoa               IN VARCHAR2 -- Nome da Pessoa
                                   ,pr_nmpessoa_receita       IN VARCHAR2 -- Nome da Pessoa na Receita Federal
                                   ,pr_tppessoa               IN NUMBER -- Tipo de Pessoa (1-Fisica/ 2-Juridica)
                                   ,pr_dtconsulta_spc         IN DATE -- Data da ultima consulta no SPC
                                   ,pr_dtconsulta_rfb         IN DATE -- Data da ultima consulta do CPF ou CNPJ na Receita Federal
                                   ,pr_cdsituacao_rfb         IN NUMBER -- Situacao do CPF ou CNPJ na Receita Federal
                                   ,pr_tpconsulta_rfb         IN NUMBER -- Consulta na Receita Federal (1-Automatica/ 2-Manual)
                                   ,pr_dtconsulta_scr         IN DATE -- Data da ultima consulta no SCR
                                   ,pr_tpcadastro             IN NUMBER -- Tipo de cadastro (0-Nao definido/ 1-Prospect/ 2-Basico/ 3-Intermediario/ 4-Completo)
                                   ,pr_cdoperad_altera        IN VARCHAR2 -- Codigo do operador que realizou a ultima alteracao
                                   ,pr_idcorrigido            IN NUMBER -- idpessoa assumido para esta pessoa no momento da identificacao de duplicidade no cadastro
                                   ,pr_dtalteracao            IN DATE -- Data da ultima alteracao no cadastro
                                   ,pr_nmsocial               IN VARCHAR2 -- Nome social
                                   ,pr_tpsexo                 IN NUMBER -- Sexo (1-Masculino/ 2-Feminino)
                                   ,pr_cdestado_civil         IN NUMBER -- Codigo do Estado Civil (FK gnetcvl)
                                   ,pr_dtnascimento           IN DATE -- Data de Nascimento
                                   ,pr_cdnaturalidade         IN NUMBER -- Codigo da cidade de naturalidade (FK crapmun)
                                   ,pr_cdnacionalidade        IN NUMBER -- Codigo da Nacionalidade (FK crapnac)
                                   ,pr_tpnacionalidade        IN NUMBER -- Tipo de nacionalidade (FK gntpnac)
                                   ,pr_tpdocumento            IN VARCHAR2 -- Tipo de documento (CI-Carteira de Identidade/ CN-Certidao de Nascimento/ CNH-Carteira Nacional de Habilitacao/ RNE-Registro Nacional de Estrangeiro/ PPT-Passaporte)
                                   ,pr_nrdocumento            IN VARCHAR2 -- Numero do documento
                                   ,pr_dtemissao_documento    IN DATE -- Data de emissao do documento conforme TPDOCUMENTO
                                   ,pr_idorgao_expedidor      IN NUMBER -- Identificador unico de orgao expedidor (FK tbgen_orgao_expedidor)
                                   ,pr_cduf_orgao_expedidor   IN VARCHAR2 -- Unidade de Federacao do Orgao Expedidor do documento conforme TPDOCUMENTO (FK tbcadast_uf)
                                   ,pr_inhabilitacao_menor    IN NUMBER -- Indicador de habilitacao/emancipacao do menor (0-menor/ 1-habilitado)
                                   ,pr_dthabilitacao_menor    IN DATE -- Data da emancipacao do menor
                                   ,pr_cdgrau_escolaridade    IN NUMBER -- Grau de instrucao (FK gngresc)
                                   ,pr_cdcurso_superior       IN NUMBER -- Codigo do curso superior (FK gncdfrm)
                                   ,pr_cdnatureza_ocupacao    IN NUMBER -- Codigo da Natureza de Ocupacao (FK gncdnto)
                                   ,pr_dsprofissao            IN VARCHAR2 -- Descricao da profissao (Cargo)
                                   ,pr_vlrenda_presumida      IN VARCHAR2 -- Valor da renda que foi retornada pelo bureau de consulta
                                   ,pr_dsjustific_outros_rend IN VARCHAR2 -- Justificativa de outros rendimentos
                                   ,pr_cdpais                 IN NUMBER -- Codigo do PAIS (FK CRAPNAT.CDNACION)
                                   ,pr_nridentificacao        IN VARCHAR2 -- Numero identificacao fiscal -- Projeto 414 - Marcelo Telles Coelho - Mouts
                                   ,pr_dsnatureza_relacao     IN VARCHAR2 -- Natureza da relacao
                                   ,pr_dsestado               IN VARCHAR2 -- Descricao do estado
                                   ,pr_nrpassaporte           IN NUMBER -- Numero do passaporte
                                   ,pr_tpdeclarado            IN VARCHAR2 -- Identificador do tipo de declaracao
                                   ,pr_incrs                  IN NUMBER -- Indica se a pessoa e cadastrado na CHS  (0-Nao/ 1-Sim). CHS = Lei de Conformidade Tributaria de Contas no Exterior para europeus
                                   ,pr_infatca                IN NUMBER -- Indica se a pessoa e cadastrado na FACTCA  (0-Nao/ 1-Sim). FATCA = Lei de Conformidade Tributária de Contas no Exterior para Americanos
                                   ,pr_dsnaturalidade         IN VARCHAR2 -- Cidade de origem do estrangeiro
                                   ,pr_dscritic               OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para cadastro de pessoa juridica
  PROCEDURE pc_cadast_pessoa_juridica(pr_idpessoa                   IN OUT NUMBER -- Identificador unico da pessoa
                                     ,pr_nrcpfcgc                   IN NUMBER -- Numero do documento CPF ou CNPJ
                                     ,pr_nmpessoa                   IN VARCHAR2 -- Nome da Pessoa
                                     ,pr_nmpessoa_receita           IN VARCHAR2 -- Nome da Pessoa na Receita Federal
                                     ,pr_tppessoa                   IN NUMBER -- Tipo de Pessoa (1-Fisica/ 2-Juridica)
                                     ,pr_dtconsulta_spc             IN DATE -- Data da ultima consulta no SPC
                                     ,pr_dtconsulta_rfb             IN DATE -- Data da ultima consulta do CPF ou CNPJ na Receita Federal
                                     ,pr_cdsituacao_rfb             IN NUMBER -- Situacao do CPF ou CNPJ na Receita Federal
                                     ,pr_tpconsulta_rfb             IN NUMBER -- Consulta na Receita Federal (1-Automatica/ 2-Manual)
                                     ,pr_dtconsulta_scr             IN DATE -- Data da ultima consulta no SCR
                                     ,pr_tpcadastro                 IN NUMBER -- Tipo de cadastro (0-Nao definido/ 1-Prospect/ 2-Basico/ 3-Intermediario/ 4-Completo)
                                     ,pr_cdoperad_altera            IN VARCHAR2 -- Codigo do operador que realizou a ultima alteracao
                                     ,pr_idcorrigido                IN NUMBER -- idpessoa assumido para esta pessoa no momento da identificacao de duplicidade no cadastro
                                     ,pr_dtalteracao                IN DATE -- Data da ultima alteracao no cadastro
                                     ,pr_cdcnae                     IN NUMBER -- Codigo CNAE (FK tbgen_cnae)
                                     ,pr_nmfantasia                 IN VARCHAR2 -- Nome Fantasia
                                     ,pr_nrinscricao_estadual       IN NUMBER -- Inscricao Estatual
                                     ,pr_cdnatureza_juridica        IN NUMBER -- Natureza Juridica (FK gncdntj)
                                     ,pr_dtconstituicao             IN DATE -- Data de constituicao da empresa
                                     ,pr_dtinicio_atividade         IN DATE -- Data de inicio das atividades
                                     ,pr_qtfilial                   IN NUMBER -- Quantidade de Filiais
                                     ,pr_qtfuncionario              IN NUMBER -- Quantidade de Funcionarios
                                     ,pr_vlcapital                  IN NUMBER -- Valor do Capital Social
                                     ,pr_dtregistro                 IN DATE -- Data do Registro
                                     ,pr_nrregistro                 IN NUMBER -- Numero do Registro
                                     ,pr_dsorgao_registro           IN VARCHAR2 -- Descricao do orgao de emissao do CNPJ
                                     ,pr_dtinscricao_municipal      IN DATE -- Data da Inscricao Municipal
                                     ,pr_nrnire                     IN NUMBER -- Numero de Identificacao no Registro de Empresas
                                     ,pr_inrefis                    IN NUMBER -- Indica se a empresa e optante pelo REFIS (0-Nao/ 1-Sim)
                                     ,pr_dssite                     IN VARCHAR2 -- URL Site
                                     ,pr_nrinscricao_municipal      IN NUMBER -- Numero da Inscricao Municipal
                                     ,pr_cdsetor_economico          IN NUMBER -- Setor Economico conforme definido em (craptab.cdacesso = "SETORECONO")
                                     ,pr_vlfaturamento_anual        IN NUMBER -- Valor do Faturamento Anual da Empresa
                                     ,pr_cdramo_atividade           IN NUMBER -- Ramo de Atividade (FK gnrativ)
                                     ,pr_nrlicenca_ambiental        IN NUMBER -- Numero da Licenca Ambiental
                                     ,pr_dtvalidade_licenca_amb     IN DATE -- Data de Validade da Licenca Ambiental
                                     ,pr_peunico_cliente            IN NUMBER -- Percentual de faturamento em um unico cliente (maior cliente)
                                     ,pr_tpregime_tributacao        IN NUMBER   -- Forma de tributacao da empresa (1-Simples Nacional, 2-Simples Nacional MEI, 3-Lucro Real, 4-Lucro Presumido)
                                     ,pr_incrs                      IN NUMBER   -- Indica se a pessoa e cadastrado na crs  (0-nao/ 1-sim). crs = lei de conformidade tributaria de contas no exterior para europeus
                                     ,pr_infatca                    IN NUMBER   -- Indica se a pessoa e cadastrado na fatca  (0-nao/ 1-sim). fatca = lei de conformidade tributaria de contas no exterior para americanos
                                     ,pr_cdpais                     IN NUMBER   -- Codigo do pais (fk crapnat.cdnacion)
                                     ,pr_nridentificacao            IN VARCHAR2 -- Numero identificacao fiscal -- Projeto 414 - Marcelo Telles Coelho - Mouts
                                     ,pr_dsnatureza_relacao         IN VARCHAR2 -- Natureza da relacao
                                     ,pr_dsestado                   IN VARCHAR2 -- Descricao do estado
                                     ,pr_nrpassaporte               IN VARCHAR2 -- Numero do passaporte
                                     ,pr_tpdeclarado                IN VARCHAR2 -- Identificador do tipo de declaracao
                                     ,pr_dsnaturalidade             IN VARCHAR2 -- Cidade de origem do estrangeiro
                                     ,pr_vlreceita_bruta            IN NUMBER   -- Valor do faturamento mensal bruto
                                     ,pr_vlcusto_despesa_adm        IN NUMBER   -- Valor dos custos e despesas administrativas dos 12 meses
                                     ,pr_vldespesa_administrativa   IN NUMBER   -- Valor das despesas financeiras
                                     ,pr_qtdias_recebimento         IN NUMBER   -- Prazo medio em dias para o recebimento
                                     ,pr_qtdias_pagamento           IN NUMBER   -- Prazo medio em dias para o pagamento
                                     ,pr_vlativo_caixa_banco_apl    IN NUMBER   -- Valor do caixa, bancos e aplicacoes financeiras
                                     ,pr_vlativo_contas_receber     IN NUMBER   -- Valor do contas a receber.
                                     ,pr_vlativo_estoque            IN NUMBER   -- Valor dos estoques
                                     ,pr_vlativo_imobilizado        IN NUMBER   -- Valor do imobilizado
                                     ,pr_vlativo_outros             IN NUMBER   -- Valor de outros ativos
                                     ,pr_vlpassivo_fornecedor       IN NUMBER   -- Valor dos fornecedores
                                     ,pr_vlpassivo_divida_bancaria  IN NUMBER   -- Valor do endividamento bancario total
                                     ,pr_vlpassivo_outros           IN NUMBER   -- Valor de outros ativos
                                     ,pr_dtmes_base                 IN DATE     -- Data base das informacoes financeiras
                                     ,pr_dscritic                  OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para retorno de ID pessoa passando como parametro o CPF / CNPJ
  PROCEDURE pc_retorna_IdPessoa(pr_nrcpfcgc IN  NUMBER -- Numero do CPF / CNPJ
                               ,pr_idpessoa OUT NUMBER -- Registro de pessoa
													   	 ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para retorno de pessoa
  PROCEDURE pc_retorna_pessoa(pr_idpessoa IN NUMBER -- -- Identificador unico da pessoa
														 ,pr_retorno  OUT xmltype -- XML de retorno
														 ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para retorno das contas da pessoa
  PROCEDURE pc_retorna_pessoa_conta(pr_cdcooper IN NUMBER  -- Codigo da cooperativa
                                   ,pr_idpessoa IN NUMBER  -- Identificador unico da pessoa
														       ,pr_retorno  OUT xmltype -- XML de retorno
														       ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para retorno com todos os dados da conta
  PROCEDURE pc_retorna_dados_conta(pr_cdcooper IN NUMBER  -- Codigo da cooperativa
                                  ,pr_nrdconta IN NUMBER  -- Numero da conta
														      ,pr_retorno  OUT xmltype -- XML de retorno
														      ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro

 -- Rotina para retorno de identificacao pessoa
  PROCEDURE pc_retorna_identificacao(pr_idpessoa IN NUMBER -- Registro de pessoa
                                    ,pr_cdcooper IN NUMBER -- Cooperativa
                                    ,pr_dscanal  IN VARCHAR2 -- Cooperativa
                                    ,pr_retorno  OUT xmltype -- XML de retorno
                                    ,pr_dscritic OUT VARCHAR2);

  -- Rotina para retorno dos dados da matricula do cooperado
  PROCEDURE pc_retorna_matricula(pr_cdcooper IN NUMBER  -- Codigo da cooperativa
                                ,pr_idpessoa IN NUMBER  -- Identificador unico da pessoa
														    ,pr_retorno  OUT xmltype -- XML de retorno
													      ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro


  -- Rotina para cadastro de telefones
  PROCEDURE pc_cadast_pessoa_telefone(pr_idpessoa               IN NUMBER -- Identificador unico da pessoa (FK tbcadast_pessoa)
                                     ,pr_nrseq_telefone         IN OUT NUMBER -- Numero sequencial do telefone
                                     ,pr_cdoperadora            IN NUMBER -- Codigo da operadora de telefone
                                     ,pr_tptelefone             IN NUMBER -- Tipo de telefone (1-Residencial/ 2-Celular/ 3-Comercial/ 4-Contato)
                                     ,pr_nmpessoa_contato       IN VARCHAR2 -- Pessoa de contato no telefone
                                     ,pr_nmsetor_pessoa_contato IN VARCHAR2 -- Secao da pessoa de contato
                                     ,pr_nrddd                  IN NUMBER -- Numero do DDD
                                     ,pr_nrtelefone             IN NUMBER -- Numero do telefone
                                     ,pr_nrramal                IN NUMBER -- Numero do ramal
                                     ,pr_insituacao             IN NUMBER -- Indicador de situacao do telefone (1-Ativo/ 2-Inativo)
                                     ,pr_tporigem_cadastro      IN NUMBER -- Tipo de origem do cadastro (1-Cooperado/ 2-Cooperativa/ 3-Terceiros)
                                     ,pr_cdoperad_altera        IN VARCHAR2 -- Codigo do operador que realizou a ultima alteracao
                                     ,pr_dscritic               OUT VARCHAR2); -- Retorno de Erro

	-- Rotina para excluir telefone
  PROCEDURE pc_exclui_pessoa_telefone(pr_idpessoa        IN NUMBER   -- Identificador de pessoa
                                     ,pr_nrseq_telefone  IN NUMBER   -- Nr. de sequência de telefone
                                     ,pr_cdoperad_altera IN VARCHAR2 -- Operador que esta efetuando a exclusao
																		 ,pr_cdcritic        OUT INTEGER                                     -- Codigo de erro
																		 ,pr_dscritic        OUT VARCHAR2);                                  -- Retorno de Erro

  -- Rotina para retorno de telefones
  PROCEDURE pc_retorna_pessoa_telefone(pr_idpessoa IN NUMBER -- Registro de bens
                                      ,pr_retorno  OUT xmltype -- XML de retorno
                                      ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro
                                      
  PROCEDURE pc_confirma_pessoa_telefone(pr_cdcooper       IN NUMBER -- Numero da cooperativa
                                       ,pr_idpessoa       IN NUMBER -- Registro de telefone
                                       ,pr_nrseq_telefone IN NUMBER -- Numero sequecial do telefone
                                       ,pr_flsituacao     IN NUMBER -- Situacao: 1 - Ativo/ 2 - Rejeitado
                                       ,pr_idcanal        IN NUMBER -- Canal que efetuou a atualização
                                       ,pr_dscritic      OUT VARCHAR2);                                   
  -- Rotina para cadastrar email
  PROCEDURE pc_cadast_pessoa_email(pr_dsemail                IN VARCHAR2 -- Descricao do email
                                  ,pr_nmpessoa_contato       IN VARCHAR2 -- Pessoa de contato no e-mail
                                  ,pr_nmsetor_pessoa_contato IN VARCHAR2 -- Secao da pessoa de contato
                                  ,pr_cdoperad_altera        IN VARCHAR2 -- Codigo do operador que realizou a ultima alteracao
                                  ,pr_idpessoa               IN NUMBER -- Identificador unico da pessoa (FK tbcadast_pessoa)
                                  ,pr_nrseq_email            IN OUT NUMBER -- Numero sequencial do email
                                  ,pr_dscritic               OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para excluir email
  PROCEDURE pc_exclui_pessoa_email(pr_idpessoa        IN NUMBER   -- Identificador de pessoa
                                  ,pr_nrseq_email     IN NUMBER   -- Numero sequencial do email
                                  ,pr_cdoperad_altera IN VARCHAR2 -- Operador que esta efetuando a exclusao
                                  ,pr_cdcritic       OUT INTEGER                                -- Codigo de erro
                                  ,pr_dscritic       OUT VARCHAR2);                             -- Retorno de Erro

  -- Rotina para retorno de email
  PROCEDURE pc_retorna_pessoa_email(pr_idpessoa IN NUMBER -- Registro de bens
                                   ,pr_retorno  OUT xmltype -- XML de retorno
                                   ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro
 -- Rotina para confirmar email                                   
  PROCEDURE pc_confirma_pessoa_email(pr_cdcooper       IN NUMBER -- Numero da cooperativa
                                    ,pr_idpessoa       IN NUMBER -- Registro de email
                                    ,pr_nrseq_email    IN NUMBER -- Numero sequecial do email
                                    ,pr_flsituacao     IN NUMBER -- Situacao: 1 - Ativo/ 2 - Rejeitado
                                    ,pr_idcanal        IN NUMBER -- Canal que efetuou a atualização
                                    ,pr_dscritic      OUT VARCHAR2);                           
                                   
  -- Rotina para cadastrar endereço
  PROCEDURE pc_cadast_pessoa_endereco(pr_idpessoa            IN NUMBER -- Identificador unico da pessoa (FK tbcadast_pessoa)
                                     ,pr_nrseq_endereco      IN OUT NUMBER -- Numero sequencial do endereco
                                     ,pr_tpendereco          IN NUMBER -- Tipo do endereco (9-Comercial/ 10-Residencial/ 12-Internet/ 13-Correspondencia/ 14-Complementar)
                                     ,pr_nmlogradouro        IN VARCHAR2 -- Nome do logradouro
                                     ,pr_nrlogradouro        IN NUMBER -- Numero do logradouro
                                     ,pr_dscomplemento       IN VARCHAR2 -- Complemento do logradouro
                                     ,pr_nmbairro            IN VARCHAR2 -- Nome do bairro
                                     ,pr_idcidade            IN NUMBER -- Identificador unido do registro de cidade (FK crapmun)
                                     ,pr_nrcep               IN NUMBER -- Numero do CEP
                                     ,pr_tpimovel            IN NUMBER -- Tipo de imovel (1-Quitado/ 2-Financiado/ 3-Alugado/ 4-Familiar/ 5-Cedido)
                                     ,pr_vldeclarado         IN NUMBER -- Valor declarado (aluguel ou valor do imovel)
                                     ,pr_dtalteracao         IN DATE -- Data de alteracao do endereco
                                     ,pr_dtinicio_residencia IN DATE -- Data de inicio de residencia
                                     ,pr_tporigem_cadastro   IN NUMBER -- Indicador de origem da informacao (1-Cooperado/ 2-Cooperativa/ 3-Terceiros)
                                     ,pr_cdoperad_altera     IN VARCHAR2 -- Codigo do operador que realizou a ultima alteracao
                                     ,pr_dscritic            OUT VARCHAR2); -- Descrição da crítica

  -- Rotina para excluir endereço
  PROCEDURE pc_exclui_pessoa_endereco(pr_idpessoa        IN NUMBER   -- Identificador de pessoa
                                     ,pr_nrseq_endereco  IN NUMBER   -- Nr. de sequência de endereço
                                     ,pr_cdoperad_altera IN VARCHAR2 -- Operador que esta efetuando a exclusao
                                     ,pr_cdcritic        OUT INTEGER                                     -- Codigo de erro
                                     ,pr_dscritic            OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para confirmação do endereço                                     
  PROCEDURE pc_confirma_pessoa_endereco(pr_cdcooper       IN NUMBER -- Numero da cooperativa
                                       ,pr_idpessoa       IN NUMBER -- Registro de endereço
                                       ,pr_nrseq_endereco IN NUMBER -- Numero sequecial do endereço
                                       ,pr_flsituacao     IN NUMBER -- Situacao: 1 - Ativo/ 2 - Rejeitado
                                       ,pr_idcanal        IN NUMBER -- Canal que efetuou a atualização
                                       ,pr_dscritic      OUT VARCHAR2);

  -- Rotina para retorno de endereço
  PROCEDURE pc_retorna_pessoa_endereco(pr_idpessoa IN NUMBER -- Registro de bens
                                      ,pr_retorno  OUT xmltype -- XML de retorno
                                      ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para cadastro de renda complementar da pessoa fisica
  PROCEDURE pc_cadast_pessoa_rend_compl(pr_idpessoa        IN NUMBER -- Identificador unico da pessoa (FK tbcadast_pessoa_fisica)
                                       ,pr_nrseq_renda     IN OUT NUMBER -- Numero sequencial do rendimento
                                       ,pr_tprenda         IN NUMBER -- Tipo de rendimento
                                       ,pr_vlrenda         IN NUMBER -- Valor do rendimento
                                       ,pr_tpfixo_variavel IN NUMBER -- Indicador de forma de renda (1-Fixo/ 2-Variavel)
                                       ,pr_cdoperad_altera IN VARCHAR2 -- Codigo do operador que realizou a ultima alteracao
                                       ,pr_dscritic        OUT VARCHAR2); -- Retorno de Erro

	-- Rotina para excluir renda complementar da pessoa fisica
  PROCEDURE pc_exclui_pessoa_renda_compl(pr_idpessoa        IN NUMBER   -- Identificador de pessoa
		                                    ,pr_nrseq_renda     IN NUMBER   -- Nr. de sequência de renda complementar
                                        ,pr_cdoperad_altera IN VARCHAR2 -- Operador que esta efetuando a exclusao
                                        ,pr_cdcritic        OUT INTEGER                                    -- Codigo de erro
                                        ,pr_dscritic        OUT VARCHAR2);                                 -- Retorno de Erro

  -- Rotina para retorno de rendimento
  PROCEDURE pc_retorna_pessoa_rend_compl(pr_idpessoa IN NUMBER -- Registro de bens
                                        ,pr_retorno  OUT xmltype -- XML de retorno
                                        ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro
  -- Rotina para cadastrar renda
  PROCEDURE pc_cadast_pessoa_renda(pr_idpessoa             IN NUMBER -- Identificador unico da pessoa (FK tbcadast_pessoa_fisica)
                                  ,pr_nrseq_renda          IN OUT NUMBER -- Numero sequencial unico da renda para o cooperado
                                  ,pr_tpcontrato_trabalho  IN NUMBER -- Tipo de contrato de trabalho (1-Permanente/ 2-Temporario/ 3-Sem vinculo/ 4-Autonomo)
                                  ,pr_cdturno              IN NUMBER -- Codigo do Turno conforme (craptab.cdacesso = DSCDTURNOS)
                                  ,pr_cdnivel_cargo        IN NUMBER -- Codigo do nivel do cargo na empresa (FK gncdncg)
                                  ,pr_dtadmissao           IN DATE -- Data de admissao na empresa
                                  ,pr_cdocupacao           IN NUMBER -- Codigo de ocupacao (FK gncdocp)
                                  ,pr_nrcadastro           IN NUMBER -- Numero do cadastro na empresa
                                  ,pr_vlrenda              IN NUMBER -- Valor do rendimento
                                  ,pr_tpfixo_variavel      IN NUMBER -- Tipo de rendimento (0-Fixo/ 1-Variavel)
                                  ,pr_tpcomprov_renda      IN NUMBER -- Tipo de comprovacao do rendimento (0-Folha de Pagamento/ 1-Decore/ 2-IR/ 3-Extrato INSS/ 4-Termo de Conviccao de Renda)
                                  ,pr_idpessoa_fonte_renda IN NUMBER -- Identificador da pessoa fonte da renda
                                  ,pr_cdoperad_altera      IN VARCHAR2 -- Codigo do operador que realizou a ultima alteracao
                                  ,pr_dscritic             OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para excluir renda da pessoa fisica
  PROCEDURE pc_exclui_pessoa_renda(pr_idpessoa        IN NUMBER   -- Identificador de pessoa
		                              ,pr_nrseq_renda     IN NUMBER   -- Nr. de sequência de renda
                                  ,pr_cdoperad_altera IN VARCHAR2 -- Operador que esta efetuando a exclusao
                                  ,pr_cdcritic        OUT INTEGER                               -- Codigo de erro
                                  ,pr_dscritic        OUT VARCHAR2);                            -- Retorno de Erro

  -- Rotina para retorno de renda
  PROCEDURE pc_retorna_pessoa_renda(pr_idpessoa IN NUMBER -- Registro de bens
                                   ,pr_retorno  OUT xmltype -- XML de retorno
                                   ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para confirmar renda
  PROCEDURE pc_confirma_pessoa_renda(pr_cdcooper       IN NUMBER -- Numero da cooperativa
                                    ,pr_idpessoa       IN NUMBER -- Registro de renda
                                    ,pr_nrseq_renda    IN NUMBER -- Numero sequecial do renda
                                    ,pr_flsituacao     IN NUMBER -- Situacao: 1 - Ativo/ 2 - Rejeitado
                                    ,pr_idcanal        IN NUMBER -- Canal que efetuou a atualização
                                    ,pr_dscritic      OUT VARCHAR2);
                                    
  -- Rotina para cadastrar relacionamento
  PROCEDURE pc_cadast_pessoa_relacao(pr_idpessoa         IN NUMBER      -- Identificador unico da pessoa (FK tbcadast_pessoa_fisica)
                                    ,pr_nrseq_relacao    IN OUT NUMBER  -- Numero sequencial do dependente
                                    ,pr_idpessoa_relacao IN NUMBER      -- Numero do CPF do dependente
                                    ,pr_tprelacao        IN NUMBER      -- Tipo de relacionamento (1-Conjuge/ / 3-Pai / 4-Mae)
                                    ,pr_cdoperad_altera  IN VARCHAR2
                                    ,pr_dscritic         OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para confirmar empresa
  PROCEDURE pc_confirma_pessoa_empresa(pr_cdcooper       IN NUMBER -- Numero da cooperativa
                                      ,pr_idpessoa       IN NUMBER -- Registro de empresa
                                      ,pr_nrseq_empresa IN NUMBER -- Numero sequecial do empresa
                                      ,pr_flsituacao     IN NUMBER -- Situacao: 1 - Ativo/ 2 - Rejeitado
                                      ,pr_idcanal        IN NUMBER -- Canal que efetuou a atualização
                                      ,pr_dscritic      OUT VARCHAR2);

  -- Rotina para excluir relacionamento
  PROCEDURE pc_exclui_pessoa_relacao(pr_idpessoa        IN NUMBER         -- Identificador de pessoa
															      ,pr_nrseq_relacao   IN NUMBER         -- Nr. de sequência de relacionamento
																		,pr_cdoperad_altera IN VARCHAR2       -- Operador que esta efetuando a exclusao
																		,pr_cdcritic        OUT INTEGER                                   -- Codigo de erro
																		,pr_dscritic        OUT VARCHAR2);                                -- Retorno de Erro

  -- Rotina para retorno de relacionamento
  PROCEDURE pc_retorna_pessoa_relacao(pr_idpessoa IN NUMBER -- Registro de bens
                                     ,pr_retorno  OUT xmltype -- XML de retorno
                                     ,pr_dscritic OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para retorno de CEP
  PROCEDURE pc_retorna_cep(pr_cdcep     IN NUMBER -- Registro de cep
                          ,pr_nmrua     IN VARCHAR2 -- Nome da rua
                          ,pr_nmbairro  IN VARCHAR2 -- Nome do bairro
                          ,pr_nmcidade  IN VARCHAR2 -- Nome da cidade
                          ,pr_retorno  OUT xmltype -- XML de retorno
                          ,pr_dscritic OUT VARCHAR2-- Retorno de Erro
                          ,pr_linha_inicio_busca in number default  1
                          ,pr_qtd_registros in number default  10
                          ); 

  -- Rotina para verificar se existe restricoes
  PROCEDURE pc_retorna_restricoes(pr_nrcpfcgc     IN NUMBER -- Numero do CPF / CNPJ da pessoa
                                 ,pr_dsrestricao OUT VARCHAR2 -- Descricao da restricao, caso houver
                                 ,pr_tprestricao OUT NUMBER   -- Tipo de restrição
                                                              --   0=Sem restrições
                                                              --   1=Com restrições - Interrompe o cadastro
                                                              --   2=Com restrições - Não interrompe o cadstro, gera alerta área segurança
                                 ,pr_dscritic    OUT VARCHAR2);

  -- Rotina para cadastrar pessoa dependente
  PROCEDURE pc_cadast_pessoa_fisica_dep( pr_idpessoa	            IN NUMBER    --> Identificador unico da pessoa
                                        ,pr_nrseq_dependente  IN OUT NUMBER    --> Numero sequencial de dependente
                                        ,pr_idpessoa_dependente   IN NUMBER    --> Identificador unico da pessoa dependente
                                        ,pr_tpdependente          IN NUMBER    --> Tipo de pessoa dependente(dominio: craptab cdacesso = dstpdepend )
                                        ,pr_cdoperad_altera       IN VARCHAR2  --> Codigo do operador que realizou a ultima alteracao
                                        ,pr_dscritic             OUT VARCHAR2);

  -- Rotina para excluir pessoa dependente
  PROCEDURE pc_exclui_pessoa_fisica_dep( pr_idpessoa         IN NUMBER          -- Identificador de pessoa
                                        ,pr_nrseq_dependente IN NUMBER          -- Nr. de sequência
                                        ,pr_cdoperad_altera  IN VARCHAR2        -- Operador que esta efetuando a exclusao
                                        ,pr_cdcritic         OUT INTEGER        -- Codigo de erro
                                        ,pr_dscritic         OUT VARCHAR2);     -- Retorno de Erro

  -- Rotina para retornar dados de pessoa dependente
  PROCEDURE pc_retorna_pessoa_fisica_dep( pr_idpessoa IN NUMBER    -- Registro de bens
                                         ,pr_retorno  OUT xmltype  -- XML de retorno
                                         ,pr_dscritic OUT VARCHAR2);

  -- Rotina para Cadastrar de resposansavel legal de pessoa de fisica
  PROCEDURE pc_cadast_pessoa_fisica_resp( pr_idpessoa	            IN NUMBER        --> Identificador unico da pessoa
                                         ,pr_nrseq_resp_legal IN OUT NUMBER        --> Numero sequencial de responsavel legal
                                         ,pr_idpessoa_resp_legal  IN NUMBER        --> Identificador unico da pessoa responsavel legal
                                         ,pr_cdrelacionamento     IN NUMBER        --> Codigo de relacao do responsavel legal com o cooperado
                                         ,pr_cdoperad_altera      IN VARCHAR2      --> Codigo do operador que realizou a ultima alteracao
                                         ,pr_dscritic             OUT VARCHAR2);

  -- Rotina para excluir pessoa responsavel legal
  PROCEDURE pc_exclui_pessoa_fisica_resp ( pr_idpessoa         IN NUMBER    -- Identificador de pessoa
                                          ,pr_nrseq_resp_legal IN NUMBER    -- Nr. de sequência
                                          ,pr_cdoperad_altera  IN VARCHAR2  -- Operador que esta efetuando a exclusao
                                          ,pr_cdcritic         OUT INTEGER                                          -- Codigo de erro
                                          ,pr_dscritic         OUT VARCHAR2);

  -- Rotina para retorna resposansavel legal de pessoa de fisica
  PROCEDURE pc_retorna_pessoa_fisica_resp( pr_idpessoa IN NUMBER -- Registro de bens
                                          ,pr_retorno  OUT xmltype -- XML de retorno
                                          ,pr_dscritic             OUT VARCHAR2);

  -- Rotina para Cadastrar de pessoa de referencia
  PROCEDURE pc_cadast_pessoa_referencia( pr_idpessoa	            IN NUMBER    --> Identificador unico da pessoa
                                         ,pr_nrseq_referencia IN OUT NUMBER    --> Numero sequencial de referencia
                                         ,pr_idpessoa_referencia  IN NUMBER    --> Identificador unico da pessoa de referencia
                                         ,pr_cdoperad_altera      IN VARCHAR2  --> Codigo do operador que realizou a ultima alteracao
                                         ,pr_dscritic             OUT VARCHAR2);

  -- Rotina para excluir pessoa referencia
  PROCEDURE pc_exclui_pessoa_referencia (pr_idpessoa         IN NUMBER    -- Identificador de pessoa
                                        ,pr_nrseq_referencia IN NUMBER    -- Nr. de sequência
                                        ,pr_cdoperad_altera  IN VARCHAR2  -- Operador que esta efetuando a exclusao
                                        ,pr_cdcritic         OUT INTEGER                                          -- Codigo de erro
                                        ,pr_dscritic         OUT VARCHAR2);

  -- Rotina para retornar de pessoa de referencia
  PROCEDURE pc_retorna_pessoa_referencia ( pr_idpessoa IN NUMBER   -- Registro de bens
                                          ,pr_retorno  OUT xmltype -- XML de retorno
                                          ,pr_dscritic             OUT VARCHAR2);

  -- Rotina para Cadastrar dados financeiros de pessoa juridica em outrao bancos.
  PROCEDURE pc_cadast_pessoa_juridica_bco ( pr_idpessoa	        IN NUMBER       --> identificador unico da pessoa
                                           ,pr_nrseq_banco  IN OUT NUMBER       --> numero sequencial de movimentação em outros bancos
                                           ,pr_cdbanco          IN NUMBER       --> codigo do banco
                                           ,pr_dsoperacao       IN VARCHAR2     --> descrição operacao realizada com outro banco
                                           ,pr_vloperacao       IN NUMBER       --> valor da operacao financeira
                                           ,pr_dsgarantia       IN VARCHAR2     --> garantia dada para a realizacao da operacao financeira
                                           ,pr_dtvencimento     IN DATE         --> data vencimento da operacao financeira, caso vazio refere-se a varios vencimentos
                                           ,pr_cdoperad_altera  IN VARCHAR2     --> codigo do operador que realizou a ultima alteracao
                                           ,pr_dscritic        OUT VARCHAR2);

  -- Rotina para excluir dados financeiros de pessoa juridica em outrao bancos.
  PROCEDURE pc_exclui_pessoa_juridica_bco(pr_idpessoa         IN NUMBER     -- Identificador de pessoa
                                         ,pr_nrseq_banco      IN NUMBER     -- Nr. de sequência
                                         ,pr_cdoperad_altera  IN VARCHAR2   -- Operador que esta efetuando a exclusao
                                         ,pr_cdcritic         OUT INTEGER                                          -- Codigo de erro
                                         ,pr_dscritic         OUT VARCHAR2);

  -- Rotina para retornar dados financeiros de pessoa juridica em outrao bancos.
  PROCEDURE pc_retorna_pessoa_juridica_bco ( pr_idpessoa  IN NUMBER   -- Registro de bens
                                            ,pr_retorno  OUT xmltype  -- XML de retorno
                                            ,pr_dscritic OUT VARCHAR2);

  -- Rotina para Cadastrar faturamento mensal de Pessoas Juridica
  PROCEDURE pc_cadast_pessoa_juridica_fat ( pr_idpessoa	             IN NUMBER     --> Identificador unico da pessoa
                                           ,pr_nrseq_faturamento IN OUT NUMBER     --> Numero sequencial do faturamento
                                           ,pr_dtmes_referencia      IN DATE       --> Mes em que ocorreu o faturamento
                                           ,pr_vlfaturamento_bruto   IN NUMBER     --> Valor do faturamento mensal bruto
                                           ,pr_cdoperad_altera       IN VARCHAR2   --> Codigo do operador que realizou a ultima alteracao
                                           ,pr_dscritic             OUT VARCHAR2);

  -- Rotina para excluir faturamento mensal de Pessoas Juridica
  PROCEDURE pc_exclui_pessoa_juridica_fat(pr_idpessoa          IN NUMBER   -- Identificador de pessoa
                                         ,pr_nrseq_faturamento IN NUMBER   -- Nr. de sequência
                                         ,pr_cdoperad_altera   IN VARCHAR2 -- Operador que esta efetuando a exclusao
                                         ,pr_cdcritic          OUT INTEGER                                          -- Codigo de erro
                                         ,pr_dscritic          OUT VARCHAR2);

  -- Rotina para retornar faturamento mensal de Pessoas Juridica
  PROCEDURE pc_retorna_pessoa_juridica_fat ( pr_idpessoa IN NUMBER   -- Registro de bens
                                            ,pr_retorno  OUT xmltype -- XML de retorno
                                            ,pr_dscritic OUT VARCHAR2);

  -- Rotina para Cadastrar participacao societaria em outras empresas
  PROCEDURE pc_cadast_pessoa_juridica_ptp ( pr_idpessoa	              IN NUMBER            --> Identificador unico da pessoa
                                           ,pr_nrseq_participacao IN OUT NUMBER            --> Numero sequencial de participacao
                                           ,pr_idpessoa_participacao  IN NUMBER            --> Identificador unico da pessoa onde a pessoa tem participação
                                           ,pr_persocio               IN NUMBER            --> Percentual societario
                                           ,pr_dtadmissao             IN DATE              --> Data de admissao como socio
                                           ,pr_cdoperad_altera        IN VARCHAR2          --> Codigo do operador que realizou a ultima alteracao
                                           ,pr_dscritic              OUT VARCHAR2);

  -- Rotina para excluir participacao societaria em outras empresas
  PROCEDURE pc_exclui_pessoa_juridica_ptp(pr_idpessoa           IN NUMBER   -- Identificador de pessoa
                                         ,pr_nrseq_participacao IN NUMBER   -- Nr. de sequência
                                         ,pr_cdoperad_altera    IN VARCHAR2 -- Operador que esta efetuando a exclusao
                                         ,pr_cdcritic          OUT INTEGER                                          -- Codigo de erro
                                         ,pr_dscritic          OUT VARCHAR2);

  -- Rotina para Retornar participacao societaria em outras empresas
  PROCEDURE pc_retorna_pessoa_juridica_ptp ( pr_idpessoa IN NUMBER   -- Registro de bens
                                            ,pr_retorno  OUT xmltype -- XML de retorno
                                            ,pr_dscritic OUT VARCHAR2);


  -- Rotina para Cadastrar representantes da pessoa juridica.
  PROCEDURE pc_cadast_pessoa_juridica_rep (  pr_idpessoa	               IN NUMBER      --> identificador unico da pessoa
                                           ,pr_nrseq_representante   IN OUT NUMBER      --> numero sequencial de representante
                                           ,pr_idpessoa_representante    IN NUMBER      --> indicador unico de pessoa representante da pessoa juridica
                                           ,pr_tpcargo_representante     IN NUMBER      --> tipo de cargo
                                           ,pr_dtvigencia                IN DATE        --> data de vigencia
                                           ,pr_dtadmissao                IN DATE        --> data de admissao como socio
                                           ,pr_persocio                  IN NUMBER      --> percentual societario
                                           ,pr_flgdependencia_economica  IN NUMBER      --> indicador de dependencia economica
                                           ,pr_cdoperad_altera           IN VARCHAR2    -->
                                           ,pr_dscritic                 OUT VARCHAR2);

  -- Rotina para excluir representantes da pessoa juridica.
  PROCEDURE pc_exclui_pessoa_juridica_rep(pr_idpessoa            IN NUMBER   -- Identificador de pessoa
                                         ,pr_nrseq_representante IN NUMBER   -- Nr. de sequência
                                         ,pr_cdoperad_altera     IN VARCHAR2 -- Operador que esta efetuando a exclusao
                                         ,pr_cdcritic           OUT INTEGER                                          -- Codigo de erro
                                         ,pr_dscritic           OUT VARCHAR2);

  -- Rotina para Retornar representantes da pessoa juridica.
  PROCEDURE pc_retorna_pessoa_juridica_rep ( pr_idpessoa IN NUMBER     -- Registro de bens
                                            ,pr_retorno  OUT xmltype   -- XML de retorno
                                            ,pr_dscritic OUT VARCHAR2);


  -- Rotina para Cadastrar pessoas politicamente expostas.
  PROCEDURE pc_cadast_pessoa_polexp ( pr_idpessoa	                 IN NUMBER	     --> Identificador unico do cadastro de pessoa
                                     ,pr_tpexposto                 IN NUMBER       --> Identificacao do tipo de exposicao (tbcadas_dominio_campo) 1-exerce ou exerceu cargo politico/2-possui relacionamento
                                     ,pr_dtinicio                  IN DATE         --> Data de inicio da exposicao politica
                                     ,pr_dttermino                 IN DATE         --> Data de termino da exposicao politica
                                     ,pr_idpessoa_empresa          IN NUMBER       --> Identificador da empresa do politicamente exposto
                                     ,pr_cdocupacao                IN NUMBER       --> Codigo de ocupacao do politico exposto (fk gncdocp)
                                     ,pr_tprelacao_polexp          IN NUMBER       --> tipo de relacionamento (definicao em tbcadast_dominio_campo)
                                     ,pr_idpessoa_politico         IN NUMBER       --> Identificador do politicamente exposto de relacao
                                     ,pr_cdoperad_altera           IN VARCHAR2     -->
                                     ,pr_dscritic                 OUT VARCHAR2);

  -- Rotina para excluir pessoas politicamente expostas.
  PROCEDURE pc_exclui_pessoa_polexp ( pr_idpessoa            IN NUMBER          -- Identificador de pessoa
                                     ,pr_cdoperad_altera     IN VARCHAR2        -- Operador que esta efetuando a exclusao
                                     ,pr_cdcritic           OUT INTEGER         -- Codigo de erro
                                     ,pr_dscritic           OUT VARCHAR2);      -- Retorno de Erro

  -- Rotina para Retornar pessoas politicamente expostas.
  PROCEDURE pc_retorna_pessoa_polexp ( pr_idpessoa IN NUMBER   -- Registro de bens
                                      ,pr_retorno  OUT xmltype -- XML de retorno
                                      ,pr_dscritic             OUT VARCHAR2);
  -- Rotina para validar senha da conta do cooperado
  PROCEDURE pc_valida_senha_cooperado(pr_cdcooper IN NUMBER,     -- Código da cooperativa
                                      pr_nrdconta IN VARCHAR2,   -- Número da conta
                                      pr_dstoken  OUT VARCHAR2,  -- Token de retorno nos casos sucesso na validação
                                      pr_dscritic OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para verificar forma de pagamento de cotas na modalidade Desligamento
  PROCEDURE pc_retorna_forma_ago (pr_cdcooper IN NUMBER,      -- Código da cooperativa
                                  pr_formaago OUT NUMBER,     -- Forma de pagamento cotas desligamento
                                  pr_dscritic OUT VARCHAR2);  -- Retorno de Erro

  -- Rotina para atualizar situação da conta para "em processo de demissão"
  PROCEDURE pc_atualiza_situacao_conta (pr_cdcooper IN NUMBER,     -- Código da cooperativa
                                        pr_nrdconta IN NUMBER,     -- Número da conta
                                        pr_cdmotdem IN NUMBER,   -- Código Motivo Demissão
                                        pr_dscritic OUT VARCHAR2); -- Retorno de Erro

  -- Rotina para verificar valor de cotas liberadas para saque
  PROCEDURE pc_retorna_cotas_liberada (pr_cdcooper IN NUMBER,   -- Código da cooperativa
                                       pr_nrdconta IN NUMBER,   -- Número da conta
                                       pr_vldcotas OUT NUMBER,  -- Forma de pagamento cotas desligamento
                                       pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_cadast_aprov_saque_cotas( pr_cdcooper	     IN NUMBER	--> Codigo da cooperativa
                                        ,pr_nrdconta       IN NUMBER  --> Numero da conta
                                        ,pr_cdmotivo       IN NUMBER  --> Codigo do motivo de saque parcial ou desligamento
                                        ,pr_tpsaque        IN NUMBER  --> Identificador do tipo de saque (1-PARCIAL / 2-DESLIGAMENTO)
                                        ,pr_iddevolucao    IN NUMBER  --> Identificador de devolucao de cotas por desligamento (1-ANTECIPADO / 2-APOS AGO)
                                        ,pr_vlsaque        IN NUMBER  --> Valor do saque
                                        ,pr_tpiniciativa   IN NUMBER  --> Identificador da iniciativa de saque de cotas (1-COOPERATIVA / 2-COOPERADO)
                                        ,pr_dtaprovwork    IN DATE    --> Data de aprovacao final workflow CRM
                                        ,pr_dtdesligamento IN DATE    --> Data de desligamento do cooperado
                                        ,pr_dtsolicitacao  IN DATE    --> Data de solicitação de saque de cotas
                                        ,pr_dtcredito      IN DATE    --> Data de crédito das cotas
                                        ,pr_cdoperadaprov  IN VARCHAR2 --> Código do Operador aprovador final workflow CRM
                                        ,pr_dscritic      OUT VARCHAR2);

  -- Rotina para efetuar a atualizacao de regras (Ex. Revisao Cadastral)
  PROCEDURE pc_atualiza_processo_regra(pr_idpessoa   IN NUMBER,  -- Registro de bens
                                       pr_idprocesso IN VARCHAR2,  -- Processo que sera utilizado (1-Revisao Cadastral)
                                       pr_dtprocesso IN DATE,    -- Data de processo da regra
                                       pr_dscritic OUT VARCHAR2);  -- Retorno de Erro

  -- Rotina para efetuar a revisao cadastral
  PROCEDURE pc_efetiva_revisao(pr_idpessoa       IN NUMBER,  -- Registro de bens
                               pr_dtatualizacao  IN DATE, -- Data de atualizacao da regra
                               pr_cdoperad       IN VARCHAR2, -- Codigo do operador
                               pr_tpcanal_atualizacao IN NUMBER, -- Canal que foi feito a atualizacao (1-Ayllos/2-Caixa/3-Internet/4-Cash/5-Ayllos WEB/6-URA/7-Batch/8-Mensageria/9-Mobile/10-CRM)
                               pr_dscritic OUT VARCHAR2);  -- Retorno de Erro

  -- Rotina para retorno dos Bancos participantes da Portabilidade de Salário  
	PROCEDURE pc_retorna_instituicao_finan(pr_cdbccxlt 	IN crapban.cdbccxlt%TYPE  
                                        ,pr_idportab 	IN NUMBER 
                                        ,pr_dsretxml  OUT xmltype -- XML de retorno CLOB
                                        ,pr_dscritic  OUT VARCHAR2) ;

  -- Rotina para retorno das listagem dos empregadores do cooperado
  PROCEDURE pc_retorna_empregador_coop(pr_cdcooper 	IN NUMBER
                                      ,pr_nrdconta 	IN NUMBER  
                                      ,pr_idseqttl 	IN NUMBER
                                      ,pr_nrcpfcgc 	IN NUMBER
                                      ,pr_dsretxml  OUT xmltype
                                      ,pr_dscritic  OUT VARCHAR2);

  -- Rotina para retorno dos relacionamentos da pessoa
  PROCEDURE pc_retorna_relacionamentos( pr_idpessoa  IN NUMBER   -- Identificador da pessoa
                                       ,pr_tprelacao IN VARCHAR2 -- Filtro para o tipo de relacao
                                       ,pr_retorno  OUT xmltype -- XML de retorno
                                       ,pr_dscritic             OUT VARCHAR2);

  -- Retorna o parametro cadastrado na CADPAR                                        
  PROCEDURE pc_busca_parametro_tarifas(pr_cdcooper IN NUMBER
                                      ,pr_cdpartar IN NUMBER
                                      ,pr_vlparamt OUT VARCHAR2
                                      ,pr_dscritic OUT VARCHAR2);
                                                     
  -- Retorna via XML o parametro cadastrado na CADPAR                                               
  PROCEDURE pc_busca_parametro_tarifas_web(pr_cdcooper IN NUMBER
                                          ,pr_cdpartar IN NUMBER
                                          ,pr_retorno   IN OUT NOCOPY xmltype 
                                          ,pr_dscritic OUT VARCHAR2); 
                                          
  -- Busca a situação, canal e data de revisão das tabelas de TBCADAST
  PROCEDURE pc_busca_tbcadast(pr_nrcpfcgc IN NUMBER
                             ,pr_idseqttl IN NUMBER
                             ,pr_nmtabela IN VARCHAR2
                             -- OUT
                             ,pr_insituac OUT NUMBER
                             ,pr_dssituac OUT VARCHAR2
                             ,pr_idcanal  OUT NUMBER
                             ,pr_dscanal  OUT VARCHAR2
                             ,pr_dtrevisa OUT DATE
                             ,pr_dscritic OUT VARCHAR2);
END cada0012;
/
CREATE OR REPLACE PACKAGE BODY CECRED.cada0012 IS
  -- Variáveis para armazenar as informações em XML
  vr_des_xml         clob;
  vr_texto_completo  varchar2(32600);

  FUNCTION fn_busca_contas_atualizar RETURN CLOB IS
    BEGIN
      RETURN 'SELECT alt.cdcooper
                    ,alt.nrdconta
                    ,ttl.idseqttl
                    ,null dsvariaveis
                FROM crapass ass
          INNER JOIN crapalt alt ON ass.cdcooper = alt.cdcooper AND ass.nrdconta = alt.nrdconta
          INNER JOIN crapttl ttl ON ass.cdcooper = ttl.cdcooper AND ass.nrdconta = ttl.nrdconta
         WHERE ASS.TPVINCUL IN (''FC'',''FU'',''FO'')
				 AND CDSITDCT = 1 
                 AND alt.dtaltera = (SELECT MAX(dtaltera) FROM crapalt WHERE  nrdconta = ass.nrdconta AND cdcooper = ass.cdcooper AND tpaltera = 1)';
  END fn_busca_contas_atualizar; 

  -- Rotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_xml(pr_des_dados in varchar2
                         ,pr_fecha_xml in boolean default false
                          ) is
  BEGIN
   gene0002.pc_escreve_xml( vr_des_xml
                          , vr_texto_completo
                          , pr_des_dados
                          , pr_fecha_xml );
  END pc_escreve_xml;

  -- Rotina generica para retornar os dados da tabela via xml
  PROCEDURE pc_retorna_dados_xml (pr_idpessoa IN NUMBER    --> Id de pessoa
                                 ,pr_nmtabela IN VARCHAR2  --> Nome da tabela
                                 ,pr_dsnoprin IN VARCHAR2  --> Nó principal do xml
                                 ,pr_dsnofilh IN VARCHAR2  --> Nós filhos
                                 ,pr_clausula IN VARCHAR2 default NULL      --> Clausula Where
                                 ,pr_retorno  OUT xmltype  --> XML de retorno
                                 ,pr_dscritic OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_retorna_dados_xml
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina generica para retornar os dados da tabela via xml
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    --> Buscar colunas da tabela
    CURSOR cr_coluna IS
      SELECT col.COLUMN_NAME,
             col.COLUMN_ID,
             col.DATA_TYPE
        FROM All_Tab_Columns col
       WHERE col.OWNER = 'CECRED'
         AND col.TABLE_NAME = upper(pr_nmtabela)
       ORDER BY col.COLUMN_ID;

    TYPE typ_tab_campos IS TABLE OF cr_coluna%ROWTYPE
         INDEX BY pls_integer;
    vr_tab_campos typ_tab_campos;

    -- Variaveis gerais
    vr_xml xmltype; -- XML qye sera enviado

    -- Variáveis para criação de cursor dinâmico
    vr_nrcursor      NUMBER;
    vr_nrretorn      NUMBER;
    vr_qtdretor      NUMBER := 0;
    vr_dscursor      VARCHAR2(32000);
    vr_dsdcampo      VARCHAR2(4000);
    vr_nmcidade      VARCHAR(300);
    vr_cdestado      VARCHAR(300);
    vr_canal         VARCHAR(300);
    vr_nmempres      VARCHAR(300);
    vr_vlminimo      NUMBER(25,2);
    vr_vlmaximo      NUMBER(25,2);
    vr_dsfaixar      VARCHAR2(4000);
    vr_separador     VARCHAR2(2);
    vr_vlrenda       NUMBER(25,2);


  BEGIN

    --> Montar Query
    vr_dscursor := 'SELECT ';

    --> Listar colunas da tabela
    FOR rw_coluna IN cr_coluna LOOP

      vr_tab_campos(vr_tab_campos.count) := rw_coluna;

      IF rw_coluna.column_id <> 1 THEN
        vr_dscursor := vr_dscursor ||',';
      END IF;

      --> Formatar caso for tipo data
      IF rw_coluna.data_type = 'DATE' THEN
        vr_dscursor := vr_dscursor || 'to_char('|| rw_coluna.column_name||',''DD/MM/RRRR HH24:MI:SS'')';
      --> Formatar caso for tipo numero e começar com VL-valor ou PE-percentual
      ELSIF rw_coluna.data_type = 'NUMBER' AND
         (rw_coluna.column_name LIKE 'VL%' OR
          rw_coluna.column_name LIKE 'PE%' )THEN
        vr_dscursor := vr_dscursor || 'to_char('|| rw_coluna.column_name||',''fm9999999999999999999990D00'',''NLS_NUMERIC_CHARACTERS='''',.'''''')';
      ELSE
        vr_dscursor := vr_dscursor || rw_coluna.column_name;
      END IF;
    END LOOP;

    vr_dscursor := vr_dscursor|| ' FROM ' || pr_nmtabela;
    vr_dscursor := vr_dscursor|| ' WHERE idpessoa = ' ||pr_idpessoa;
    IF pr_clausula IS NOT NULL THEN
      vr_dscursor := vr_dscursor|| ' AND ' || pr_clausula;
    END IF;    

    -- Cria cursor dinâmico
    vr_nrcursor := dbms_sql.open_cursor;
    -- Comando Parse
    dbms_sql.parse(vr_nrcursor, vr_dscursor, 1);

    --> Listar colunas da tabela
    FOR i IN vr_tab_campos.first..vr_tab_campos.last LOOP
      -- Definindo Colunas de retorno
      dbms_sql.define_column(vr_nrcursor, vr_tab_campos(i).column_id, vr_dsdcampo,4000);
    END LOOP;


    -- Execução do select dinamico
    vr_nrretorn := dbms_sql.execute(vr_nrcursor);
    vr_qtdretor  := 0;

    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><'||pr_dsnoprin||'/>');

    LOOP
      -- Verifica se há alguma linha de retorno do cursor
      vr_nrretorn := dbms_sql.fetch_rows(vr_nrcursor);
      if vr_nrretorn = 0 THEN
        -- Se o cursor dinamico está aberto
        IF dbms_sql.is_open(vr_nrcursor) THEN
          -- Fecha o mesmo
          dbms_sql.close_cursor(vr_nrcursor);
        END IF;
        EXIT;
      ELSE
        -- Insere o nó principal
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => pr_dsnoprin
                              ,pr_posicao  => 0
                              ,pr_tag_nova => pr_dsnofilh
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => pr_dscritic);

        --> Listar colunas da tabela
        FOR i IN vr_tab_campos.first..vr_tab_campos.last LOOP

          -- Carrega variáveis com o retorno do cursor
          dbms_sql.column_value(vr_nrcursor, vr_tab_campos(i).column_id, vr_dsdcampo);

          -- Insere os detalhes
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => pr_dsnofilh
                                ,pr_posicao  => vr_qtdretor
                                ,pr_tag_nova => vr_tab_campos(i).column_name
                                ,pr_tag_cont => vr_dsdcampo
                                ,pr_des_erro => pr_dscritic);

          -- Tratativa para buscar o nome da cidade caso seja TBCADAST_PESSOA_ENDERECO
          IF (UPPER(vr_tab_campos(i).column_name) = 'IDCIDADE' AND UPPER(pr_nmtabela) = 'TBCADAST_PESSOA_ENDERECO') THEN
            vr_nmcidade := '';
            IF (vr_dsdcampo IS NOT NULL) THEN
              SELECT dscidade, cdestado INTO vr_nmcidade, vr_cdestado FROM crapmun WHERE idcidade = vr_dsdcampo;
            END IF;

            -- Insere os detalhes
            gene0007.pc_insere_tag(pr_xml      => vr_xml
                                  ,pr_tag_pai  => pr_dsnofilh
                                  ,pr_posicao  => vr_qtdretor
                                  ,pr_tag_nova => 'NMCIDADE'
                                  ,pr_tag_cont => vr_nmcidade
                                  ,pr_des_erro => pr_dscritic);

            -- Insere os detalhes
            gene0007.pc_insere_tag(pr_xml      => vr_xml
                                  ,pr_tag_pai  => pr_dsnofilh
                                  ,pr_posicao  => vr_qtdretor
                                  ,pr_tag_nova => 'DSESTADO'
                                  ,pr_tag_cont => vr_cdestado
                                  ,pr_des_erro => pr_dscritic);
          END IF;

          -- Tratativa para retornar a situação por escrito quando TELEFONE e EMAIL
          IF ((UPPER(vr_tab_campos(i).column_name) = 'INSITUACAO')
             AND UPPER(pr_nmtabela) IN('TBCADAST_PESSOA_TELEFONE', 'TBCADAST_PESSOA_EMAIL')) THEN
            -- Insere os detalhes
            gene0007.pc_insere_tag(pr_xml      => vr_xml
                                  ,pr_tag_pai  => pr_dsnofilh
                                  ,pr_posicao  => vr_qtdretor
                                  ,pr_tag_nova => 'FLSITUACAO'
                                  ,pr_tag_cont => CASE WHEN NVL(vr_dsdcampo, 1) = 1 THEN 'Ativo' ELSE 'Inativo' END
                                  ,pr_des_erro => pr_dscritic);
          END IF;

          -- Tratativa para retornar o Canal
          IF ((UPPER(vr_tab_campos(i).column_name)) IN ('IDCANAL', 'IDCANAL_EMPRESA', 'IDCANAL_RENDA')
             AND UPPER(pr_nmtabela) IN('TBCADAST_PESSOA_TELEFONE'
                                      ,'TBCADAST_PESSOA_EMAIL'
                                      ,'TBCADAST_PESSOA_RENDA'
                                      ,'TBCADAST_PESSOA_ENDERECO'
                                      )) THEN
            vr_canal := '';
            IF (vr_dsdcampo IS NOT NULL) THEN
              -- Busca o codigo no dominio e retorna a descricao
              SELECT DSCODIGO INTO vr_canal FROM TBCADAST_DOMINIO_CAMPO WHERE NMDOMINIO = 'TBCADAST_CANAL' AND CDDOMINIO = vr_dsdcampo;
            END IF;

            -- Insere os detalhes
            gene0007.pc_insere_tag(pr_xml      => vr_xml
                                  ,pr_tag_pai  => pr_dsnofilh
                                  ,pr_posicao  => vr_qtdretor
                                  ,pr_tag_nova => 'CANAL_ALTERACAO' || SUBSTR(UPPER(vr_tab_campos(i).column_name),8)
                                  ,pr_tag_cont => vr_canal
                                  ,pr_des_erro => pr_dscritic);
          END IF;

          -- Tratativa para buscar o nome da empresa caso seja TBCADAST_PESSOA_RENDA
          IF (UPPER(vr_tab_campos(i).column_name) = 'IDPESSOA_FONTE_RENDA' AND UPPER(pr_nmtabela) = 'TBCADAST_PESSOA_RENDA') THEN
            vr_nmempres := '';
            IF (vr_dsdcampo IS NOT NULL) THEN
              SELECT nmpessoa INTO vr_nmempres FROM tbcadast_pessoa WHERE idpessoa = vr_dsdcampo;
            END IF;

            -- Insere os detalhes
            gene0007.pc_insere_tag(pr_xml      => vr_xml
                                  ,pr_tag_pai  => pr_dsnofilh
                                  ,pr_posicao  => vr_qtdretor
                                  ,pr_tag_nova => 'NMEMPRES'
                                  ,pr_tag_cont => vr_nmempres
                                  ,pr_des_erro => pr_dscritic);
          END IF;
          
          -- Tratativa para calcular faixa de renda
          IF (UPPER(vr_tab_campos(i).column_name) = 'VLRENDA' AND UPPER(pr_nmtabela) = 'TBCADAST_PESSOA_RENDA') THEN
          
            SELECT VALUE INTO vr_separador FROM nls_session_parameters WHERE parameter = 'NLS_NUMERIC_CHARACTERS';
            vr_vlrenda := to_number(REPLACE(REPLACE(vr_dsdcampo,'.',''),',',SUBSTR(vr_separador, 1, 1)));
            
            vr_vlminimo := vr_vlrenda - (vr_vlrenda*0.2);
            vr_vlmaximo := vr_vlrenda + (vr_vlrenda*0.2);
            vr_dsfaixar := 'R$' || to_char(vr_vlminimo,'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.''') ||
                           ' à R$' || to_char(vr_vlmaximo,'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.''');
            -- Insere os detalhes
            gene0007.pc_insere_tag(pr_xml      => vr_xml
                                  ,pr_tag_pai  => pr_dsnofilh
                                  ,pr_posicao  => vr_qtdretor
                                  ,pr_tag_nova => 'DSFAIXA_RENDA'
                                  ,pr_tag_cont => vr_dsfaixar
                                  ,pr_des_erro => pr_dscritic);
          END IF;
        END LOOP;

        vr_qtdretor := vr_qtdretor + 1;

      END IF;
    END LOOP;


    pr_retorno := vr_xml;
  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_dados_xml: ' ||
                     SQLERRM;
  END pc_retorna_dados_xml;

  PROCEDURE pc_insere_crapalt(pr_idpessoa IN NUMBER
                             ,pr_cdcooper IN NUMBER
                             ,pr_dtmvtolt IN DATE
                             ,pr_dsaltera IN VARCHAR2
                             ,pr_dscritic OUT VARCHAR2) IS
/* ..........................................................................
  --
  --  Programa : pc_insere_crapalt
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CADA
  --  Autor    : Vitor S. Assanuma (GFT)
  --  Data     : Março/2019.                   Ultima atualizacao:
  --
  --  Dados referentes ao programa:
  --
  --   Frequencia: Sempre que for chamado
  --   Objetivo  : Rotina para atualizar a crapalt
  --
  --  Alteração :
  --
  --
  -- ..........................................................................*/
  -- Variaveis de erro
  vr_dscritic VARCHAR(500);
  vr_exc_erro EXCEPTION;
  
  vr_dsaltera VARCHAR2(30000);

  CURSOR cr_craptps IS
      SELECT
         ass.nrdconta
        ,ass.nrmatric
      FROM
        TBCADAST_PESSOA tps
      INNER JOIN
        crapass ass ON  ass.nrcpfcgc = tps.nrcpfcgc
      WHERE tps.idpessoa = pr_idpessoa
        AND ass.cdcooper = pr_cdcooper;
    rw_craptps cr_craptps%ROWTYPE;
    
    CURSOR cr_crapalt (pr_nrdconta NUMBER) IS
      SELECT dsaltera 
        FROM crapalt 
       WHERE cdcooper = pr_cdcooper 
         AND nrdconta = pr_nrdconta 
         AND dtaltera = pr_dtmvtolt;
    rw_crapalt cr_crapalt%ROWTYPE;
         
  BEGIN
    -- Busca o numero da conta e a matricula
    FOR rw_craptps IN cr_craptps LOOP
    OPEN cr_crapalt(pr_nrdconta => rw_craptps.nrdconta);
      FETCH cr_crapalt INTO rw_crapalt;    
        
    IF (cr_crapalt%NOTFOUND) THEN
      -- Atualiza a Crapalt
      BEGIN
        INSERT INTO crapalt (
           crapalt.nrdconta
          ,crapalt.dtaltera
          ,crapalt.tpaltera
          ,crapalt.dsaltera
          ,crapalt.cdcooper
          ,crapalt.flgctitg
          ,crapalt.cdoperad)
        VALUES(
          rw_craptps.nrdconta,
          pr_dtmvtolt,
          1,
          pr_dsaltera,
          pr_cdcooper,
          1,
          rw_craptps.nrmatric
        );
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na crapalt: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    ELSE
      BEGIN
        UPDATE crapalt 
             SET dsaltera = rw_crapalt.dsaltera || ' ' || pr_dsaltera
         WHERE cdcooper = pr_cdcooper 
           AND nrdconta = rw_craptps.nrdconta 
           AND dtaltera = pr_dtmvtolt;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crapalt: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;
    CLOSE cr_crapalt;
    END LOOP;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_insere_crapalt: ' || SQLERRM;
  END pc_insere_crapalt;

  -- Rotina para cadastro de bens
  PROCEDURE pc_cadast_pessoa_bem(pr_idpessoa        IN NUMBER
                                ,pr_nrseq_bem       IN OUT NUMBER
                                ,pr_dsbem           IN VARCHAR2
                                ,pr_pebem           IN NUMBER
                                ,pr_qtparcela_bem   IN NUMBER
                                ,pr_vlbem           IN NUMBER
                                ,pr_vlparcela_bem   IN NUMBER
                                ,pr_dtalteracao     IN DATE
                                ,pr_cdoperad_altera IN VARCHAR2
                                ,pr_dscritic        OUT VARCHAR2) IS
    -- Retorno de Erro

    vr_pessoa_bem tbcadast_pessoa_bem%ROWTYPE;
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
  BEGIN
    -- Popula o tipo registro
    vr_pessoa_bem.idpessoa := pr_idpessoa;
    vr_pessoa_bem.nrseq_bem := pr_nrseq_bem;
    vr_pessoa_bem.dsbem := pr_dsbem;
    vr_pessoa_bem.pebem := pr_pebem;
    vr_pessoa_bem.qtparcela_bem := pr_qtparcela_bem;
    vr_pessoa_bem.vlbem := pr_vlbem;
    vr_pessoa_bem.vlparcela_bem := pr_vlparcela_bem;
    vr_pessoa_bem.dtalteracao := pr_dtalteracao;
    vr_pessoa_bem.cdoperad_altera := pr_cdoperad_altera;

    -- Chama rotina passando um registro
    cada0010.pc_cadast_pessoa_bem(pr_pessoa_bem => vr_pessoa_bem
                                 ,pr_cdcritic   => vr_cdcritic
                                 ,pr_dscritic   => pr_dscritic);

    -- Retorna a sequencia do bem
    pr_nrseq_bem := vr_pessoa_bem.nrseq_bem;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_bem: ' ||
                     SQLERRM;
  END;

  -- Rotina para excluir bem
  PROCEDURE pc_exclui_pessoa_bem(pr_idpessoa        IN NUMBER   -- Identificador de pessoa
															  ,pr_nrseq_bem       IN NUMBER   -- Nr. de sequência de bem
															  ,pr_cdoperad_altera IN VARCHAR2 -- Operador que esta efetuando a exclusao
															  ,pr_cdcritic        OUT INTEGER                             -- Codigo de erro
															  ,pr_dscritic        OUT VARCHAR2) IS                        -- Retorno de Erro
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

    -- Chamar rotina para exclusão
    cada0010.pc_exclui_pessoa_bem(pr_idpessoa => pr_idpessoa
		                             ,pr_nrseq_bem => pr_nrseq_bem
																 ,pr_cdoperad_altera => pr_cdoperad_altera
																 ,pr_cdcritic => pr_cdcritic
																 ,pr_dscritic => pr_dscritic);

		-- Se retornou alguma crítica
		IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_bem: ' ||SQLERRM;
	END;

  -- Rotina para retorno de bens
  PROCEDURE pc_retorna_pessoa_bem(pr_idpessoa IN NUMBER -- Registro de bens
                                 ,pr_retorno  OUT xmltype -- XML de retorno
                                 ,pr_dscritic OUT VARCHAR2) IS
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;

  BEGIN
    -- Rotina generica para retornar os dados da tabela via xml
    pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa                    --> Id de pessoa
                         ,pr_nmtabela => 'TBCADAST_PESSOA_BEM'          --> Nome da tabela
                         ,pr_dsnoprin => 'bens'                         --> Nó principal do xml
                         ,pr_dsnofilh => 'bem'                          --> Nós filhos
                         ,pr_retorno  => pr_retorno                     --> XML de retorno
                         ,pr_dscritic => pr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_bem: ' ||
                     SQLERRM;
  END;

  -- Verifica se o operador possui acesso ao sistema
  PROCEDURE pc_valida_acesso_operador(pr_cdcooper IN NUMBER, -- Codigo da cooperativa
                                      pr_cdoperad IN VARCHAR2, -- Codigo do operador
                                      pr_cdagenci IN NUMBER, -- Codigo da agencia
                                      pr_fltoken  IN VARCHAR2 DEFAULT 'S', -- Flag se deve ser alterado o token
                                      pr_tpcanal_sistema  IN NUMBER DEFAULT 10, -- Sistema que esta solicitando acesso 10-CRM, 13 - Ibracred
                                      pr_dstoken  OUT VARCHAR2, -- Token de retorno nos casos de sucesso na validacao
                                      pr_dscritic OUT VARCHAR2) IS  -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_valida_acesso_operador
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Lucas Reinert
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para validar o acesso do operador na Cooperativa e do PA
		--               a partir do sistema de CRM
    --
    --  Alteração : 16/05/2019 - 508.1 - Atualização cadastral - Cassia - GFT
	--              27/05/2019 - PJ438 - Alterações devido chamada via Ibratan - Paulo Martins
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

		-- Verificar se PA utilza o CRM
    CURSOR cr_crapage IS
		  SELECT inutlcrm flgutcrm -- age.flgutcrm
			  FROM crapage age
			 WHERE age.cdcooper = pr_cdcooper
			   AND age.cdagenci = pr_cdagenci;
		rw_crapage cr_crapage%ROWTYPE;

		-- Verifcar acesso do operador ao CRM
		CURSOR cr_crapope IS
		  SELECT ope.inutlcrm flgutcrm,
             ope.cddsenha
			  FROM crapope ope
			 WHERE ope.cdcooper = pr_cdcooper
			   AND UPPER(ope.cdoperad) = UPPER(pr_cdoperad);
		rw_crapope cr_crapope%ROWTYPE;
    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_cdcritic PLS_INTEGER;
		vr_dscritic VARCHAR2(4000);

  BEGIN
    if pr_tpcanal_sistema = 13 then /*Ibratan Tela Unica PRJ438*/
      tela_analise_credito.pc_gera_token_ibratan(pr_cdcooper => pr_cdcooper, 
                                                 pr_cdagenci => pr_cdagenci,
                                                 pr_cdoperad => pr_cdoperad,
                                                 pr_dstoken =>  pr_dstoken,
                                                 pr_cdcritic => vr_cdcritic,
                                                 pr_dscritic => vr_dscritic);
      if vr_dscritic is not null then
        RAISE vr_exc_erro;
      end if;
                                                 
    else     
			-- Buscar registro do operador
			OPEN cr_crapope;
			FETCH cr_crapope INTO rw_crapope;

			-- Se não encontrou registro de operador
			IF cr_crapope%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_crapope;
				-- Gerar crítica
				vr_cdcritic := 67;
				vr_dscritic := '';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			-- Fechar cursor
			CLOSE cr_crapope;

			-- Se operador não possui acesso ao CRM
      IF rw_crapope.flgutcrm = 0 and pr_tpcanal_sistema = 10 THEN
				-- Gerar crítica
				vr_dscritic := 'Operador não está habilitado para acessar o sistema CRM.';
				-- Levantar exceção
				RAISE vr_exc_erro;
      ELSE
        IF pr_fltoken = 'S' THEN
          -- Gera o codigo do token
          pr_dstoken := substr(dbms_random.random,1,10);
          
          -- Atualiza a tabela de senha do operador
          BEGIN
            UPDATE crapope
               SET cddsenha = pr_dstoken
             WHERE upper(cdoperad) = upper(pr_cdoperad);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar CRAPOPE: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
        ELSE
          -- Retorna o token de acesso
          pr_dstoken := rw_crapope.cddsenha;
        END IF;
			END IF;
  
        -- Buscar registro do PA
        OPEN cr_crapage;
        FETCH cr_crapage INTO rw_crapage;

        -- Se não encontrou PA
        IF cr_crapage%NOTFOUND THEN
          -- Fechar cursor
          CLOSE cr_crapage;
          -- Gerar crítica
          vr_cdcritic := 962;
          vr_dscritic := '';
          -- Levantar exceção
          RAISE vr_exc_erro;
		END IF;
        -- Fechar cursor
        CLOSE cr_crapage;

        -- Se PA não possui acesso ao CRM
       IF (rw_crapage.flgutcrm = 0 AND rw_crapope.flgutcrm=3) THEN
          -- Gerar crítica
          vr_dscritic := 'PA não está habilitado para acessar o sistema CRM.';
          -- Levantar exceção
          RAISE vr_exc_erro;
       END IF; 

    end if;
  EXCEPTION
		WHEN vr_exc_erro THEN
			-- Se possui código da crítica
			IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
				-- Buscar descrição da crítica
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			END IF;
			-- Retornar crítica parametrizada
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_valida_acesso_operador: ' ||
                     SQLERRM;
  END;

  -- ROtina para mesclar duas pessoas em uma unica pessoa
  PROCEDURE pc_mesclar_pessoa(pr_idpessoa_origem  IN NUMBER -- Identificador unico da pessoa de origem (que sera desativado)
                             ,pr_idpessoa_destino IN NUMBER -- Identificador unico da pessoa de destino (pessoa que sera migrado as informacoes)
                             ,pr_dscritic        OUT VARCHAR2)IS  -- Retorno de Erro
  BEGIN
    NULL;
  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_mesclar_pessoa: ' ||
                     SQLERRM;
  END;


  PROCEDURE pc_cadast_pessoa_fisica(pr_idpessoa               IN OUT NUMBER -- Identificador unico da pessoa
                                   ,pr_nrcpfcgc               IN NUMBER -- Numero do documento CPF ou CNPJ
                                   ,pr_nmpessoa               IN VARCHAR2 -- Nome da Pessoa
                                   ,pr_nmpessoa_receita       IN VARCHAR2 -- Nome da Pessoa na Receita Federal
                                   ,pr_tppessoa               IN NUMBER -- Tipo de Pessoa (1-Fisica/ 2-Juridica)
                                   ,pr_dtconsulta_spc         IN DATE -- Data da ultima consulta no SPC
                                   ,pr_dtconsulta_rfb         IN DATE -- Data da ultima consulta do CPF ou CNPJ na Receita Federal
                                   ,pr_cdsituacao_rfb         IN NUMBER -- Situacao do CPF ou CNPJ na Receita Federal
                                   ,pr_tpconsulta_rfb         IN NUMBER -- Consulta na Receita Federal (1-Automatica/ 2-Manual)
                                   ,pr_dtconsulta_scr         IN DATE -- Data da ultima consulta no SCR
                                   ,pr_tpcadastro             IN NUMBER -- Tipo de cadastro (0-Nao definido/ 1-Prospect/ 2-Basico/ 3-Intermediario/ 4-Completo)
                                   ,pr_cdoperad_altera        IN VARCHAR2 -- Codigo do operador que realizou a ultima alteracao
                                   ,pr_idcorrigido            IN NUMBER -- idpessoa assumido para esta pessoa no momento da identificacao de duplicidade no cadastro
                                   ,pr_dtalteracao            IN DATE -- Data da ultima alteracao no cadastro
                                   ,pr_nmsocial               IN VARCHAR2 -- Nome social
                                   ,pr_tpsexo                 IN NUMBER -- Sexo (1-Masculino/ 2-Feminino)
                                   ,pr_cdestado_civil         IN NUMBER -- Codigo do Estado Civil (FK gnetcvl)
                                   ,pr_dtnascimento           IN DATE -- Data de Nascimento
                                   ,pr_cdnaturalidade         IN NUMBER -- Codigo da cidade de naturalidade (FK crapmun)
                                   ,pr_cdnacionalidade        IN NUMBER -- Codigo da Nacionalidade (FK crapnac)
                                   ,pr_tpnacionalidade        IN NUMBER -- Tipo de nacionalidade (FK gntpnac)
                                   ,pr_tpdocumento            IN VARCHAR2 -- Tipo de documento (CI-Carteira de Identidade/ CN-Certidao de Nascimento/ CNH-Carteira Nacional de Habilitacao/ RNE-Registro Nacional de Estrangeiro/ PPT-Passaporte)
                                   ,pr_nrdocumento            IN VARCHAR2 -- Numero do documento
                                   ,pr_dtemissao_documento    IN DATE -- Data de emissao do documento conforme TPDOCUMENTO
                                   ,pr_idorgao_expedidor      IN NUMBER -- Identificador unico de orgao expedidor (FK tbgen_orgao_expedidor)
                                   ,pr_cduf_orgao_expedidor   IN VARCHAR2 -- Unidade de Federacao do Orgao Expedidor do documento conforme TPDOCUMENTO (FK tbcadast_uf)
                                   ,pr_inhabilitacao_menor    IN NUMBER -- Indicador de habilitacao/emancipacao do menor (0-menor/ 1-habilitado)
                                   ,pr_dthabilitacao_menor    IN DATE -- Data da emancipacao do menor
                                   ,pr_cdgrau_escolaridade    IN NUMBER -- Grau de instrucao (FK gngresc)
                                   ,pr_cdcurso_superior       IN NUMBER -- Codigo do curso superior (FK gncdfrm)
                                   ,pr_cdnatureza_ocupacao    IN NUMBER -- Codigo da Natureza de Ocupacao (FK gncdnto)
                                   ,pr_dsprofissao            IN VARCHAR2 -- Descricao da profissao (Cargo)
                                   ,pr_vlrenda_presumida      IN VARCHAR2 -- Valor da renda que foi retornada pelo bureau de consulta
                                   ,pr_dsjustific_outros_rend IN VARCHAR2 -- Justificativa de outros rendimentos
                                   ,pr_cdpais                 IN NUMBER -- Codigo do PAIS (FK CRAPNAT.CDNACION)
                                   ,pr_nridentificacao        IN VARCHAR2 -- Numero identificacao fiscal -- Projeto 414 - Marcelo Telles Coelho - Mouts
                                   ,pr_dsnatureza_relacao     IN VARCHAR2 -- Natureza da relacao
                                   ,pr_dsestado               IN VARCHAR2 -- Descricao do estado
                                   ,pr_nrpassaporte           IN NUMBER -- Numero do passaporte
                                   ,pr_tpdeclarado            IN VARCHAR2 -- Identificador do tipo de declaracao
                                   ,pr_incrs                  IN NUMBER -- Indica se a pessoa e cadastrado na CHS  (0-Nao/ 1-Sim). CHS = Lei de Conformidade Tributaria de Contas no Exterior para europeus
                                   ,pr_infatca                IN NUMBER -- Indica se a pessoa e cadastrado na FACTCA  (0-Nao/ 1-Sim). FATCA = Lei de Conformidade Tributária de Contas no Exterior para Americanos
                                   ,pr_dsnaturalidade         IN VARCHAR2 -- Cidade de origem do estrangeiro
                                   ,pr_dscritic               OUT VARCHAR2) IS -- Retorno de Erro
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_fisica vwcadast_pessoa_fisica%ROWTYPE;

  BEGIN

    vr_pessoa_fisica.idpessoa := pr_idpessoa;
    vr_pessoa_fisica.nrcpf := pr_nrcpfcgc;
    vr_pessoa_fisica.nmpessoa := pr_nmpessoa;
    vr_pessoa_fisica.nmpessoa_receita := pr_nmpessoa_receita;
    vr_pessoa_fisica.tppessoa := pr_tppessoa;
    vr_pessoa_fisica.dtconsulta_spc := pr_dtconsulta_spc;
    vr_pessoa_fisica.dtconsulta_rfb := pr_dtconsulta_rfb;
    vr_pessoa_fisica.cdsituacao_rfb := pr_cdsituacao_rfb;
    vr_pessoa_fisica.tpconsulta_rfb := pr_tpconsulta_rfb;
    -- Campo abaixo nao sera atualizado neste momento
--    vr_pessoa_fisica.dtatualiza_telefone := pr_dtatualiza_telefone;
    vr_pessoa_fisica.dtconsulta_scr := pr_dtconsulta_scr;
    vr_pessoa_fisica.tpcadastro := pr_tpcadastro;
    vr_pessoa_fisica.cdoperad_altera := pr_cdoperad_altera;
    vr_pessoa_fisica.idcorrigido := pr_idcorrigido;
    vr_pessoa_fisica.dtalteracao := pr_dtalteracao;
    vr_pessoa_fisica.nmsocial := pr_nmsocial;
    vr_pessoa_fisica.tpsexo := pr_tpsexo;
    vr_pessoa_fisica.cdestado_civil := pr_cdestado_civil;
    vr_pessoa_fisica.dtnascimento := pr_dtnascimento;
    vr_pessoa_fisica.cdnaturalidade := pr_cdnaturalidade;
    vr_pessoa_fisica.cdnacionalidade := pr_cdnacionalidade;
    vr_pessoa_fisica.tpnacionalidade := pr_tpnacionalidade;
    vr_pessoa_fisica.tpdocumento := pr_tpdocumento;
    vr_pessoa_fisica.nrdocumento := pr_nrdocumento;
    vr_pessoa_fisica.dtemissao_documento := pr_dtemissao_documento;
    vr_pessoa_fisica.idorgao_expedidor := pr_idorgao_expedidor;
    vr_pessoa_fisica.cduf_orgao_expedidor := pr_cduf_orgao_expedidor;
    vr_pessoa_fisica.inhabilitacao_menor := pr_inhabilitacao_menor;
    vr_pessoa_fisica.dthabilitacao_menor := pr_dthabilitacao_menor;
    vr_pessoa_fisica.cdgrau_escolaridade := pr_cdgrau_escolaridade;
    vr_pessoa_fisica.cdcurso_superior := pr_cdcurso_superior;
    vr_pessoa_fisica.cdnatureza_ocupacao := pr_cdnatureza_ocupacao;
    vr_pessoa_fisica.dsprofissao := pr_dsprofissao;
    vr_pessoa_fisica.vlrenda_presumida := pr_vlrenda_presumida;
    vr_pessoa_fisica.dsjustific_outros_rend := pr_dsjustific_outros_rend;
    vr_pessoa_fisica.cdpais := pr_cdpais;
    vr_pessoa_fisica.nridentificacao := pr_nridentificacao;
    vr_pessoa_fisica.dsnatureza_relacao := pr_dsnatureza_relacao;
    vr_pessoa_fisica.dsestado := pr_dsestado;
    vr_pessoa_fisica.nrpassaporte := pr_nrpassaporte;
    vr_pessoa_fisica.tpdeclarado := pr_tpdeclarado;
    vr_pessoa_fisica.incrs := pr_incrs;
    vr_pessoa_fisica.infatca := pr_infatca;
    vr_pessoa_fisica.dsnaturalidade := pr_dsnaturalidade;

    -- Chama rotina passando um registro
    cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => vr_pessoa_fisica
                                    ,pr_cdcritic      => vr_cdcritic
                                    ,pr_dscritic      => pr_dscritic);

    -- Retorna a sequencia do telefone
    pr_idpessoa := vr_pessoa_fisica.idpessoa;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_fisica: ' ||
                     SQLERRM;
  END;

	  -- Rotina para cadastro de pessoa juridica
  PROCEDURE pc_cadast_pessoa_juridica(pr_idpessoa                IN OUT NUMBER  -- Identificador unico da pessoa
                                     ,pr_nrcpfcgc                   IN NUMBER   -- Numero do documento CPF ou CNPJ
                                     ,pr_nmpessoa                   IN VARCHAR2 -- Nome da Pessoa
                                     ,pr_nmpessoa_receita           IN VARCHAR2 -- Nome da Pessoa na Receita Federal
                                     ,pr_tppessoa                   IN NUMBER   -- Tipo de Pessoa (1-Fisica/ 2-Juridica)
                                     ,pr_dtconsulta_spc             IN DATE     -- Data da ultima consulta no SPC
                                     ,pr_dtconsulta_rfb             IN DATE     -- Data da ultima consulta do CPF ou CNPJ na Receita Federal
                                     ,pr_cdsituacao_rfb             IN NUMBER   -- Situacao do CPF ou CNPJ na Receita Federal
                                     ,pr_tpconsulta_rfb             IN NUMBER   -- Consulta na Receita Federal (1-Automatica/ 2-Manual)
                                     ,pr_dtconsulta_scr             IN DATE     -- Data da ultima consulta no SCR
                                     ,pr_tpcadastro                 IN NUMBER   -- Tipo de cadastro (0-Nao definido/ 1-Prospect/ 2-Basico/ 3-Intermediario/ 4-Completo)
                                     ,pr_cdoperad_altera            IN VARCHAR2 -- Codigo do operador que realizou a ultima alteracao
                                     ,pr_idcorrigido                IN NUMBER   -- idpessoa assumido para esta pessoa no momento da identificacao de duplicidade no cadastro
                                     ,pr_dtalteracao                IN DATE     -- Data da ultima alteracao no cadastro
                                     ,pr_cdcnae                     IN NUMBER   -- Codigo CNAE (FK tbgen_cnae)
                                     ,pr_nmfantasia                 IN VARCHAR2 -- Nome Fantasia
                                     ,pr_nrinscricao_estadual       IN NUMBER   -- Inscricao Estatual
                                     ,pr_cdnatureza_juridica        IN NUMBER   -- Natureza Juridica (FK gncdntj)
                                     ,pr_dtconstituicao             IN DATE     -- Data de constituicao da empresa
                                     ,pr_dtinicio_atividade         IN DATE     -- Data de inicio das atividades
                                     ,pr_qtfilial                   IN NUMBER   -- Quantidade de Filiais
                                     ,pr_qtfuncionario              IN NUMBER   -- Quantidade de Funcionarios
                                     ,pr_vlcapital                  IN NUMBER   -- Valor do Capital Social
                                     ,pr_dtregistro                 IN DATE     -- Data do Registro
                                     ,pr_nrregistro                 IN NUMBER   -- Numero do Registro
                                     ,pr_dsorgao_registro           IN VARCHAR2   -- Descricao do orgao de emissao do CNPJ
                                     ,pr_dtinscricao_municipal      IN DATE     -- Data da Inscricao Municipal
                                     ,pr_nrnire                     IN NUMBER   -- Numero de Identificacao no Registro de Empresas
                                     ,pr_inrefis                    IN NUMBER   -- Indica se a empresa e optante pelo REFIS (0-Nao/ 1-Sim)
                                     ,pr_dssite                     IN VARCHAR2 -- URL Site
                                     ,pr_nrinscricao_municipal      IN NUMBER   -- Numero da Inscricao Municipal
                                     ,pr_cdsetor_economico          IN NUMBER   -- Setor Economico conforme definido em (craptab.cdacesso = "SETORECONO")
                                     ,pr_vlfaturamento_anual        IN NUMBER   -- Valor do Faturamento Anual da Empresa
                                     ,pr_cdramo_atividade           IN NUMBER   -- Ramo de Atividade (FK gnrativ)
                                     ,pr_nrlicenca_ambiental        IN NUMBER   -- Numero da Licenca Ambiental
                                     ,pr_dtvalidade_licenca_amb     IN DATE     -- Data de Validade da Licenca Ambiental
                                     ,pr_peunico_cliente            IN NUMBER   -- Percentual de faturamento em um unico cliente (maior cliente)
                                     ,pr_tpregime_tributacao        IN NUMBER   -- Forma de tributacao da empresa (1-Simples Nacional, 2-Simples Nacional MEI, 3-Lucro Real, 4-Lucro Presumido)
                                     ,pr_incrs                      IN NUMBER   -- Indica se a pessoa e cadastrado na crs  (0-nao/ 1-sim). crs = lei de conformidade tributaria de contas no exterior para europeus
                                     ,pr_infatca                    IN NUMBER   -- Indica se a pessoa e cadastrado na fatca  (0-nao/ 1-sim). fatca = lei de conformidade tributaria de contas no exterior para americanos
                                     ,pr_cdpais                     IN NUMBER   -- Codigo do pais (fk crapnat.cdnacion)
                                     ,pr_nridentificacao            IN VARCHAR2 -- Numero identificacao fiscal -- Projeto 414 - Marcelo Telles Coelho - Mouts
                                     ,pr_dsnatureza_relacao         IN VARCHAR2 -- Natureza da relacao
                                     ,pr_dsestado                   IN VARCHAR2 -- Descricao do estado
                                     ,pr_nrpassaporte               IN VARCHAR2 -- Numero do passaporte
                                     ,pr_tpdeclarado                IN VARCHAR2 -- Identificador do tipo de declaracao
                                     ,pr_dsnaturalidade             IN VARCHAR2 -- Cidade de origem do estrangeiro
                                     ,pr_vlreceita_bruta            IN NUMBER   -- Valor do faturamento mensal bruto
                                     ,pr_vlcusto_despesa_adm        IN NUMBER   -- Valor dos custos e despesas administrativas dos 12 meses
                                     ,pr_vldespesa_administrativa   IN NUMBER   -- Valor das despesas financeiras
                                     ,pr_qtdias_recebimento         IN NUMBER   -- Prazo medio em dias para o recebimento
                                     ,pr_qtdias_pagamento           IN NUMBER   -- Prazo medio em dias para o pagamento
                                     ,pr_vlativo_caixa_banco_apl    IN NUMBER   -- Valor do caixa, bancos e aplicacoes financeiras
                                     ,pr_vlativo_contas_receber     IN NUMBER   -- Valor do contas a receber.
                                     ,pr_vlativo_estoque            IN NUMBER   -- Valor dos estoques
                                     ,pr_vlativo_imobilizado        IN NUMBER   -- Valor do imobilizado
                                     ,pr_vlativo_outros             IN NUMBER   -- Valor de outros ativos
                                     ,pr_vlpassivo_fornecedor       IN NUMBER   -- Valor dos fornecedores
                                     ,pr_vlpassivo_divida_bancaria  IN NUMBER   -- Valor do endividamento bancario total
                                     ,pr_vlpassivo_outros           IN NUMBER   -- Valor de outros ativos
                                     ,pr_dtmes_base                 IN DATE     -- Data base das informacoes financeiras
                                     ,pr_dscritic                  OUT VARCHAR2) IS -- Retorno de Erro



    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_juridica vwcadast_pessoa_juridica%ROWTYPE;

  BEGIN

		vr_pessoa_juridica.idpessoa := pr_idpessoa;
		vr_pessoa_juridica.nrcnpj := pr_nrcpfcgc;
		vr_pessoa_juridica.nmpessoa := pr_nmpessoa;
		vr_pessoa_juridica.nmpessoa_receita := pr_nmpessoa_receita;
		vr_pessoa_juridica.tppessoa := pr_tppessoa;
		vr_pessoa_juridica.dtconsulta_spc := pr_dtconsulta_spc;
		vr_pessoa_juridica.dtconsulta_rfb := pr_dtconsulta_rfb;
		vr_pessoa_juridica.cdsituacao_rfb := pr_cdsituacao_rfb;
		vr_pessoa_juridica.tpconsulta_rfb := pr_tpconsulta_rfb;
    -- Campo abaixo nao sera atualizado neste momento
--		vr_pessoa_juridica.dtatualiza_telefone := pr_dtatualiza_telefone;
		vr_pessoa_juridica.dtconsulta_scr := pr_dtconsulta_scr;
		vr_pessoa_juridica.tpcadastro := pr_tpcadastro;
		vr_pessoa_juridica.cdoperad_altera := pr_cdoperad_altera;
		vr_pessoa_juridica.idcorrigido := pr_idcorrigido;
		vr_pessoa_juridica.dtalteracao := pr_dtalteracao;
		vr_pessoa_juridica.cdcnae := pr_cdcnae;
		vr_pessoa_juridica.nmfantasia := pr_nmfantasia;
		vr_pessoa_juridica.nrinscricao_estadual := pr_nrinscricao_estadual;
		vr_pessoa_juridica.cdnatureza_juridica := pr_cdnatureza_juridica;
		vr_pessoa_juridica.dtconstituicao := pr_dtconstituicao;
		vr_pessoa_juridica.dtinicio_atividade := pr_dtinicio_atividade;
		vr_pessoa_juridica.qtfilial := pr_qtfilial;
		vr_pessoa_juridica.qtfuncionario := pr_qtfuncionario;
		vr_pessoa_juridica.vlcapital := pr_vlcapital;
		vr_pessoa_juridica.dtregistro := pr_dtregistro;
		vr_pessoa_juridica.nrregistro := pr_nrregistro;
		vr_pessoa_juridica.dsorgao_registro := pr_dsorgao_registro;
		vr_pessoa_juridica.dtinscricao_municipal := pr_dtinscricao_municipal;
		vr_pessoa_juridica.nrnire := pr_nrnire;
		vr_pessoa_juridica.inrefis := pr_inrefis;
		vr_pessoa_juridica.dssite := pr_dssite;
		vr_pessoa_juridica.nrinscricao_municipal := pr_nrinscricao_municipal;
		vr_pessoa_juridica.cdsetor_economico := pr_cdsetor_economico;
		vr_pessoa_juridica.vlfaturamento_anual := pr_vlfaturamento_anual;
		vr_pessoa_juridica.cdramo_atividade := pr_cdramo_atividade;
		vr_pessoa_juridica.nrlicenca_ambiental := pr_nrlicenca_ambiental;
		vr_pessoa_juridica.dtvalidade_licenca_amb := pr_dtvalidade_licenca_amb;
		vr_pessoa_juridica.peunico_cliente := pr_peunico_cliente;
    vr_pessoa_juridica.tpregime_tributacao := pr_tpregime_tributacao;
    vr_pessoa_juridica.incrs                        := pr_incrs                    ;
    vr_pessoa_juridica.infatca                      := pr_infatca                  ;
    vr_pessoa_juridica.cdpais                       := pr_cdpais                   ;
    vr_pessoa_juridica.nridentificacao              := pr_nridentificacao          ;
    vr_pessoa_juridica.dsnatureza_relacao           := pr_dsnatureza_relacao       ;
    vr_pessoa_juridica.dsestado                     := pr_dsestado                 ;
    vr_pessoa_juridica.nrpassaporte                 := pr_nrpassaporte             ;
    vr_pessoa_juridica.tpdeclarado                  := pr_tpdeclarado              ;
    vr_pessoa_juridica.dsnaturalidade               := pr_dsnaturalidade           ;
    vr_pessoa_juridica.vlreceita_bruta              := pr_vlreceita_bruta          ;
    vr_pessoa_juridica.vlcusto_despesa_adm          := pr_vlcusto_despesa_adm      ;
    vr_pessoa_juridica.vldespesa_administrativa     := pr_vldespesa_administrativa ;
    vr_pessoa_juridica.qtdias_recebimento           := pr_qtdias_recebimento       ;
    vr_pessoa_juridica.qtdias_pagamento             := pr_qtdias_pagamento         ;
    vr_pessoa_juridica.vlativo_caixa_banco_apl      := pr_vlativo_caixa_banco_apl  ;
    vr_pessoa_juridica.vlativo_contas_receber       := pr_vlativo_contas_receber   ;
    vr_pessoa_juridica.vlativo_estoque              := pr_vlativo_estoque          ;
    vr_pessoa_juridica.vlativo_imobilizado          := pr_vlativo_imobilizado      ;
    vr_pessoa_juridica.vlativo_outros               := pr_vlativo_outros           ;
    vr_pessoa_juridica.vlpassivo_fornecedor         := pr_vlpassivo_fornecedor     ;
    vr_pessoa_juridica.vlpassivo_divida_bancaria    := pr_vlpassivo_divida_bancaria;
    vr_pessoa_juridica.vlpassivo_outros             := pr_vlpassivo_outros         ;
    vr_pessoa_juridica.dtmes_base                   := pr_dtmes_base               ;


    -- Chama rotina passando um registro
    cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => vr_pessoa_juridica
                                      ,pr_cdcritic        => vr_cdcritic
                                      ,pr_dscritic        => pr_dscritic);

    -- Retorna a sequencia do telefone
    pr_idpessoa := vr_pessoa_juridica.idpessoa;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_juridica: ' ||
                     SQLERRM;
  END;

  -- Rotina para retorno de ID pessoa passando como parametro o CPF / CNPJ
  PROCEDURE pc_retorna_IdPessoa(pr_nrcpfcgc IN  NUMBER -- Numero do CPF / CNPJ
                               ,pr_idpessoa OUT NUMBER -- Registro de pessoa
													   	 ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro
    -- Cursor para buscar o cadastro de pessoa
    CURSOR cr_pessoa IS
      SELECT tps.idpessoa
        FROM tbcadast_pessoa tps
       WHERE nrcpfcgc = pr_nrcpfcgc;
		rw_pessoa cr_pessoa%ROWTYPE;

		-- Exceções
		vr_exc_erro EXCEPTION;
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;

  BEGIN
    OPEN cr_pessoa;
    FETCH cr_pessoa INTO pr_idpessoa;
    CLOSE cr_pessoa;

  EXCEPTION
		WHEN vr_exc_erro THEN
			-- Se possuir código de crítica
			IF vr_cdcritic > 0 THEN
				-- Buscar código da crítica
				vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
			END IF;
			-- Retornar crítica
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_IdPessoa: ' ||
                     SQLERRM;
  END;

  -- Rotina para retorno de pessoa
  PROCEDURE pc_retorna_pessoa(pr_idpessoa IN NUMBER -- Registro de pessoa
														 ,pr_retorno  OUT xmltype -- XML de retorno
														 ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro

		-- Exceções
		vr_exc_erro EXCEPTION;
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado

    -- Cursor para buscar o cadastro de pessoa
    CURSOR cr_pessoa IS
      SELECT tps.nrcpfcgc
						,tps.nmpessoa
						,tps.nmpessoa_receita
						,tps.tppessoa
						,tps.dtconsulta_spc
						,tps.dtconsulta_rfb
						,tps.cdsituacao_rfb
						,tps.tpconsulta_rfb
						,tps.dtatualiza_telefone
						,tps.dtconsulta_scr
						,tps.tpcadastro
						,tps.idcorrigido
						,tps.dtalteracao
            ,ROWNUM - 1 seq
        FROM tbcadast_pessoa tps
       WHERE tps.idpessoa = pr_idpessoa
         AND pr_idpessoa IS NOT NULL;
		rw_pessoa cr_pessoa%ROWTYPE;

    -- Cursor para buscar a maior data de alteracao do resultado
    CURSOR cr_data_resultado IS
      SELECT max(a.dhalteracao) dhalteracao
        FROM tbcadast_pessoa_historico a,
             tbcadast_campo_historico b
       WHERE b.nmtabela_oracle = 'TBCADAST_PESSOA_JURIDICA_FNC'
         AND b.nmcampo IN ('VLRECEITA_BRUTA',
                           'VLCUSTO_DESPESA_ADM',
                           'VLDESPESA_ADMINISTRATIVA',
                           'QTDIAS_RECEBIMENTO',
                           'QTDIAS_PAGAMENTO')
         AND a.idcampo = b.idcampo
         AND a.idpessoa = pr_idpessoa;
    rw_data_resultado cr_data_resultado%ROWTYPE;

    -- Cursor para buscar a maior data de alteracao de ativo
    CURSOR cr_data_ativo IS
      SELECT max(a.dhalteracao) dhalteracao
        FROM tbcadast_pessoa_historico a,
             tbcadast_campo_historico b
       WHERE b.nmtabela_oracle = 'TBCADAST_PESSOA_JURIDICA_FNC'
         AND b.nmcampo IN ('VLATIVO_CAIXA_BANCO_APL',
                           'VLATIVO_CONTAS_RECEBER',
                           'VLATIVO_ESTOQUE',
                           'VLATIVO_IMOBILIZADO',
                           'VLATIVO_OUTROS')
         AND a.idcampo = b.idcampo
         AND a.idpessoa = pr_idpessoa;
    rw_data_ativo cr_data_ativo%ROWTYPE;

    -- Cursor para buscar a maior data de alteracao de ativo
    CURSOR cr_data_passivo IS
      SELECT max(a.dhalteracao) dhalteracao
        FROM tbcadast_pessoa_historico a,
             tbcadast_campo_historico b
       WHERE b.nmtabela_oracle = 'TBCADAST_PESSOA_JURIDICA_FNC'
         AND b.nmcampo IN ('VLPASSIVO_FORNECEDOR',
                           'VLPASSIVO_DIVIDA_BANCARIA',
                           'VLPASSIVO_OUTROS')
         AND a.idcampo = b.idcampo
         AND a.idpessoa = pr_idpessoa;
    rw_data_passivo cr_data_passivo%ROWTYPE;

  BEGIN

    --> Verificar se pessoa existe
    OPEN cr_pessoa;
    FETCH cr_pessoa INTO rw_pessoa;
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;
      vr_dscritic := 'Pessoa nao encontrada.';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_pessoa;

    --> PF
    IF rw_pessoa.tppessoa = 1 THEN

      -- retornar os dados da tabela via xml
      pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa                    --> Id de pessoa
                           ,pr_nmtabela => 'VWCADAST_PESSOA_FISICA'       --> Nome da tabela
                           ,pr_dsnoprin => 'Pessoas'                      --> Nó principal do xml
                           ,pr_dsnofilh => 'Pessoa'                       --> Nós filhos
                           ,pr_retorno  => pr_retorno                     --> XML de retorno
                           ,pr_dscritic => pr_dscritic);

    ELSE
      --> PJ
      -- retornar os dados da tabela via xml
      pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa                    --> Id de pessoa
                           ,pr_nmtabela => 'VWCADAST_PESSOA_JURIDICA'     --> Nome da tabela
                           ,pr_dsnoprin => 'Pessoas'                      --> Nó principal do xml
                           ,pr_dsnofilh => 'Pessoa'                       --> Nós filhos
                           ,pr_retorno  => pr_retorno                     --> XML de retorno
                           ,pr_dscritic => pr_dscritic);
      -- Busca a data da ultima alteracao do passivo
      OPEN cr_data_passivo;
      FETCH cr_data_passivo INTO rw_data_passivo;
      CLOSE cr_data_passivo;
      -- Insere a data
      gene0007.pc_insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Pessoa'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'DTALTERACAO_PASSIVO'
                            ,pr_tag_cont => to_char(rw_data_passivo.dhalteracao,'DD/MM/YYYY hh24:MI:SS')
                            ,pr_des_erro => pr_dscritic);

      -- Busca a data da ultima alteracao do ativo
      OPEN cr_data_ativo;
      FETCH cr_data_ativo INTO rw_data_ativo;
      CLOSE cr_data_ativo;
      -- Insere a data
      gene0007.pc_insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Pessoa'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'DTALTERACAO_ATIVO'
                            ,pr_tag_cont => to_char(rw_data_ativo.dhalteracao,'DD/MM/YYYY hh24:MI:SS')
                            ,pr_des_erro => pr_dscritic);

      -- Busca a data da ultima alteracao do resultado
      OPEN cr_data_resultado;
      FETCH cr_data_resultado INTO rw_data_resultado;
      CLOSE cr_data_resultado;
      -- Insere a data
      gene0007.pc_insere_tag(pr_xml      => pr_retorno
                            ,pr_tag_pai  => 'Pessoa'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'DTALTERACAO_RESULTADO'
                            ,pr_tag_cont => to_char(rw_data_resultado.dhalteracao,'DD/MM/YYYY hh24:MI:SS')
                            ,pr_des_erro => pr_dscritic);

    END IF;


  EXCEPTION
		WHEN vr_exc_erro THEN
			-- Se possuir código de crítica
			IF vr_cdcritic > 0 THEN
				-- Buscar código da crítica
				vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
			END IF;
			-- Retornar crítica
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa: ' ||
                     SQLERRM;
  END;

  -- Rotina para retorno das contas da pessoa (Consulta simplificada)
  PROCEDURE pc_retorna_pessoa_conta(pr_cdcooper IN NUMBER  -- Codigo da cooperativa
                                   ,pr_idpessoa IN NUMBER  -- Identificador unico da pessoa
														       ,pr_retorno  OUT xmltype -- XML de retorno
														       ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro
		/* ..........................................................................
    --
    --  Programa : pc_retorna_pessoa_conta
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : 
    --  Data     :                        Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para retorno das contas da pessoa (Consulta simplificada)
    --
    --  Alteração : 30/05/2018 - Ajuste para permitir passar pr_cdcooper zerado.
    --                           PRJ - CDC (Odirlei-AMcom)
    --
    --
    -- ..........................................................................*/
		-- Exceções
		vr_exc_erro EXCEPTION;
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado

    -- Cursor para buscar as contas da pessoa
    CURSOR cr_contas IS
      SELECT /*+index (ass CRAPASS##CRAPASS5)*/
             ass.cdcooper
            ,ass.nrdconta
            ,1 idseqttl
            ,ROWNUM - 1 seq
        FROM tbcadast_pessoa tps
				    ,crapass ass
       WHERE tps.idpessoa = pr_idpessoa
			   AND ass.cdcooper = DECODE(NVL(pr_cdcooper,0),0,ass.cdcooper,pr_cdcooper) 
				 AND ass.nrcpfcgc = tps.nrcpfcgc
         AND ass.inpessoa <> 1
--				 AND ass.dtdemiss IS NULL
      UNION ALL
      SELECT /*+index (ttl CRAPTTL##CRAPTTL6)*/
             ass.cdcooper
            ,ass.nrdconta
            ,ttl.idseqttl
            ,ROWNUM - 1 seq
        FROM crapass ass
            ,tbcadast_pessoa tps
				    ,crapttl ttl
       WHERE tps.idpessoa = pr_idpessoa
			   AND ttl.cdcooper = DECODE(NVL(pr_cdcooper,0),0,ttl.cdcooper,pr_cdcooper) 
				 AND ttl.nrcpfcgc = tps.nrcpfcgc
         AND ass.cdcooper = ttl.cdcooper
         AND ass.nrdconta = ttl.nrdconta
--				 AND ass.dtdemiss IS NULL
         ;

  BEGIN
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Contas/>');

      -- Loop sobre a tabela de pessoas
    FOR rw_contas IN cr_contas LOOP

			-- Insere o nó principal
			gene0007.pc_insere_tag(pr_xml      => vr_xml
														,pr_tag_pai  => 'Contas'
														,pr_posicao  => 0
														,pr_tag_nova => 'Conta'
														,pr_tag_cont => NULL
														,pr_des_erro => pr_dscritic);

      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Conta'
                            ,pr_posicao  => rw_contas.seq
                            ,pr_tag_nova => 'cdcooper'
                            ,pr_tag_cont => rw_contas.cdcooper
                            ,pr_des_erro => pr_dscritic);

      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Conta'
                            ,pr_posicao  => rw_contas.seq
                            ,pr_tag_nova => 'nrdconta'
                            ,pr_tag_cont => rw_contas.nrdconta
                            ,pr_des_erro => pr_dscritic);

      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Conta'
                            ,pr_posicao  => rw_contas.seq
                            ,pr_tag_nova => 'idseqttl'
                            ,pr_tag_cont => rw_contas.idseqttl
                            ,pr_des_erro => pr_dscritic);

    END LOOP;
    
    pr_retorno := vr_xml;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_conta: ' ||
                     SQLERRM;
  END;

  -- Rotina para retorno com todos os dados da conta
    -- Rotina para retorno com todos os dados da conta
  PROCEDURE pc_retorna_dados_conta(pr_cdcooper IN NUMBER  -- Codigo da cooperativa
                                  ,pr_nrdconta IN NUMBER  -- Numero da conta
                                  ,pr_retorno  OUT xmltype -- XML de retorno
                                  ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro
-- pr_retorno
--        cdagenci              - Nr.PA
--        dtdesligamento        - Data Desligamento
--        qtanos_desligamento   - Tempo de Desligamento (Qtd.anos -> Data Atual - Data desligamento)
--        cdmotivo_desligamento - Motivo Desligamento
--        vlcapital_saida       - Valor Capital na Saída
--        vlcotas_liberadas     - Valor da cotas liberadas para saque
--        inrisco_credito       - Indicador de risco do cooperado (de A ate H)
--        dtrisco_credito       - Data Risco de Crédito na Saída

--        vlcotas_liberadas     - Valor disponível para saque

    -- Cursor para buscar os dados da contas
    CURSOR cr_dados_contas IS
      SELECT a.cdagenci                  CDAGENCI              -- PA
            ,b.cddregio
            ,to_char(a.dtdemiss,'dd/mm/yyyy HH24:mi:ss')
                                         DTDESLIGAMENTO        -- DATA DESLIGAMENTO
            ,to_char(sysdate,'yyyy') -
             to_char(a.dtdemiss,'yyyy')  QTANOS_DESLIGAMENTO   -- TEMPO DE DESLIGAMENTO
            ,a.cdmotdem                  CDMOTIVO_DESLIGAMENTO -- MOTIVO DE DEMISSÃO
            ,a.inrisctl                  INRISCO_CREDITO       -- INDICADOR DE RISCO DO COOPERADO (DE A ATE H)
            ,a.dtrisctl                  DTRISCO_CREDITO       -- Data em que foi atribuida a nota do risco do titular
            ,decode(a.inpessoa,1,'F','J') tppessoa
            ,a.inpessoa
            ,a.nrcpfcgc
        FROM crapage b,
             crapass A
       WHERE A.NRDCONTA = pr_nrdconta
         AND A.CDCOOPER = pr_cdcooper
         AND b.cdcooper (+) = a.cdcooper
         AND b.cdagenci (+) = a.cdagenci;

    -- Busca os titulares da conta
    CURSOR cr_crapttl IS
      SELECT rownum - 1 sequencia,
             a.idseqttl,
             a.nrcpfcgc
        FROM crapttl A
       WHERE a.nrdconta = pr_nrdconta
         AND a.cdcooper = pr_cdcooper
         ORDER BY a.idseqttl;

    -- Variaveis
    w_vlcapital_saida    NUMBER;
    w_vlcotas_liberadas  NUMBER;
    --
    -- Variaveis gerais
    vr_xml      xmltype; -- XML qye sera enviado
    vr_exc_erro EXCEPTION;

  BEGIN
    vr_xml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    FOR r_dados_contas in cr_dados_contas LOOP

      w_vlcapital_saida   := null;
      w_vlcotas_liberadas := null;
      pr_dscritic         := null;

      IF r_dados_contas.dtdesligamento IS NOT NULL THEN
        FOR r_capital in (SELECT VLLANMTO vlcapital_saida
              FROM (SELECT *
                      FROM CRAPLCT A
                     WHERE A.NRDCONTA = pr_nrdconta
                       AND A.CDCOOPER = pr_cdcooper
                       AND A.DTMVTOLT <= to_date(r_dados_contas.dtdesligamento,'dd/mm/yyyy HH24:mi:ss')
                     ORDER BY A.DTMVTOLT DESC)
                     WHERE ROWNUM = 1)
        LOOP
          w_vlcapital_saida := r_capital.vlcapital_saida;
        END LOOP;
      ELSE
        CADA0012.pc_retorna_cotas_liberada(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_vldcotas => w_vlcotas_liberadas
                                          ,pr_dscritic => pr_dscritic);
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --
      -- Insere o nó principal
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dados_conta'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_gera_atributo(pr_xml      => vr_xml
                               ,pr_tag      => 'dados_conta'
                               ,pr_atrib    => 'qtregist'
                               ,pr_atval    => 1
                               ,pr_numva    => 0
                               ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'dados_conta'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'conta'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);

      -- Insere os detalhes
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'conta'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'cdagenci'
                            ,pr_tag_cont => r_dados_contas.cdagenci
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'conta'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'cddregio'
                            ,pr_tag_cont => r_dados_contas.cddregio
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'conta'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dtdesligamento'
                            ,pr_tag_cont => r_dados_contas.dtdesligamento
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'conta'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtanos_desligamento'
                            ,pr_tag_cont => r_dados_contas.qtanos_desligamento
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'conta'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'cdmotivo_desligamento'
                            ,pr_tag_cont => r_dados_contas.cdmotivo_desligamento
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'conta'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlcapital_saida'
                            ,pr_tag_cont => trim(to_char(w_vlcapital_saida, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'conta'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inrisco_credito'
                            ,pr_tag_cont => r_dados_contas.inrisco_credito
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'conta'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dtrisco_credito'
                            ,pr_tag_cont => to_char(r_dados_contas.dtrisco_credito,'dd/mm/yyyy hh24:mi:ss')
                            ,pr_des_erro => pr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'conta'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlcotas_liberadas'
                            ,pr_tag_cont => trim(to_char(w_vlcotas_liberadas, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))
                            ,pr_des_erro => pr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'conta'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'tppessoa'
                            ,pr_tag_cont => r_dados_contas.tppessoa
                            ,pr_des_erro => pr_dscritic);

      -- Insere os dados do CPF / CNPJ
      gene0007.pc_insere_tag(pr_xml      => vr_xml
                            ,pr_tag_pai  => 'conta'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'titulares'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => pr_dscritic);
      -- Se for pessoa juridica
      IF r_dados_contas.inpessoa = 2 THEN
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'titulares'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'titular'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'titular'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'sequencia'
                              ,pr_tag_cont => '1'
                              ,pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => vr_xml
                              ,pr_tag_pai  => 'titular'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrcpfcgc'
                              ,pr_tag_cont => r_dados_contas.nrcpfcgc
                              ,pr_des_erro => pr_dscritic);
      ELSE
        -- Loop sobre os titulares
        FOR rw_crapttl IN cr_crapttl LOOP
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'titulares'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'titular'
                                ,pr_tag_cont => NULL
                                ,pr_des_erro => pr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'titular'
                                ,pr_posicao  => rw_crapttl.sequencia
                                ,pr_tag_nova => 'sequencia'
                                ,pr_tag_cont => rw_crapttl.idseqttl
                                ,pr_des_erro => pr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => vr_xml
                                ,pr_tag_pai  => 'titular'
                                ,pr_posicao  => rw_crapttl.sequencia
                                ,pr_tag_nova => 'nrcpfcgc'
                                ,pr_tag_cont => rw_crapttl.nrcpfcgc
                                ,pr_des_erro => pr_dscritic);
        END LOOP;
      END IF;

    END LOOP;

    pr_retorno := vr_xml;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Erro já tratado, pr_dscritic já esta populado.
      NULL;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_dados_conta: ' ||
                     SQLERRM;
  END pc_retorna_dados_conta;

  -- Rotina para retorno de identificacao pessoa
  PROCEDURE pc_retorna_identificacao(pr_idpessoa IN NUMBER -- Registro de pessoa
                                    ,pr_cdcooper IN NUMBER -- Cooperativa
                                    ,pr_dscanal  IN VARCHAR2 -- Canal
                                    ,pr_retorno  OUT xmltype -- XML de retorno
                                    ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro
  /* ..........................................................................
    --
    --  Programa : pc_retorna_identificacao
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CADA
    --  Autor    : Vitor S. Assanuma (GFT)
    --  Data     : Março/2019.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para identificar o cooperado logando
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(500);

    -- Retorno da procedure
    vr_vlparamt    VARCHAR(500);
    vr_nrtentativa NUMBER;
    vr_flexcedeu   BOOLEAN;
    vr_flatualizar BOOLEAN;
    vr_dtatualizar DATE;

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%rowtype;

    -- Cursor para buscar a conta utilizando idpessoa
    CURSOR cr_tbpessoa IS
      SELECT
         tps.idpessoa
        ,tps.nrtentativa
        ,alt.dtaltera
      FROM
        TBCADAST_PESSOA tps
      INNER JOIN
        crapass ass ON  ass.nrcpfcgc = tps.nrcpfcgc
      INNER JOIN
        crapalt alt ON ass.cdcooper = alt.cdcooper AND ass.nrdconta = alt.nrdconta
      WHERE tps.idpessoa = pr_idpessoa
        AND ass.cdcooper = pr_cdcooper
        AND alt.dtaltera = (SELECT MAX(dtaltera) FROM crapalt WHERE cdcooper = pr_cdcooper AND nrdconta = ass.nrdconta);
    rw_tbpessoa cr_tbpessoa%ROWTYPE;
    BEGIN
      -- Inicialização de variáveis
      vr_nrtentativa := 0;
      vr_flexcedeu   := FALSE;
      vr_flatualizar := FALSE;

      -- Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      IF (btch0001.cr_crapdat%NOTFOUND) THEN
        CLOSE btch0001.cr_crapdat;
        vr_dscritic := 'Erro ao buscar data na crapdat';
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;

      -- Abre o cursor de pessoa para buscar as datas de alteração
      OPEN cr_tbpessoa;
      FETCH cr_tbpessoa INTO rw_tbpessoa;
      IF (cr_tbpessoa%NOTFOUND) THEN
        CLOSE cr_tbpessoa;
        vr_dscritic := 'Pessoa não encontrada';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_tbpessoa;

      -- Busca o parâmetro cadastrado para verificar se é para notificar
      pc_busca_parametro_tarifas(pr_cdcooper => pr_cdcooper
                                ,pr_cdpartar => 66
                                ,pr_vlparamt => vr_vlparamt
                                ,pr_dscritic => vr_dscritic);
      IF (TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;

      -- Soma a data da ultima alteração com a quantidade de meses*30 (para ficar em dias) do parâmetro.
      vr_dtatualizar := rw_tbpessoa.dtaltera + NVL(vr_vlparamt, 0)*30;

      -- Verifica se já passou o período para notificar e se está no mês de aniversário OU se já foi notificado alguma vez
      IF ((((vr_dtatualizar <= rw_crapdat.dtmvtolt) AND (TO_CHAR(vr_dtatualizar, 'MM') = TO_CHAR(rw_tbpessoa.dtaltera, 'MM'))
          ) OR (NVL(rw_tbpessoa.nrtentativa, 0) > 0))) THEN
        -- Seta para atualizar
        vr_flatualizar := TRUE;

        -- Soma 1 as tentativas
        vr_nrtentativa := NVL(rw_tbpessoa.nrtentativa, 0) + 1;

        -- Atualizar o numero de tentativas
        UPDATE TBCADAST_PESSOA SET nrtentativa = NVL(nrtentativa, 0)+1 WHERE idpessoa = pr_idpessoa;
      ELSE
        -- Senão atualizar o numero de tentativas para 0
        UPDATE TBCADAST_PESSOA SET nrtentativa = 0 WHERE idpessoa = pr_idpessoa;
      END IF;

      -- Verifica se passou de 3 tentativas e é para notificar
      IF (vr_nrtentativa > 3) THEN
        vr_flexcedeu := TRUE;
      END IF;

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>' ||
                     '<root>'
                       || '<idpessoa>'      || pr_idpessoa    || '</idpessoa>'
                       || '<nrcooperativa>' || pr_cdcooper    || '</nrcooperativa>'
                       || '<flatualizacao>' || CASE WHEN vr_flatualizar THEN 'TRUE' ELSE 'FALSE' END || '</flatualizacao>'
                       || '<nrtentativa>'   || vr_nrtentativa || '</nrtentativa>'
                       || '<flexcedeu>'     || CASE WHEN vr_flexcedeu   THEN 'TRUE' ELSE 'FALSE' END || '</flexcedeu>'
                     );
      pc_escreve_xml ('</root>',true);
      pr_retorno := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);


    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na pc_retorna_identificacao: ' || SQLERRM;
  END pc_retorna_identificacao;

  -- Rotina para retorno dos dados da matricula do cooperado
  PROCEDURE pc_retorna_matricula(pr_cdcooper IN NUMBER  -- Codigo da cooperativa
                                ,pr_idpessoa IN NUMBER  -- Identificador unico da pessoa
														    ,pr_retorno  OUT xmltype -- XML de retorno
													      ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro
		-- Exceções
		vr_exc_erro EXCEPTION;
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
    -- Variáveis
    w_tpsituacao_matricula number;
    w_nrmatric             number;
    w_sequencia            number;
    w_tpmotivo             number;
    w_inblqexc             number;

    -- Cursor para buscar as matrículas da pessoa
    CURSOR cr_matriculas IS
      SELECT t.nrmatric
            ,t.cdmotdem
            ,t.dtdemiss
            ,ROWNUM - 1 seq
        FROM (SELECT DISTINCT
                     ass.nrmatric
                    ,ass.cdmotdem
                    ,ass.dtdemiss
                FROM tbcadast_pessoa tps
                    ,crapass         ass
               WHERE tps.idpessoa = pr_idpessoa
                 AND ass.cdcooper = pr_cdcooper
                 AND ass.nrcpfcgc = tps.nrcpfcgc
--                 AND ass.dtdemiss IS not NULL
               ORDER BY ass.dtdemiss DESC
                 ) t;
  BEGIN
-- teste realizado junto com o Miguel Valdepenas
    -- Cria o cabecalho do xml de envio
    vr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Matriculas/>');

    -- Loop sobre a tabela de pessoas
    FOR rw_matricula IN cr_matriculas LOOP
      --
      w_nrmatric := rw_matricula.nrmatric;
      w_sequencia:= rw_matricula.seq;
      w_tpsituacao_matricula := 0;
      IF rw_matricula.dtdemiss IS NULL THEN
        w_tpsituacao_matricula := 1;
        EXIT;
      ELSE
        w_tpmotivo := 1;
        --
        FOR r_motivo in (SELECT A.TPMOTIVO
                           FROM TBCOTAS_MOTIVO_DESLIGAMENTO A
                          WHERE A.CDMOTIVO = rw_matricula.cdmotdem)
        LOOP
          w_tpmotivo  := r_motivo.tpmotivo;
        END LOOP;
        --
        IF w_tpmotivo = 1 THEN -- Demissão
          w_tpsituacao_matricula := 4;
        ELSE
          FOR r_bloqueio in (SELECT INBLQEXC
                               FROM CRAPCOP A
                              WHERE A.CDCOOPER = pr_cdcooper)
          LOOP
            w_inblqexc := r_bloqueio.inblqexc;
          END LOOP;
          --
          IF w_inblqexc = 1 THEN -- SIM, bloqueia a readmissão de cooperado eliminado
            w_tpsituacao_matricula := 2;
            EXIT;
          ELSE
            w_tpsituacao_matricula := 3;
          END IF;
        END IF;
      END IF;
    END LOOP;
    -- Insere o nó principal
    gene0007.pc_insere_tag(pr_xml      => vr_xml
                          ,pr_tag_pai  => 'Matriculas'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Matricula'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => pr_dscritic);
    -- Insere os detalhes - Matricula
    gene0007.pc_insere_tag(pr_xml      => vr_xml
                          ,pr_tag_pai  => 'Matricula'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'nrmatric'
                          ,pr_tag_cont => w_nrmatric
                          ,pr_des_erro => pr_dscritic);
    -- Insere os detalhes - tpsituacao_matricula
    --  tpsituacao_matricula - Situação da Matrícula:
    --    1 = Ativa     - Sem Restrições
    --    2 = Excluída  - Reativação não permitida
    --    3 = Reativada - Reativação permitida - Segurança Corporativa
    --    4 = Demitida  - Reativação permitida
    gene0007.pc_insere_tag(pr_xml      => vr_xml
                          ,pr_tag_pai  => 'Matricula'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tpsituacao_matricula'
                          ,pr_tag_cont => w_tpsituacao_matricula
                          ,pr_des_erro => pr_dscritic);
    pr_retorno := vr_xml;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_matricula: ' ||
                     SQLERRM;
  END pc_retorna_matricula;

  -- Rotina para cadastro de telefones
  PROCEDURE pc_cadast_pessoa_telefone(pr_idpessoa               IN NUMBER -- Identificador unico da pessoa (FK tbcadast_pessoa)
                                     ,pr_nrseq_telefone         IN OUT NUMBER -- Numero sequencial do telefone
                                     ,pr_cdoperadora            IN NUMBER -- Codigo da operadora de telefone
                                     ,pr_tptelefone             IN NUMBER -- Tipo de telefone (1-Residencial/ 2-Celular/ 3-Comercial/ 4-Contato)
                                     ,pr_nmpessoa_contato       IN VARCHAR2 -- Pessoa de contato no telefone
                                     ,pr_nmsetor_pessoa_contato IN VARCHAR2 -- Secao da pessoa de contato
                                     ,pr_nrddd                  IN NUMBER -- Numero do DDD
                                     ,pr_nrtelefone             IN NUMBER -- Numero do telefone
                                     ,pr_nrramal                IN NUMBER -- Numero do ramal
                                     ,pr_insituacao             IN NUMBER -- Indicador de situacao do telefone (1-Ativo/ 2-Inativo)
                                     ,pr_tporigem_cadastro      IN NUMBER -- Tipo de origem do cadastro (1-Cooperado/ 2-Cooperativa/ 3-Terceiros)
                                     ,pr_cdoperad_altera        IN VARCHAR2 -- Codigo do operador que realizou a ultima alteracao
                                     ,pr_dscritic               OUT VARCHAR2) IS
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_telefone tbcadast_pessoa_telefone%ROWTYPE;

  BEGIN

    vr_pessoa_telefone.idpessoa := pr_idpessoa;
    vr_pessoa_telefone.nrseq_telefone := pr_nrseq_telefone;
    vr_pessoa_telefone.cdoperadora := pr_cdoperadora;
    vr_pessoa_telefone.tptelefone := pr_tptelefone;
    vr_pessoa_telefone.nmpessoa_contato := pr_nmpessoa_contato;
    vr_pessoa_telefone.nmsetor_pessoa_contato := pr_nmsetor_pessoa_contato;
    vr_pessoa_telefone.nrddd := pr_nrddd;
    vr_pessoa_telefone.nrtelefone := pr_nrtelefone;
    vr_pessoa_telefone.nrramal := pr_nrramal;
    vr_pessoa_telefone.insituacao := pr_insituacao;
    vr_pessoa_telefone.tporigem_cadastro := pr_tporigem_cadastro;
    vr_pessoa_telefone.cdoperad_altera := pr_cdoperad_altera;

    -- Chama rotina passando um registro
    cada0010.pc_cadast_pessoa_telefone(pr_pessoa_telefone => vr_pessoa_telefone
                                      ,pr_cdcritic        => vr_cdcritic
                                      ,pr_dscritic        => pr_dscritic);

    -- Retorna a sequencia do telefone
    pr_nrseq_telefone := vr_pessoa_telefone.nrseq_telefone;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_telefone: ' ||
                     SQLERRM;
  END;

  -- Rotina para excluir telefone
  PROCEDURE pc_exclui_pessoa_telefone(pr_idpessoa        IN NUMBER   -- Identificador de pessoa
																		 ,pr_nrseq_telefone  IN NUMBER   -- Nr. de sequência de telefone
																		 ,pr_cdoperad_altera IN VARCHAR2 -- Operador que esta efetuando a exclusao
																		 ,pr_cdcritic        OUT INTEGER                                     -- Codigo de erro
																		 ,pr_dscritic        OUT VARCHAR2) IS                                -- Retorno de Erro
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

    -- Chamar rotina para a exclusão
    cada0010.pc_exclui_pessoa_telefone(pr_idpessoa => pr_idpessoa
		                                  ,pr_nrseq_telefone => pr_nrseq_telefone
																			,pr_cdoperad_altera => pr_cdoperad_altera
																			,pr_cdcritic => pr_cdcritic
																			,pr_dscritic => pr_dscritic);

		-- Se retornou alguma crítica
		IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_telefone: ' ||SQLERRM;
	END;

  -- Rotina para retorno de telefones
  PROCEDURE pc_retorna_pessoa_telefone(pr_idpessoa IN NUMBER -- Registro de telefone
                                      ,pr_retorno  OUT xmltype -- XML de retorno
                                      ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;

  BEGIN
    -- Rotina generica para retornar os dados da tabela via xml
    pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa                    --> Id de pessoa
                         ,pr_nmtabela => 'TBCADAST_PESSOA_TELEFONE'     --> Nome da tabela
                         ,pr_dsnoprin => 'telefones'                    --> Nó principal do xml
                         ,pr_dsnofilh => 'telefone'                     --> Nós filhos
						 ,pr_clausula => '(INSITUACAO = 1)'             --> Cláusula Where
                         ,pr_retorno  => pr_retorno                     --> XML de retorno
                         ,pr_dscritic => pr_dscritic);				 

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_telefone: ' ||
                     SQLERRM;
  END;

  PROCEDURE pc_confirma_pessoa_telefone(pr_cdcooper       IN NUMBER -- Numero da cooperativa
                                       ,pr_idpessoa       IN NUMBER -- Registro de telefone
                                       ,pr_nrseq_telefone IN NUMBER -- Numero sequecial do telefone
                                       ,pr_flsituacao     IN NUMBER -- Situacao: 1 - Ativo/ 2 - Rejeitado
                                       ,pr_idcanal        IN NUMBER -- Canal que efetuou a atualização
                                       ,pr_dscritic      OUT VARCHAR2) IS -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_confirma_pessoa_telefone
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CADA
    --  Autor    : Vitor S. Assanuma (GFT)
    --  Data     : Março/2019.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para confirmar o telefone da pessoa
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    -- Variaveis de erro
    vr_dscritic VARCHAR(500);
    vr_exc_erro EXCEPTION;

    vr_vlparamt VARCHAR(500);

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%rowtype;
    BEGIN
      -- Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      IF (btch0001.cr_crapdat%NOTFOUND) THEN
        CLOSE btch0001.cr_crapdat;
        vr_dscritic := 'Erro ao buscar data na crapdat';
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;
           
      -- Busca o parâmetro cadastrado para verificar se é para inserir na crapalt
      pc_busca_parametro_tarifas(pr_cdcooper => pr_cdcooper
                                ,pr_cdpartar => 67
                                ,pr_vlparamt => vr_vlparamt
                                ,pr_dscritic => vr_dscritic);
      IF (TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;
      
      IF vr_vlparamt = '1' AND pr_flsituacao = 1 THEN
        -- Insere na crapalt
        pc_insere_crapalt(pr_idpessoa => pr_idpessoa
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt =>  rw_crapdat.dtmvtolt
                         ,pr_dsaltera => 'Confirmação do Telefone'
                         ,pr_dscritic => vr_dscritic);
        IF (TRIM(vr_dscritic) IS NOT NULL) THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
      
      BEGIN
        UPDATE TBCADAST_PESSOA_TELEFONE 
          SET idcanal    = pr_idcanal 
             ,insituacao = pr_flsituacao
             ,dtrevisao  = rw_crapdat.dtmvtolt
          WHERE idpessoa = pr_idpessoa
            AND nrseq_telefone = pr_nrseq_telefone;
            
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_TELEFONE: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na pc_confirma_pessoa_telefone: ' || SQLERRM;
  END pc_confirma_pessoa_telefone;


  -- Rotina para cadastrar email
  PROCEDURE pc_cadast_pessoa_email(pr_dsemail                IN VARCHAR2 -- Descricao do email
                                  ,pr_nmpessoa_contato       IN VARCHAR2 -- Pessoa de contato no e-mail
                                  ,pr_nmsetor_pessoa_contato IN VARCHAR2 -- Secao da pessoa de contato
                                  ,pr_cdoperad_altera        IN VARCHAR2 -- Codigo do operador que realizou a ultima alteracao
                                  ,pr_idpessoa               IN NUMBER -- Identificador unico da pessoa (FK tbcadast_pessoa)
                                  ,pr_nrseq_email            IN OUT NUMBER -- Numero sequencial do email
                                  ,pr_dscritic               OUT VARCHAR2) IS
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_email tbcadast_pessoa_email%ROWTYPE;

  BEGIN

    vr_pessoa_email.dsemail := pr_dsemail;
    vr_pessoa_email.nmpessoa_contato := pr_nmpessoa_contato;
    vr_pessoa_email.nmsetor_pessoa_contato := pr_nmsetor_pessoa_contato;
    vr_pessoa_email.cdoperad_altera := pr_cdoperad_altera;
    vr_pessoa_email.idpessoa := pr_idpessoa;
    vr_pessoa_email.nrseq_email := pr_nrseq_email;

    -- Chama rotina passando um registro
    cada0010.pc_cadast_pessoa_email(pr_pessoa_email => vr_pessoa_email
                                   ,pr_cdcritic     => vr_cdcritic
                                   ,pr_dscritic     => pr_dscritic);

    -- Retorna a sequencia do e-mail
    pr_nrseq_email := vr_pessoa_email.nrseq_email;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_email: ' ||
                     SQLERRM;
  END;

  -- Rotina para excluir email
  PROCEDURE pc_exclui_pessoa_email(pr_idpessoa        IN NUMBER       -- Identificador de pessoa
                                  ,pr_nrseq_email     IN NUMBER       -- Numero sequencial do email
                                  ,pr_cdoperad_altera IN VARCHAR2     -- Operador que esta efetuando a exclusao
                                  ,pr_cdcritic       OUT INTEGER      -- Codigo de erro
                                  ,pr_dscritic       OUT VARCHAR2) IS -- Retorno de Erro

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

	  -- Chamar rotina de exclusão
    CADA0010.pc_exclui_pessoa_email(pr_idpessoa => pr_idpessoa
		                               ,pr_nrseq_email => pr_nrseq_email
																	 ,pr_cdoperad_altera => pr_cdoperad_altera
																	 ,pr_cdcritic => pr_cdcritic
																	 ,pr_dscritic => pr_dscritic);

		-- Se retornou críticas
    IF pr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
		  -- Levantar exceção
			RAISE vr_exc_erro;
		END IF;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_email: ' ||SQLERRM;
  END;

  -- Rotina para retorno de email
  PROCEDURE pc_retorna_pessoa_email(pr_idpessoa IN NUMBER -- Registro de e-mail
                                   ,pr_retorno  OUT xmltype -- XML de retorno
                                   ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;

  BEGIN
    -- Rotina generica para retornar os dados da tabela via xml
    pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa                    --> Id de pessoa
                         ,pr_nmtabela => 'TBCADAST_PESSOA_EMAIL'        --> Nome da tabela
                         ,pr_dsnoprin => 'emails'                       --> Nó principal do xml
                         ,pr_dsnofilh => 'email'                        --> Nós filhos
						 ,pr_clausula => '(INSITUACAO = 1)'             --> Cláusula Where						 
                         ,pr_retorno  => pr_retorno                     --> XML de retorno
                         ,pr_dscritic => pr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_email: ' ||
                     SQLERRM;
  END;

  PROCEDURE pc_confirma_pessoa_email(pr_cdcooper       IN NUMBER -- Numero da cooperativa
                                    ,pr_idpessoa       IN NUMBER -- Registro de email
                                    ,pr_nrseq_email    IN NUMBER -- Numero sequecial do email
                                    ,pr_flsituacao     IN NUMBER -- Situacao: 1 - Ativo/ 2 - Rejeitado
                                    ,pr_idcanal        IN NUMBER -- Canal que efetuou a atualização
                                    ,pr_dscritic      OUT VARCHAR2) IS -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_confirma_pessoa_email
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CADA
    --  Autor    : Vitor S. Assanuma (GFT)
    --  Data     : Março/2019.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para confirmar o email da pessoa
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    -- Variaveis de erro
    vr_dscritic VARCHAR(500);
    vr_exc_erro EXCEPTION;

    vr_vlparamt VARCHAR(500);

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%rowtype;
    BEGIN  
      -- Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      IF (btch0001.cr_crapdat%NOTFOUND) THEN
        CLOSE btch0001.cr_crapdat;
        vr_dscritic := 'Erro ao buscar data na crapdat';
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;
          
      -- Busca o parâmetro cadastrado para verificar se é para inserir na crapalt
      pc_busca_parametro_tarifas(pr_cdcooper => pr_cdcooper
                                ,pr_cdpartar => 67
                                ,pr_vlparamt => vr_vlparamt
                                ,pr_dscritic => vr_dscritic);
      IF (TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;
      
      IF vr_vlparamt = '1' AND pr_flsituacao = 1 THEN
        -- Insere na crapalt
        pc_insere_crapalt(pr_idpessoa => pr_idpessoa
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_dsaltera => 'Confirmação do Email'
                         ,pr_dscritic => vr_dscritic);
        IF (TRIM(vr_dscritic) IS NOT NULL) THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
          
      -- Atualizar o canal TBCADAST_PESSOA_EMAIL e a data de revisão
      BEGIN
        UPDATE TBCADAST_PESSOA_EMAIL 
          SET idcanal    = pr_idcanal 
             ,insituacao = pr_flsituacao
             ,dtrevisao  = rw_crapdat.dtmvtolt
          WHERE idpessoa = pr_idpessoa
            AND nrseq_email = pr_nrseq_email;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_EMAIL: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na pc_confirma_pessoa_email: ' || SQLERRM;
  END pc_confirma_pessoa_email;  

  -- Rotina para cadastrar endereço
  PROCEDURE pc_cadast_pessoa_endereco(pr_idpessoa            IN NUMBER -- Identificador unico da pessoa (FK tbcadast_pessoa)
                                     ,pr_nrseq_endereco      IN OUT NUMBER -- Numero sequencial do endereco
                                     ,pr_tpendereco          IN NUMBER -- Tipo do endereco (9-Comercial/ 10-Residencial/ 12-Internet/ 13-Correspondencia/ 14-Complementar)
                                     ,pr_nmlogradouro        IN VARCHAR2 -- Nome do logradouro
                                     ,pr_nrlogradouro        IN NUMBER -- Numero do logradouro
                                     ,pr_dscomplemento       IN VARCHAR2 -- Complemento do logradouro
                                     ,pr_nmbairro            IN VARCHAR2 -- Nome do bairro
                                     ,pr_idcidade            IN NUMBER -- Identificador unido do registro de cidade (FK crapmun)
                                     ,pr_nrcep               IN NUMBER -- Numero do CEP
                                     ,pr_tpimovel            IN NUMBER -- Tipo de imovel (1-Quitado/ 2-Financiado/ 3-Alugado/ 4-Familiar/ 5-Cedido)
                                     ,pr_vldeclarado         IN NUMBER -- Valor declarado (aluguel ou valor do imovel)                                     ,pr_dtalteracao         IN DATE -- Data de alteracao do endereco
                                     ,pr_dtalteracao         IN DATE -- Data de alteracao do endereco
                                     ,pr_dtinicio_residencia IN DATE -- Data de inicio de residencia
                                     ,pr_tporigem_cadastro   IN NUMBER -- Indicador de origem da informacao (1-Cooperado/ 2-Cooperativa/ 3-Terceiros)
                                     ,pr_cdoperad_altera     IN VARCHAR2 -- Codigo do operador que realizou a ultima alteracao
                                     ,pr_dscritic            OUT VARCHAR2) IS
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_endereco tbcadast_pessoa_endereco%ROWTYPE;

  BEGIN

    vr_pessoa_endereco.idpessoa := pr_idpessoa;
    vr_pessoa_endereco.nrseq_endereco := pr_nrseq_endereco;
    vr_pessoa_endereco.tpendereco := pr_tpendereco;
    vr_pessoa_endereco.nmlogradouro := pr_nmlogradouro;
    vr_pessoa_endereco.nrlogradouro := pr_nrlogradouro;
    vr_pessoa_endereco.dscomplemento := pr_dscomplemento;
    vr_pessoa_endereco.nmbairro := pr_nmbairro;
    vr_pessoa_endereco.idcidade := pr_idcidade;
    vr_pessoa_endereco.nrcep := pr_nrcep;
    vr_pessoa_endereco.tpimovel := pr_tpimovel;
    vr_pessoa_endereco.vldeclarado := pr_vldeclarado;
    vr_pessoa_endereco.dtalteracao := pr_dtalteracao;
    vr_pessoa_endereco.dtinicio_residencia := pr_dtinicio_residencia;
    vr_pessoa_endereco.tporigem_cadastro := pr_tporigem_cadastro;
    vr_pessoa_endereco.cdoperad_altera := pr_cdoperad_altera;

    -- Chama rotina passando um registro
    cada0010.pc_cadast_pessoa_endereco(pr_pessoa_endereco => vr_pessoa_endereco
                                      ,pr_cdcritic        => vr_cdcritic
                                      ,pr_dscritic        => pr_dscritic);

    -- Retorna a sequencia do endereço
    pr_nrseq_endereco := vr_pessoa_endereco.nrseq_endereco;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_endereco: ' ||
                     SQLERRM;
  END;

  -- Rotina para excluir endereço
  PROCEDURE pc_exclui_pessoa_endereco(pr_idpessoa        IN NUMBER        -- Identificador de pessoa
																		 ,pr_nrseq_endereco  IN NUMBER        -- Nr. de sequência de endereço
																		 ,pr_cdoperad_altera IN VARCHAR2      -- Operador que esta efetuando a exclusao
																		 ,pr_cdcritic        OUT INTEGER      -- Codigo de erro
																		 ,pr_dscritic        OUT VARCHAR2) IS -- Retorno de Erro
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

    -- Chamar rotina para exclusão
    cada0010.pc_exclui_pessoa_endereco(pr_idpessoa => pr_idpessoa
		                                  ,pr_nrseq_endereco => pr_nrseq_endereco
																			,pr_cdoperad_altera => pr_cdoperad_altera
																			,pr_cdcritic => pr_cdcritic
																			,pr_dscritic => pr_dscritic);

		-- Se retornou alguma crítica
		IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_endereco: ' ||SQLERRM;
	END;

  -- Rotina para retorno de endereço
  PROCEDURE pc_retorna_pessoa_endereco(pr_idpessoa IN NUMBER -- Registro de endereço
                                      ,pr_retorno  OUT xmltype -- XML de retorno
                                      ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro
  BEGIN
    -- Rotina generica para retornar os dados da tabela via xml
    pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa                    --> Id de pessoa
                         ,pr_nmtabela => 'TBCADAST_PESSOA_ENDERECO'     --> Nome da tabela
                         ,pr_dsnoprin => 'enderecos'                    --> Nó principal do xml
                         ,pr_dsnofilh => 'endereco'                     --> Nós filhos
                         ,pr_clausula => '(NRCEP > 0)'                  --> Cláusula Where
                         ,pr_retorno  => pr_retorno                     --> XML de retorno
                         ,pr_dscritic => pr_dscritic);
  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_endereco: ' ||
                     SQLERRM;
  END;

  PROCEDURE pc_confirma_pessoa_endereco(pr_cdcooper       IN NUMBER -- Numero da cooperativa
                                       ,pr_idpessoa       IN NUMBER -- Registro de endereço
                                       ,pr_nrseq_endereco IN NUMBER -- Numero sequecial do endereço
                                       ,pr_flsituacao     IN NUMBER -- Situacao: 1 - Ativo/ 2 - Rejeitado
                                       ,pr_idcanal        IN NUMBER -- Canal que efetuou a atualização
                                       ,pr_dscritic      OUT VARCHAR2) IS -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_confirma_pessoa_endereco
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CADA
    --  Autor    : Vitor S. Assanuma (GFT)
    --  Data     : Março/2019.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para confirmar o endereço da pessoa
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    -- Variaveis de erro
    vr_dscritic VARCHAR(500);
    vr_exc_erro EXCEPTION;
    
    vr_vlparamt VARCHAR(500);

   -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%rowtype;
  BEGIN
    
    -- Leitura do calendário da cooperativa
    OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat into rw_crapdat;
    IF (btch0001.cr_crapdat%NOTFOUND) THEN
      CLOSE btch0001.cr_crapdat;
      vr_dscritic := 'Erro ao buscar data na crapdat';
      RAISE vr_exc_erro;
    END IF;
    CLOSE btch0001.cr_crapdat;
    
    -- Busca o parâmetro cadastrado para verificar se é para inserir na crapalt
    pc_busca_parametro_tarifas(pr_cdcooper => pr_cdcooper
                              ,pr_cdpartar => 66
                              ,pr_vlparamt => vr_vlparamt
                              ,pr_dscritic => vr_dscritic);
    IF (TRIM(vr_dscritic) IS NOT NULL) THEN
      RAISE vr_exc_erro;
    END IF;
      
    IF vr_vlparamt = '1' AND pr_flsituacao = 1 THEN
      -- Insere na crapalt
      pc_insere_crapalt(pr_idpessoa => pr_idpessoa
                       ,pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_dsaltera => 'Confirmação do Endereço'
                       ,pr_dscritic => vr_dscritic);
      IF (TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;
                     
    -- Atualizar o canal TBCADAST_PESSOA_ENDERECO e a data de revisão
    BEGIN
      UPDATE TBCADAST_PESSOA_ENDERECO 
        SET idcanal   = pr_idcanal 
           ,dtrevisao = rw_crapdat.dtmvtolt
           ,statusrevisao = pr_flsituacao
        WHERE idpessoa       = pr_idpessoa
          AND nrseq_endereco = pr_nrseq_endereco;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_ENDERECO: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Atualiza o numero de tentativas para 0
    UPDATE TBCADAST_PESSOA SET nrtentativa = 0 WHERE idpessoa = pr_idpessoa;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_confirma_pessoa_endereco: ' || SQLERRM;
  END pc_confirma_pessoa_endereco;
  
  PROCEDURE pc_cadast_pessoa_rend_compl(pr_idpessoa        IN NUMBER -- Identificador unico da pessoa (FK tbcadast_pessoa_fisica)
                                       ,pr_nrseq_renda     IN OUT NUMBER -- Numero sequencial do rendimento
                                       ,pr_tprenda         IN NUMBER -- Tipo de rendimento
                                       ,pr_vlrenda         IN NUMBER -- Valor do rendimento
                                       ,pr_tpfixo_variavel IN NUMBER -- Indicador de forma de renda (1-Fixo/ 2-Variavel)
                                       ,pr_cdoperad_altera IN VARCHAR2 -- Codigo do operador que realizou a ultima alteracao
                                       ,pr_dscritic        OUT VARCHAR2) IS
    -- Retorno de Erro
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_rendacompl tbcadast_pessoa_rendacompl%ROWTYPE;

  BEGIN

    vr_pessoa_rendacompl.idpessoa := pr_idpessoa;
    vr_pessoa_rendacompl.nrseq_renda := pr_nrseq_renda;
    vr_pessoa_rendacompl.tprenda := pr_tprenda;
    vr_pessoa_rendacompl.vlrenda := pr_vlrenda;
    vr_pessoa_rendacompl.tpfixo_variavel := pr_tpfixo_variavel;
    vr_pessoa_rendacompl.cdoperad_altera := pr_cdoperad_altera;

    -- Chama rotina passando um registro
    cada0010.pc_cadast_pessoa_renda_compl(pr_pessoa_renda_compl => vr_pessoa_rendacompl
                                         ,pr_cdcritic           => vr_cdcritic
                                         ,pr_dscritic           => pr_dscritic);

    -- Retorna a sequencia do endereço
    pr_nrseq_renda := vr_pessoa_rendacompl.nrseq_renda;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_rend_compl: ' ||
                     SQLERRM;
  END;

	-- Rotina para excluir renda complementar da pessoa fisica
  PROCEDURE pc_exclui_pessoa_renda_compl(pr_idpessoa        IN NUMBER         -- Identificador de pessoa
		                                    ,pr_nrseq_renda     IN NUMBER         -- Nr. de sequência de renda complementar
                                        ,pr_cdoperad_altera IN VARCHAR2       -- Operador que esta efetuando a exclusao
                                        ,pr_cdcritic        OUT INTEGER       -- Codigo de erro
                                        ,pr_dscritic        OUT VARCHAR2) IS  -- Retorno de Erro
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

	  -- Chamar rotina para exclusão
    cada0010.pc_exclui_pessoa_renda_compl(pr_idpessoa => pr_idpessoa
		                                     ,pr_nrseq_renda => pr_nrseq_renda
																				 ,pr_cdoperad_altera => pr_cdoperad_altera
																				 ,pr_cdcritic => pr_cdcritic
																				 ,pr_dscritic => pr_dscritic);
		-- Se retornou alguma crítica
		IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_renda_compl: ' ||SQLERRM;
	END;

  -- Rotina para retorno de rendimento
  PROCEDURE pc_retorna_pessoa_rend_compl(pr_idpessoa IN NUMBER -- Registro de reda complem.
                                        ,pr_retorno  OUT xmltype -- XML de retorno
                                        ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro
  BEGIN
    -- Rotina generica para retornar os dados da tabela via xml
    pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa                    --> Id de pessoa
                         ,pr_nmtabela => 'TBCADAST_PESSOA_RENDACOMPL'   --> Nome da tabela
                         ,pr_dsnoprin => 'rendas_compl'                 --> Nó principal do xml
                         ,pr_dsnofilh => 'renda_compl'                  --> Nós filhos
                         ,pr_retorno  => pr_retorno                     --> XML de retorno
                         ,pr_dscritic => pr_dscritic);
  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_rend_compl: ' ||
                     SQLERRM;
  END;

  -- Rotina para cadastrar renda
  PROCEDURE pc_cadast_pessoa_renda(pr_idpessoa             IN NUMBER -- Identificador unico da pessoa (FK tbcadast_pessoa_fisica)
                                  ,pr_nrseq_renda          IN OUT NUMBER -- Numero sequencial unico da renda para o cooperado
                                  ,pr_tpcontrato_trabalho  IN NUMBER -- Tipo de contrato de trabalho (1-Permanente/ 2-Temporario/ 3-Sem vinculo/ 4-Autonomo)
                                  ,pr_cdturno              IN NUMBER -- Codigo do Turno conforme (craptab.cdacesso = DSCDTURNOS)
                                  ,pr_cdnivel_cargo        IN NUMBER -- Codigo do nivel do cargo na empresa (FK gncdncg)
                                  ,pr_dtadmissao           IN DATE -- Data de admissao na empresa
                                  ,pr_cdocupacao           IN NUMBER -- Codigo de ocupacao (FK gncdocp)
                                  ,pr_nrcadastro           IN NUMBER -- Numero do cadastro na empresa
                                  ,pr_vlrenda              IN NUMBER -- Valor do rendimento
                                  ,pr_tpfixo_variavel      IN NUMBER -- Tipo de rendimento (0-Fixo/ 1-Variavel)
                                  ,pr_tpcomprov_renda      IN NUMBER -- Tipo de comprovacao do rendimento (0-Folha de Pagamento/ 1-Decore/ 2-IR/ 3-Extrato INSS/ 4-Termo de Conviccao de Renda)
                                  ,pr_idpessoa_fonte_renda IN NUMBER -- Identificador da pessoa fonte da renda
                                  ,pr_cdoperad_altera      IN VARCHAR2 -- Codigo do operador que realizou a ultima alteracao
                                  ,pr_dscritic             OUT VARCHAR2) IS
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_renda tbcadast_pessoa_renda%ROWTYPE;

  BEGIN

    vr_pessoa_renda.idpessoa := pr_idpessoa;
    vr_pessoa_renda.nrseq_renda := pr_nrseq_renda;
    vr_pessoa_renda.tpcontrato_trabalho := pr_tpcontrato_trabalho;
    vr_pessoa_renda.cdturno := pr_cdturno;
    vr_pessoa_renda.cdnivel_cargo := pr_cdnivel_cargo;
    vr_pessoa_renda.dtadmissao := pr_dtadmissao;
    vr_pessoa_renda.cdocupacao := pr_cdocupacao;
    vr_pessoa_renda.nrcadastro := pr_nrcadastro;
    vr_pessoa_renda.vlrenda := pr_vlrenda;
    vr_pessoa_renda.tpfixo_variavel := pr_tpfixo_variavel;
    vr_pessoa_renda.tpcomprov_renda := pr_tpcomprov_renda;
    vr_pessoa_renda.idpessoa_fonte_renda := pr_idpessoa_fonte_renda;
    vr_pessoa_renda.cdoperad_altera := pr_cdoperad_altera;

    -- Chama rotina passando um registro
    cada0010.pc_cadast_pessoa_renda(pr_pessoa_renda => vr_pessoa_renda
                                   ,pr_cdcritic     => vr_cdcritic
                                   ,pr_dscritic     => pr_dscritic);

    -- Retorna a sequencia da renda
    pr_nrseq_renda := vr_pessoa_renda.nrseq_renda;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_renda: ' ||
                     SQLERRM;
  END;

  -- Rotina para excluir renda da pessoa fisica
  PROCEDURE pc_exclui_pessoa_renda(pr_idpessoa        IN NUMBER            -- Identificador de pessoa
		                              ,pr_nrseq_renda     IN NUMBER            -- Nr. de sequência de renda
                                  ,pr_cdoperad_altera IN VARCHAR2          -- Operador que esta efetuando a exclusao
                                  ,pr_cdcritic        OUT INTEGER          -- Codigo de erro
                                  ,pr_dscritic        OUT VARCHAR2) IS     -- Retorno de Erro
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

    -- Chamar rotina para exclusão
		cada0010.pc_exclui_pessoa_renda(pr_idpessoa => pr_idpessoa
		                               ,pr_nrseq_renda => pr_nrseq_renda
																	 ,pr_cdoperad_altera => pr_cdoperad_altera
																	 ,pr_cdcritic => pr_cdcritic
																	 ,pr_dscritic => pr_dscritic);

		-- Se retornou erro
		IF pr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_renda: ' ||SQLERRM;
	END;

  -- Rotina para retorno de renda
  PROCEDURE pc_retorna_pessoa_renda(pr_idpessoa IN NUMBER -- Registro de renda
                                   ,pr_retorno  OUT xmltype -- XML de retorno
                                   ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro
  BEGIN
    -- Rotina generica para retornar os dados da tabela via xml
    pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa              --> Id de pessoa
                         ,pr_nmtabela => 'TBCADAST_PESSOA_RENDA'  --> Nome da tabela
                         ,pr_dsnoprin => 'rendas'                 --> Nó principal do xml
                         ,pr_dsnofilh => 'renda'                  --> Nós filhos
                         ,pr_retorno  => pr_retorno               --> XML de retorno
                         ,pr_dscritic => pr_dscritic);
  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_renda: ' ||
                     SQLERRM;
  END;

  PROCEDURE pc_confirma_pessoa_renda(pr_cdcooper       IN NUMBER -- Numero da cooperativa
                                    ,pr_idpessoa       IN NUMBER -- Registro de renda
                                    ,pr_nrseq_renda    IN NUMBER -- Numero sequecial do renda
                                    ,pr_flsituacao     IN NUMBER -- Situacao: 1 - Ativo/ 2 - Rejeitado
                                    ,pr_idcanal        IN NUMBER -- Canal que efetuou a atualização
                                    ,pr_dscritic      OUT VARCHAR2) IS -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_confirma_pessoa_renda
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CADA
    --  Autor    : Vitor S. Assanuma (GFT)
    --  Data     : Março/2019.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para confirmar o renda da pessoa
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    -- Variaveis de erro
    vr_dscritic VARCHAR(500);
    vr_exc_erro EXCEPTION;

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%rowtype;
    BEGIN  

      -- Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      IF (btch0001.cr_crapdat%NOTFOUND) THEN
        CLOSE btch0001.cr_crapdat;
        vr_dscritic := 'Erro ao buscar data na crapdat';
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;
          
      IF pr_flsituacao = 1 THEN
      -- Insere na crapalt
      pc_insere_crapalt(pr_idpessoa => pr_idpessoa
                       ,pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_dsaltera => 'Confirmação da Renda'
                       ,pr_dscritic => vr_dscritic);
      IF (TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;
      END IF;
                
      -- Atualizar o canal TBCADAST_PESSOA_RENDA e a data de revisão
      BEGIN
        UPDATE TBCADAST_PESSOA_RENDA 
          SET idcanal_renda    = pr_idcanal 
             ,dtrevisao_renda  = rw_crapdat.dtmvtolt
             ,statusrevisao_renda = pr_flsituacao
          WHERE idpessoa = pr_idpessoa
            AND nrseq_renda = pr_nrseq_renda;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_RENDA: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na pc_confirma_pessoa_renda: ' || SQLERRM;
  END pc_confirma_pessoa_renda;

  PROCEDURE pc_confirma_pessoa_empresa(pr_cdcooper       IN NUMBER -- Numero da cooperativa
                                      ,pr_idpessoa       IN NUMBER -- Registro de empresa
                                      ,pr_nrseq_empresa IN NUMBER -- Numero sequecial do empresa
                                      ,pr_flsituacao     IN NUMBER -- Situacao: 1 - Ativo/ 2 - Rejeitado
                                      ,pr_idcanal        IN NUMBER -- Canal que efetuou a atualização
                                      ,pr_dscritic      OUT VARCHAR2) IS -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_confirma_pessoa_empresa
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CADA
    --  Autor    : Vitor S. Assanuma (GFT)
    --  Data     : Março/2019.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para confirmar o empresa da pessoa
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    -- Variaveis de erro
    vr_dscritic VARCHAR(500);
    vr_exc_erro EXCEPTION;

    vr_vlparamt VARCHAR(500);

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%rowtype;
    BEGIN  

      -- Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      IF (btch0001.cr_crapdat%NOTFOUND) THEN
        CLOSE btch0001.cr_crapdat;
        vr_dscritic := 'Erro ao buscar data na crapdat';
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;
                
      -- Busca o parâmetro cadastrado para verificar se é para inserir na crapalt
      pc_busca_parametro_tarifas(pr_cdcooper => pr_cdcooper
                                ,pr_cdpartar => 67
                                ,pr_vlparamt => vr_vlparamt
                                ,pr_dscritic => vr_dscritic);
      IF (TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;
      
      IF vr_vlparamt = '1' AND pr_flsituacao = 1 THEN
        -- Insere na crapalt
        pc_insere_crapalt(pr_idpessoa => pr_idpessoa
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_dsaltera => 'Confirmação da Empresa'
                         ,pr_dscritic => vr_dscritic);
        IF (TRIM(vr_dscritic) IS NOT NULL) THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
                
      -- Atualizar o canal TBCADAST_PESSOA_RENDA e a data de revisão
      BEGIN
        UPDATE TBCADAST_PESSOA_RENDA 
          SET idcanal_empresa    = pr_idcanal 
             ,dtrevisao_empresa  = rw_crapdat.dtmvtolt
             ,statusrevisao_empresa = pr_flsituacao
          WHERE idpessoa = pr_idpessoa
            AND nrseq_renda = pr_nrseq_empresa;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_RENDA com dados da EMPRESA: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na pc_confirma_pessoa_empresa: ' || SQLERRM;
  END pc_confirma_pessoa_empresa;

  -- Rotina para cadastrar relacionamento
  PROCEDURE pc_cadast_pessoa_relacao(pr_idpessoa         IN NUMBER -- Identificador unico da pessoa (FK tbcadast_pessoa_fisica)
                                    ,pr_nrseq_relacao    IN OUT NUMBER -- Numero sequencial do dependente
                                    ,pr_idpessoa_relacao IN NUMBER -- Numero do CPF do dependente
                                    ,pr_tprelacao        IN NUMBER -- Tipo de relacionamento (1-Conjuge/ 3-Pai / 4-Mae)
                                    ,pr_cdoperad_altera  IN VARCHAR2
                                    ,pr_dscritic         OUT VARCHAR2) IS
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_relacao tbcadast_pessoa_relacao%ROWTYPE;

  BEGIN

    vr_pessoa_relacao.idpessoa := pr_idpessoa;
    vr_pessoa_relacao.nrseq_relacao := pr_nrseq_relacao;
    vr_pessoa_relacao.idpessoa_relacao := pr_idpessoa_relacao;
    vr_pessoa_relacao.tprelacao := pr_tprelacao;
    vr_pessoa_relacao.cdoperad_altera := pr_cdoperad_altera;

    -- Chama rotina passando um registro
    cada0010.pc_cadast_pessoa_relacao(pr_pessoa_relacao => vr_pessoa_relacao
                                     ,pr_cdcritic       => vr_cdcritic
                                     ,pr_dscritic       => pr_dscritic);

    -- Retorna a sequencia da relação
    pr_nrseq_relacao := vr_pessoa_relacao.nrseq_relacao;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_relacao: ' ||
                     SQLERRM;
  END;

  -- Rotina para excluir relacionamento
  PROCEDURE pc_exclui_pessoa_relacao(pr_idpessoa        IN NUMBER         -- Identificador de pessoa
															      ,pr_nrseq_relacao   IN NUMBER         -- Nr. de sequência de relacionamento
																		,pr_cdoperad_altera IN VARCHAR2       -- Operador que esta efetuando a exclusao
																		,pr_cdcritic        OUT INTEGER                                   -- Codigo de erro
																		,pr_dscritic        OUT VARCHAR2) IS                              -- Retorno de Erro
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

	  -- Chamar rotina para exclusão
    cada0010.pc_exclui_pessoa_relacao(pr_idpessoa => pr_idpessoa
		                                 ,pr_nrseq_relacao => pr_nrseq_relacao
																		 ,pr_cdoperad_altera => pr_cdoperad_altera
																		 ,pr_cdcritic => pr_cdcritic
																		 ,pr_dscritic => pr_dscritic);

		-- Se retornou alguma crítica
		IF vr_cdcritic > 0 OR TRIM(vr_dscritic)	IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_relacao: ' ||SQLERRM;
	END;

  -- Rotina para retorno de relacionamento
  PROCEDURE pc_retorna_pessoa_relacao(pr_idpessoa IN NUMBER -- Registro de relacionamento
                                     ,pr_retorno  OUT xmltype -- XML de retorno
                                     ,pr_dscritic OUT VARCHAR2) IS -- Retorno de Erro
  BEGIN
    -- Rotina generica para retornar os dados da tabela via xml
    pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa                --> Id de pessoa
                         ,pr_nmtabela => 'TBCADAST_PESSOA_RELACAO'  --> Nome da tabela
                         ,pr_dsnoprin => 'relacoes'                 --> Nó principal do xml
                         ,pr_dsnofilh => 'relacao'                  --> Nós filhos
                         ,pr_retorno  => pr_retorno                 --> XML de retorno
                         ,pr_dscritic => pr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_relacao: ' ||
                     SQLERRM;
  END;

  -- Rotina para retorno de CEP
PROCEDURE pc_retorna_cep(pr_cdcep              IN NUMBER -- Registro de cep
                          ,
                           pr_nmrua              IN VARCHAR2 -- Nome da rua
                          ,
                           pr_nmbairro           IN VARCHAR2 -- Nome do bairro
                          ,
                           pr_nmcidade           IN VARCHAR2 -- Nome da cidade
                          ,
                           pr_retorno            OUT xmltype -- XML de retorno
                          ,
                           pr_dscritic           OUT VARCHAR2 -- Retorno de Erro
                          ,
                           pr_linha_inicio_busca in number default 1,
                           pr_qtd_registros      in number default 10) IS
  
    -- Exceções
    vr_exc_erro EXCEPTION;
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    -- Variaveis gerais
    vr_xml xmltype; -- XML que sera enviado
  
    -- Variavel para a geracao do XML
    vr_clob     CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
  
    -- Buscar endereço pelo código do cep
    CURSOR cr_cdcep IS
      select *
        from (select /*+ FIRST_ROWS(n) */
               topn.*, ROWNUM rnum
                from (SELECT nrceplog,
                             nmextlog,
                             nmreslog,
                             dscmplog,
                             dstiplog,
                             nmextbai,
                             nmresbai,
                             nmextcid,
                             nmrescid,
                             cduflogr,
                             ROWNUM - 1 seq
                        FROM crapdne
                       WHERE crapdne.nrceplog = pr_cdcep
                       order by nrceplog, ROWID) topn
               where ROWNUM <=
                     (pr_linha_inicio_busca - 1) + pr_qtd_registros) --linha final
       where rnum > (pr_linha_inicio_busca - 1); -- linha inicial
  
    -- Buscar endereço pela rua, bairo e cidade
    CURSOR cr_dscep IS
      select *
        from (select /*+ FIRST_ROWS(n) */
               topn.*, ROWNUM rnum
                from (SELECT nrceplog,
             nmextlog,
             nmreslog,
             dscmplog,
             dstiplog,
             nmextbai,
             nmresbai,
             nmextcid,
             nmrescid,
             cduflogr,
             ROWNUM - 1 seq
        FROM crapdne
       WHERE upper(crapdne.nmextlog) LIKE upper('%' || pr_nmrua || '%')
         AND upper(crapdne.nmextbai) LIKE upper('%' || pr_nmbairro || '%')
         AND upper(crapdne.nmextcid) LIKE upper('%' || pr_nmcidade || '%')
                       order by nrceplog, ROWID) topn
               where ROWNUM <=
                     (pr_linha_inicio_busca - 1) + pr_qtd_registros) --linha final
       where rnum > (pr_linha_inicio_busca - 1); -- linha inicial
  
  BEGIN
  
    -- Monta documento XML
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
  
    -- Criar cabeçalho do XML e tag de abertura
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><CEPs>');
  
    -- Se informou código do CEP
    IF pr_cdcep > 0 THEN
      -- Loop sob os CEPs
      FOR rw_cdcep IN cr_cdcep LOOP
      
        -- gera o detalhe da relacao
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob,
                                pr_texto_completo => vr_xml_temp,
                                pr_texto_novo     => '<CEP>' || chr(13) ||
                                                     '  <nrceplog>' ||
                                                     rw_cdcep.nrceplog ||
                                                     '</nrceplog>' ||
                                                     chr(13) ||
                                                     '  <nmextlog>' ||
                                                     rw_cdcep.nmextlog ||
                                                     '</nmextlog>' ||
                                                     chr(13) ||
                                                     '  <nmreslog>' ||
                                                     rw_cdcep.nmreslog ||
                                                     '</nmreslog>' ||
                                                     chr(13) ||
                                                     '  <dscmplog>' ||
                                                     rw_cdcep.dscmplog ||
                                                     '</dscmplog>' ||
                                                     chr(13) ||
                                                     '  <dstiplog>' ||
                                                     rw_cdcep.dstiplog ||
                                                     '</dstiplog>' ||
                                                     chr(13) ||
                                                     '  <nmextbai>' ||
                                                     rw_cdcep.nmextbai ||
                                                     '</nmextbai>' ||
                                                     chr(13) ||
                                                     '  <nmresbai>' ||
                                                     rw_cdcep.nmresbai ||
                                                     '</nmresbai>' ||
                                                     chr(13) ||
                                                     '  <nmextcid>' ||
                                                     rw_cdcep.nmextcid ||
                                                     '</nmextcid>' ||
                                                     chr(13) ||
                                                     '  <nmrescid>' ||
                                                     rw_cdcep.nmrescid ||
                                                     '</nmrescid>' ||
                                                     chr(13) ||
                                                     '  <cduflogr>' ||
                                                     rw_cdcep.cduflogr ||
                                                     '</cduflogr>' ||
                                                     chr(13) || '</CEP>' ||
                                                     chr(13));
      
      END LOOP;
    
    ELSE
    
      -- Se preencheu algum dos parametros
      IF TRIM(pr_nmrua) IS NOT NULL OR TRIM(pr_nmbairro) IS NOT NULL OR
         TRIM(pr_nmcidade) IS NOT NULL THEN
      
        -- Efetuar busca sob os CEPs
        FOR rw_dscep IN cr_dscep LOOP
          -- gera o detalhe da relacao
          GENE0002.pc_escreve_xml(pr_xml            => vr_clob,
                                  pr_texto_completo => vr_xml_temp,
                                  pr_texto_novo     => '<CEP>' || chr(13) ||
                                                       '  <nrceplog>' ||
                                                       rw_dscep.nrceplog ||
                                                       '</nrceplog>' ||
                                                       chr(13) ||
                                                       '  <nmextlog>' ||
                                                       rw_dscep.nmextlog ||
                                                       '</nmextlog>' ||
                                                       chr(13) ||
                                                       '  <nmreslog>' ||
                                                       rw_dscep.nmreslog ||
                                                       '</nmreslog>' ||
                                                       chr(13) ||
                                                       '  <dscmplog>' ||
                                                       rw_dscep.dscmplog ||
                                                       '</dscmplog>' ||
                                                       chr(13) ||
                                                       '  <dstiplog>' ||
                                                       rw_dscep.dstiplog ||
                                                       '</dstiplog>' ||
                                                       chr(13) ||
                                                       '  <nmextbai>' ||
                                                       rw_dscep.nmextbai ||
                                                       '</nmextbai>' ||
                                                       chr(13) ||
                                                       '  <nmresbai>' ||
                                                       rw_dscep.nmresbai ||
                                                       '</nmresbai>' ||
                                                       chr(13) ||
                                                       '  <nmextcid>' ||
                                                       rw_dscep.nmextcid ||
                                                       '</nmextcid>' ||
                                                       chr(13) ||
                                                       '  <nmrescid>' ||
                                                       rw_dscep.nmrescid ||
                                                       '</nmrescid>' ||
                                                       chr(13) ||
                                                       '  <cduflogr>' ||
                                                       rw_dscep.cduflogr ||
                                                       '</cduflogr>' ||
                                                       chr(13) || '</CEP>' ||
                                                       chr(13));
        END LOOP;
      
    ELSE
        -- Senão gerar crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Parâmetros inválidos.';
        -- Levantar exceção
        RAISE vr_exc_erro;
      END IF;
    
    END IF;
  
    -- Finaliza o XML
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob,
                            pr_texto_completo => vr_xml_temp,
                            pr_texto_novo     => '</CEPs>',
                            pr_fecha_xml      => TRUE);
  
    -- Converte para XML
    pr_retorno := xmltype(vr_clob);
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se crítica possui código
      IF (vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL) THEN
        -- Buscar código de crítica
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Retornar descrição do erro
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_cep: ' || SQLERRM;
  END;



  -- Rotina para verificar se existe restricoes
  PROCEDURE pc_retorna_restricoes(pr_nrcpfcgc     IN NUMBER -- Numero do CPF / CNPJ da pessoa
                                 ,pr_dsrestricao OUT VARCHAR2 -- Descricao da restricao, caso houver
                                 ,pr_tprestricao OUT NUMBER   -- Tipo de restrição
                                                              --   0=Sem restrições
                                                              --   1=Com restrições - Interrompe o cadastro
                                                              --   2=Com restrições - Não interrompe o cadstro, gera alerta área segurança
                                 ,pr_dscritic    OUT VARCHAR2) IS
    --> Buscar Atividades proibidas
    CURSOR cr_atividade_proibida IS
      SELECT c.TPBLOQUEIO
            ,c.DSMOTIVO
        FROM TBCADAST_PESSOA          a
            ,TBCADAST_PESSOA_JURIDICA b
            ,TBCC_CNAE_BLOQUEADO      c
       WHERE A.NRCPFCGC = pr_nrcpfcgc
         AND b.IDPESSOA = a.IDPESSOA
         AND c.CDCNAE   = b.CDCNAE;
      rw_atividade_proibida cr_atividade_proibida%ROWTYPE;

    --> Buscar Restritivos de segurança da cooperativa - CPF/CNPJ
    CURSOR cr_restricao_cpf_cnpj IS
      SELECT a.DSMOTIVO
        FROM TBCC_CNPJCPF_BLOQUEADO a
       WHERE A.NRCPFCGC = pr_nrcpfcgc;
      rw_restricao_cpf_cnpj cr_restricao_cpf_cnpj%ROWTYPE;

    --> Buscar Restritivos de segurança da cooperativa - Documento
    CURSOR cr_restricao_documento IS
      SELECT DSJUSINC
        FROM CRAPCRT a
       WHERE a.Nrcpfcgc = pr_nrcpfcgc
         AND a.CDSITREG = 1;
      rw_restricao_documento cr_restricao_documento%ROWTYPE;

  BEGIN
    pr_dsrestricao := NULL;
    pr_tprestricao := NULL;
    pr_dscritic    := NULL;

    -- Buscar Atividades proibidas
    OPEN cr_atividade_proibida;
    FETCH cr_atividade_proibida INTO rw_atividade_proibida;

    -- Fechar cursor
    CLOSE cr_atividade_proibida;

    -- Tratar a Atividade Proibida
    IF nvl(rw_atividade_proibida.TPBLOQUEIO,99) = 1 THEN
      pr_dsrestricao := rw_atividade_proibida.DSMOTIVO;
      pr_tprestricao := 1;
    ELSIF nvl(rw_atividade_proibida.TPBLOQUEIO,99) = 0 THEN
      pr_dsrestricao := rw_atividade_proibida.DSMOTIVO;
      pr_tprestricao := 2;
    END IF;

    IF pr_tprestricao IS NULL THEN
      -- Buscar Restritivos de segurança da cooperativa - CPF/CNPJ
      OPEN cr_restricao_cpf_cnpj;
      FETCH cr_restricao_cpf_cnpj INTO rw_restricao_cpf_cnpj;

      -- Se não encontrou Atividades proibidas
      IF cr_restricao_cpf_cnpj%NOTFOUND THEN
        -- Fechar cursor
        rw_restricao_cpf_cnpj.DSMOTIVO := NULL;
      END IF;
      -- Fechar cursor
      CLOSE cr_restricao_cpf_cnpj;

      IF rw_restricao_cpf_cnpj.DSMOTIVO IS NOT NULL THEN
        pr_dsrestricao := rw_restricao_cpf_cnpj.DSMOTIVO;
        pr_tprestricao := 1;
      END IF;
    END IF;

    IF pr_tprestricao IS NULL THEN
      -- Buscar Restritivos de segurança da cooperativa - Documento
      OPEN cr_restricao_documento;
      FETCH cr_restricao_documento INTO rw_restricao_documento;

      -- Se não encontrou Atividades proibidas
      IF cr_restricao_documento%NOTFOUND THEN
        -- Fechar cursor
        rw_restricao_documento.DSJUSINC := NULL;
      END IF;
      -- Fechar cursor
      CLOSE cr_restricao_documento;

      IF rw_restricao_documento.DSJUSINC IS NOT NULL THEN
        pr_dsrestricao := rw_restricao_documento.DSJUSINC;
        pr_tprestricao := 2;
      END IF;
    END IF;

    pr_tprestricao := nvl(pr_tprestricao,0);
  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_restricoes: ' || SQLERRM;
  END pc_retorna_restricoes;

  -- Rotina para cadastrar pessoa dependente
  PROCEDURE pc_cadast_pessoa_fisica_dep( pr_idpessoa	            IN NUMBER    --> Identificador unico da pessoa
                                        ,pr_nrseq_dependente  IN OUT NUMBER    --> Numero sequencial de dependente
                                        ,pr_idpessoa_dependente   IN NUMBER    --> Identificador unico da pessoa dependente
                                        ,pr_tpdependente          IN NUMBER    --> Tipo de pessoa dependente(dominio: craptab cdacesso = dstpdepend )
                                        ,pr_cdoperad_altera       IN VARCHAR2  --> Codigo do operador que realizou a ultima alteracao
                                        ,pr_dscritic             OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_fisica_dep
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para cadastrar pessoa dependente
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_fisica_dep tbcadast_pessoa_fisica_dep%ROWTYPE;

  BEGIN

    vr_pessoa_fisica_dep.idpessoa            := pr_idpessoa;
    vr_pessoa_fisica_dep.nrseq_dependente    := pr_nrseq_dependente;
    vr_pessoa_fisica_dep.idpessoa_dependente := pr_idpessoa_dependente;
    vr_pessoa_fisica_dep.tpdependente        := pr_tpdependente;
    vr_pessoa_fisica_dep.cdoperad_altera     := pr_cdoperad_altera;

    -- Rotina para Cadastro de pessoa dependente
    cada0010.pc_cadast_pessoa_fisica_dep( pr_pessoa_fisica_dep => vr_pessoa_fisica_dep
                                        , pr_cdcritic          => vr_cdcritic
                                        , pr_dscritic          => pr_dscritic);

    -- Retorna a sequencia da
    pr_nrseq_dependente := vr_pessoa_fisica_dep.nrseq_dependente;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_fisica_dep: ' ||
                     SQLERRM;
  END pc_cadast_pessoa_fisica_dep;

  -- Rotina para excluir pessoa dependente
  PROCEDURE pc_exclui_pessoa_fisica_dep( pr_idpessoa         IN NUMBER          -- Identificador de pessoa
                                        ,pr_nrseq_dependente IN NUMBER          -- Nr. de sequência
                                        ,pr_cdoperad_altera  IN VARCHAR2        -- Operador que esta efetuando a exclusao
                                        ,pr_cdcritic         OUT INTEGER        -- Codigo de erro
                                        ,pr_dscritic         OUT VARCHAR2) IS   -- Retorno de Erro
  /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_fisica_dep
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para excluir pessoa dependente
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <------------------
    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

    -- Chamar rotina para exclusão
		cada0010.pc_exclui_pessoa_fisica_dep( pr_idpessoa         => pr_idpessoa
                                         ,pr_nrseq_dependente => pr_nrseq_dependente
                                         ,pr_cdoperad_altera  => pr_cdoperad_altera
                                         ,pr_cdcritic         => pr_cdcritic
                                         ,pr_dscritic         => pr_dscritic);

		-- Se retornou erro
		IF pr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_fisica_dep: ' ||SQLERRM;
	END pc_exclui_pessoa_fisica_dep;

  -- Rotina para retornar dados de pessoa dependente
  PROCEDURE pc_retorna_pessoa_fisica_dep( pr_idpessoa IN NUMBER -- Registro de bens
                                         ,pr_retorno  OUT xmltype -- XML de retorno
                                         ,pr_dscritic             OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_retorna_pessoa_fisica_dep
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para retornar dados de pessoa dependente
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;

  BEGIN
    -- Rotina generica para retornar os dados da tabela via xml
    pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa                  --> Id de pessoa
                         ,pr_nmtabela => 'TBCADAST_PESSOA_FISICA_DEP' --> Nome da tabela
                         ,pr_dsnoprin => 'dependentes'                --> Nó principal do xml
                         ,pr_dsnofilh => 'dependente'                 --> Nós filhos
                         ,pr_retorno  => pr_retorno                   --> XML de retorno
                         ,pr_dscritic => pr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_fisica_dep: ' ||
                     SQLERRM;
  END pc_retorna_pessoa_fisica_dep;

  -- Rotina para Cadastrar de resposansavel legal de pessoa de fisica
  PROCEDURE pc_cadast_pessoa_fisica_resp( pr_idpessoa	            IN NUMBER        --> Identificador unico da pessoa
                                         ,pr_nrseq_resp_legal IN OUT NUMBER        --> Numero sequencial de responsavel legal
                                         ,pr_idpessoa_resp_legal  IN NUMBER        --> Identificador unico da pessoa responsavel legal
                                         ,pr_cdrelacionamento     IN NUMBER        --> Codigo de relacao do responsavel legal com o cooperado
                                         ,pr_cdoperad_altera      IN VARCHAR2      --> Codigo do operador que realizou a ultima alteracao
                                         ,pr_dscritic             OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_fisica_resp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Cadastrar de resposansavel legal de pessoa de fisica
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_fisica_resp tbcadast_pessoa_fisica_resp%ROWTYPE;

  BEGIN

    vr_pessoa_fisica_resp.idpessoa	           := pr_idpessoa;
    vr_pessoa_fisica_resp.nrseq_resp_legal    := pr_nrseq_resp_legal;
    vr_pessoa_fisica_resp.idpessoa_resp_legal := pr_idpessoa_resp_legal;
    vr_pessoa_fisica_resp.cdrelacionamento    := pr_cdrelacionamento;
    vr_pessoa_fisica_resp.cdoperad_altera     := pr_cdoperad_altera;

    -- Rotina para Cadastro de resposansavel legal de pessoa de fisica
    cada0010.pc_cadast_pessoa_fisica_resp(pr_pessoa_fisica_resp => vr_pessoa_fisica_resp
                                        , pr_cdcritic           => vr_cdcritic
                                        , pr_dscritic           => pr_dscritic);

    -- Retorna a sequencia
    pr_nrseq_resp_legal := vr_pessoa_fisica_resp.nrseq_resp_legal;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_fisica_resp: ' ||
                     SQLERRM;
  END pc_cadast_pessoa_fisica_resp;

  -- Rotina para excluir pessoa responsavel legal
  PROCEDURE pc_exclui_pessoa_fisica_resp ( pr_idpessoa         IN NUMBER          -- Identificador de pessoa
                                          ,pr_nrseq_resp_legal IN NUMBER          -- Nr. de sequência
                                          ,pr_cdoperad_altera  IN VARCHAR2        -- Operador que esta efetuando a exclusao
                                          ,pr_cdcritic         OUT INTEGER                                          -- Codigo de erro
                                          ,pr_dscritic         OUT VARCHAR2) IS                                     -- Retorno de Erro
  /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_fisica_resp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para excluir pessoa responsavel legal
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <------------------
    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

    -- Chamar rotina para exclusão
		cada0010.pc_exclui_pessoa_fisica_resp ( pr_idpessoa         => pr_idpessoa
                                           ,pr_nrseq_resp_legal => pr_nrseq_resp_legal
                                           ,pr_cdoperad_altera  => pr_cdoperad_altera
                                           ,pr_cdcritic         => pr_cdcritic
                                           ,pr_dscritic         => pr_dscritic);

		-- Se retornou erro
		IF pr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_fisica_resp: ' ||SQLERRM;
	END pc_exclui_pessoa_fisica_resp;

  -- Rotina para retorna resposansavel legal de pessoa de fisica
  PROCEDURE pc_retorna_pessoa_fisica_resp( pr_idpessoa IN NUMBER -- Registro de bens
                                          ,pr_retorno  OUT xmltype -- XML de retorno
                                          ,pr_dscritic             OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_retorna_pessoa_fisica_resp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para retorna resposansavel legal de pessoa de fisica
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;

  BEGIN
    -- Rotina generica para retornar os dados da tabela via xml
    pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa                   --> Id de pessoa
                         ,pr_nmtabela => 'TBCADAST_PESSOA_FISICA_RESP' --> Nome da tabela
                         ,pr_dsnoprin => 'responsaveis'                --> Nó principal do xml
                         ,pr_dsnofilh => 'responsavel'                 --> Nós filhos
                         ,pr_retorno  => pr_retorno                    --> XML de retorno
                         ,pr_dscritic => pr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_fisica_resp: ' ||
                     SQLERRM;
  END pc_retorna_pessoa_fisica_resp;

   -- Rotina para Cadastrar de pessoa de referencia
   PROCEDURE pc_cadast_pessoa_referencia( pr_idpessoa	            IN NUMBER    --> Identificador unico da pessoa
                                         ,pr_nrseq_referencia IN OUT NUMBER    --> Numero sequencial de referencia
                                         ,pr_idpessoa_referencia  IN NUMBER    --> Identificador unico da pessoa de referencia
                                         ,pr_cdoperad_altera      IN VARCHAR2  --> Codigo do operador que realizou a ultima alteracao
                                         ,pr_dscritic             OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_referencia
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Cadastrar de pessoa de referencia
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_referencia tbcadast_pessoa_referencia%ROWTYPE;

  BEGIN

    vr_pessoa_referencia.idpessoa	           := pr_idpessoa;
    vr_pessoa_referencia.nrseq_referencia    := pr_nrseq_referencia;
    vr_pessoa_referencia.idpessoa_referencia := pr_idpessoa_referencia;
    vr_pessoa_referencia.cdoperad_altera     := pr_cdoperad_altera;

    -- Rotina para Cadastrar de pessoa de referencia
    cada0010.pc_cadast_pessoa_referencia (pr_pessoa_referencia => vr_pessoa_referencia
                                        , pr_cdcritic          => vr_cdcritic
                                        , pr_dscritic          => pr_dscritic);

    -- Retorna a sequencia
    pr_nrseq_referencia := vr_pessoa_referencia.nrseq_referencia;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_referencia: ' ||
                     SQLERRM;
  END pc_cadast_pessoa_referencia;

  -- Rotina para excluir pessoa referencia
  PROCEDURE pc_exclui_pessoa_referencia (pr_idpessoa         IN NUMBER    -- Identificador de pessoa
                                        ,pr_nrseq_referencia IN NUMBER    -- Nr. de sequência
                                        ,pr_cdoperad_altera  IN VARCHAR2  -- Operador que esta efetuando a exclusao
                                        ,pr_cdcritic         OUT INTEGER                                          -- Codigo de erro
                                        ,pr_dscritic         OUT VARCHAR2) IS                                     -- Retorno de Erro
  /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_referencia
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para excluir pessoa pessoa referencia
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <------------------
    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

    -- Chamar rotina para exclusão
		cada0010.pc_exclui_pessoa_referencia ( pr_idpessoa         => pr_idpessoa
                                          ,pr_nrseq_referencia => pr_nrseq_referencia
                                          ,pr_cdoperad_altera  => pr_cdoperad_altera
                                          ,pr_cdcritic         => pr_cdcritic
                                          ,pr_dscritic         => pr_dscritic);

		-- Se retornou erro
		IF pr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_referencia: ' ||SQLERRM;
	END pc_exclui_pessoa_referencia;

  -- Rotina para retornar de pessoa de referencia
  PROCEDURE pc_retorna_pessoa_referencia ( pr_idpessoa IN NUMBER   -- Registro de bens
                                          ,pr_retorno  OUT xmltype -- XML de retorno
                                          ,pr_dscritic             OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_retorna_pessoa_referencia
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para retornar de pessoa de referencia
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;

  BEGIN
    -- Rotina generica para retornar os dados da tabela via xml
    pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa                   --> Id de pessoa
                         ,pr_nmtabela => 'TBCADAST_PESSOA_REFERENCIA' --> Nome da tabela
                         ,pr_dsnoprin => 'referencias'                --> Nó principal do xml
                         ,pr_dsnofilh => 'referencia'                 --> Nós filhos
                         ,pr_retorno  => pr_retorno                    --> XML de retorno
                         ,pr_dscritic => pr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_referencia: ' ||
                     SQLERRM;
  END pc_retorna_pessoa_referencia;

  -- Rotina para Cadastrar dados financeiros de pessoa juridica em outrao bancos.
  PROCEDURE pc_cadast_pessoa_juridica_bco ( pr_idpessoa	        IN NUMBER       --> identificador unico da pessoa
                                           ,pr_nrseq_banco  IN OUT NUMBER       --> numero sequencial de movimentação em outros bancos
                                           ,pr_cdbanco          IN NUMBER       --> codigo do banco
                                           ,pr_dsoperacao       IN VARCHAR2     --> descrição operacao realizada com outro banco
                                           ,pr_vloperacao       IN NUMBER       --> valor da operacao financeira
                                           ,pr_dsgarantia       IN VARCHAR2     --> garantia dada para a realizacao da operacao financeira
                                           ,pr_dtvencimento     IN DATE         --> data vencimento da operacao financeira, caso vazio refere-se a varios vencimentos
                                           ,pr_cdoperad_altera  IN VARCHAR2     --> codigo do operador que realizou a ultima alteracao
                                           ,pr_dscritic        OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_juridica_bco
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Cadastrar de resposansavel legal de pessoa de fisica
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_juridica_bco tbcadast_pessoa_juridica_bco%ROWTYPE;

  BEGIN

    vr_pessoa_juridica_bco.idpessoa          := pr_idpessoa;
    vr_pessoa_juridica_bco.nrseq_banco       := pr_nrseq_banco;
    vr_pessoa_juridica_bco.cdbanco           := pr_cdbanco;
    vr_pessoa_juridica_bco.dsoperacao        := pr_dsoperacao;
    vr_pessoa_juridica_bco.vloperacao        := pr_vloperacao;
    vr_pessoa_juridica_bco.dsgarantia        := pr_dsgarantia;
    vr_pessoa_juridica_bco.dtvencimento      := pr_dtvencimento;
    vr_pessoa_juridica_bco.cdoperad_altera   := pr_cdoperad_altera;

    -- Rotina para Cadastrar dados financeiros de pessoa juridica em outrao bancos.
    CADA0010.pc_cadast_pessoa_juridica_bco( pr_pessoa_juridica_bco => vr_pessoa_juridica_bco
                                          , pr_cdcritic            => vr_cdcritic
                                          , pr_dscritic            => pr_dscritic);

    -- Retorna a sequencia
    pr_nrseq_banco := vr_pessoa_juridica_bco.nrseq_banco;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_juridica_bco: ' ||
                     SQLERRM;
  END pc_cadast_pessoa_juridica_bco;

  -- Rotina para excluir dados financeiros de pessoa juridica em outrao bancos.
  PROCEDURE pc_exclui_pessoa_juridica_bco(pr_idpessoa         IN NUMBER     -- Identificador de pessoa
                                         ,pr_nrseq_banco      IN NUMBER     -- Nr. de sequência
                                         ,pr_cdoperad_altera  IN VARCHAR2   -- Operador que esta efetuando a exclusao
                                         ,pr_cdcritic         OUT INTEGER                                          -- Codigo de erro
                                         ,pr_dscritic         OUT VARCHAR2) IS                                     -- Retorno de Erro
  /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_juridica_bco
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para excluir dados financeiros de pessoa juridica em outrao bancos.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <------------------
    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

    -- Chamar rotina para exclusão
		cada0010.pc_exclui_pessoa_juridica_bco ( pr_idpessoa         => pr_idpessoa
                                            ,pr_nrseq_banco      => pr_nrseq_banco
                                            ,pr_cdoperad_altera  => pr_cdoperad_altera
                                            ,pr_cdcritic         => pr_cdcritic
                                            ,pr_dscritic         => pr_dscritic);

		-- Se retornou erro
		IF pr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_juridica_bco: ' ||SQLERRM;
	END pc_exclui_pessoa_juridica_bco;

  -- Rotina para retornar dados financeiros de pessoa juridica em outrao bancos.
  PROCEDURE pc_retorna_pessoa_juridica_bco ( pr_idpessoa IN NUMBER   -- Registro de bens
                                            ,pr_retorno  OUT xmltype -- XML de retorno
                                            ,pr_dscritic             OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_retorna_pessoa_juridica_bco
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para retornar dados financeiros de pessoa juridica em outrao bancos.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------
    -- Cursor para buscar a maior data de alteracao
    CURSOR cr_data_banco IS
      SELECT max(a.dhalteracao) dhalteracao
        FROM tbcadast_pessoa_historico a,
             tbcadast_campo_historico b
       WHERE b.nmtabela_oracle = 'TBCADAST_PESSOA_JURIDICA_BCO'
         AND a.idcampo = b.idcampo
         AND a.idpessoa = pr_idpessoa;
    rw_data_banco cr_data_banco%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;

  BEGIN
    -- Rotina generica para retornar os dados da tabela via xml
    pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa                    --> Id de pessoa
                         ,pr_nmtabela => 'TBCADAST_PESSOA_JURIDICA_BCO' --> Nome da tabela
                         ,pr_dsnoprin => 'bancos'                       --> Nó principal do xml
                         ,pr_dsnofilh => 'banco'                        --> Nós filhos
                         ,pr_retorno  => pr_retorno                     --> XML de retorno
                         ,pr_dscritic => pr_dscritic);
    -- Busca a data da ultima alteracao
    OPEN cr_data_banco;
    FETCH cr_data_banco INTO rw_data_banco;
    CLOSE cr_data_banco;
    -- Insere a data
    gene0007.pc_insere_tag(pr_xml      => pr_retorno
                          ,pr_tag_pai  => 'bancos'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'DTALTERACAO'
                          ,pr_tag_cont => to_char(rw_data_banco.dhalteracao,'DD/MM/YYYY hh24:MI:SS')
                          ,pr_des_erro => pr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_juridica_bco: ' ||
                     SQLERRM;
  END pc_retorna_pessoa_juridica_bco;

  -- Rotina para Cadastrar faturamento mensal de Pessoas Juridica
  PROCEDURE pc_cadast_pessoa_juridica_fat ( pr_idpessoa	             IN NUMBER     --> Identificador unico da pessoa
                                           ,pr_nrseq_faturamento IN OUT NUMBER     --> Numero sequencial do faturamento
                                           ,pr_dtmes_referencia      IN DATE       --> Mes em que ocorreu o faturamento
                                           ,pr_vlfaturamento_bruto   IN NUMBER     --> Valor do faturamento mensal bruto
                                           ,pr_cdoperad_altera       IN VARCHAR2   --> Codigo do operador que realizou a ultima alteracao
                                           ,pr_dscritic             OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_juridica_fat
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Cadastrar faturamento mensal de Pessoas Juridica
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_juridica_fat tbcadast_pessoa_juridica_fat%ROWTYPE;

  BEGIN

    vr_pessoa_juridica_fat.idpessoa              := pr_idpessoa;
    vr_pessoa_juridica_fat.nrseq_faturamento     := pr_nrseq_faturamento;
    vr_pessoa_juridica_fat.dtmes_referencia      := pr_dtmes_referencia;
    vr_pessoa_juridica_fat.vlfaturamento_bruto   := pr_vlfaturamento_bruto;
    vr_pessoa_juridica_fat.cdoperad_altera       := pr_cdoperad_altera;

    -- Rotina para Cadastrar faturamento mensal de Pessoas Juridica
    CADA0010.pc_cadast_pessoa_juridica_fat( pr_pessoa_juridica_fat => vr_pessoa_juridica_fat
                                          , pr_cdcritic            => vr_cdcritic
                                          , pr_dscritic            => pr_dscritic);

    -- Retorna a sequencia
    pr_nrseq_faturamento := vr_pessoa_juridica_fat.nrseq_faturamento;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_juridica_fat: ' ||
                     SQLERRM;
  END pc_cadast_pessoa_juridica_fat;

  -- Rotina para excluir faturamento mensal de Pessoas Juridica
  PROCEDURE pc_exclui_pessoa_juridica_fat(pr_idpessoa          IN NUMBER   -- Identificador de pessoa
                                         ,pr_nrseq_faturamento IN NUMBER   -- Nr. de sequência
                                         ,pr_cdoperad_altera   IN VARCHAR2 -- Operador que esta efetuando a exclusao
                                         ,pr_cdcritic          OUT INTEGER                                          -- Codigo de erro
                                         ,pr_dscritic          OUT VARCHAR2) IS                                     -- Retorno de Erro
  /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_juridica_fat
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para excluir faturamento mensal de Pessoas Juridica
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <------------------
    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

    -- Chamar rotina para exclusão
		cada0010.pc_exclui_pessoa_juridica_fat ( pr_idpessoa         => pr_idpessoa
                                            ,pr_nrseq_faturamento=> pr_nrseq_faturamento
                                            ,pr_cdoperad_altera  => pr_cdoperad_altera
                                            ,pr_cdcritic         => pr_cdcritic
                                            ,pr_dscritic         => pr_dscritic);

		-- Se retornou erro
		IF pr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_juridica_fat: ' ||SQLERRM;
	END pc_exclui_pessoa_juridica_fat;

  -- Rotina para retornar faturamento mensal de Pessoas Juridica
  PROCEDURE pc_retorna_pessoa_juridica_fat ( pr_idpessoa IN NUMBER   -- Registro de bens
                                            ,pr_retorno  OUT xmltype -- XML de retorno
                                            ,pr_dscritic OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_retorna_pessoa_juridica_fat
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para retornar faturamento mensal de Pessoas Juridica
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;

  BEGIN
    -- Rotina generica para retornar os dados da tabela via xml
    pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa                    --> Id de pessoa
                         ,pr_nmtabela => 'TBCADAST_PESSOA_JURIDICA_FAT' --> Nome da tabela
                         ,pr_dsnoprin => 'faturamentos'                 --> Nó principal do xml
                         ,pr_dsnofilh => 'faturamento'                  --> Nós filhos
                         ,pr_retorno  => pr_retorno                     --> XML de retorno
                         ,pr_dscritic => pr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_juridica_fat: ' ||
                     SQLERRM;
  END pc_retorna_pessoa_juridica_fat;

  -- Rotina para Cadastrar participacao societaria em outras empresas
  PROCEDURE pc_cadast_pessoa_juridica_ptp ( pr_idpessoa	              IN NUMBER            --> Identificador unico da pessoa
                                           ,pr_nrseq_participacao IN OUT NUMBER            --> Numero sequencial de participacao
                                           ,pr_idpessoa_participacao  IN NUMBER            --> Identificador unico da pessoa onde a pessoa tem participação
                                           ,pr_persocio               IN NUMBER            --> Percentual societario
                                           ,pr_dtadmissao             IN DATE              --> Data de admissao como socio
                                           ,pr_cdoperad_altera        IN VARCHAR2          --> Codigo do operador que realizou a ultima alteracao
                                           ,pr_dscritic              OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_juridica_ptp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Cadastrar participacao societaria em outras empresas
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_juridica_ptp tbcadast_pessoa_juridica_ptp%ROWTYPE;

  BEGIN

    vr_pessoa_juridica_ptp.idpessoa                := pr_idpessoa;
    vr_pessoa_juridica_ptp.nrseq_participacao      := pr_nrseq_participacao;
    vr_pessoa_juridica_ptp.idpessoa_participacao   := pr_idpessoa_participacao;
    vr_pessoa_juridica_ptp.persocio                := pr_persocio;
    vr_pessoa_juridica_ptp.dtadmissao              := pr_dtadmissao;
    vr_pessoa_juridica_ptp.cdoperad_altera         := pr_cdoperad_altera;


    -- Cadastrar participacao societaria em outras empresas
    CADA0010.pc_cadast_pessoa_juridica_ptp( pr_pessoa_juridica_ptp => vr_pessoa_juridica_ptp
                                          , pr_cdcritic            => vr_cdcritic
                                          , pr_dscritic            => pr_dscritic);

    -- Retorna a sequencia
    pr_nrseq_participacao := vr_pessoa_juridica_ptp.nrseq_participacao;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_juridica_ptp: ' ||
                     SQLERRM;
  END pc_cadast_pessoa_juridica_ptp;

  -- Rotina para excluir participacao societaria em outras empresas
  PROCEDURE pc_exclui_pessoa_juridica_ptp(pr_idpessoa           IN NUMBER   -- Identificador de pessoa
                                         ,pr_nrseq_participacao IN NUMBER   -- Nr. de sequência
                                         ,pr_cdoperad_altera    IN VARCHAR2 -- Operador que esta efetuando a exclusao
                                         ,pr_cdcritic          OUT INTEGER                                          -- Codigo de erro
                                         ,pr_dscritic          OUT VARCHAR2) IS                                     -- Retorno de Erro
  /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_juridica_ptp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para excluir participacao societaria em outras empresas
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <------------------
    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

    -- Chamar rotina para exclusão
		cada0010.pc_exclui_pessoa_juridica_ptp ( pr_idpessoa          => pr_idpessoa
                                            ,pr_nrseq_participacao=> pr_nrseq_participacao
                                            ,pr_cdoperad_altera   => pr_cdoperad_altera
                                            ,pr_cdcritic          => pr_cdcritic
                                            ,pr_dscritic          => pr_dscritic);

		-- Se retornou erro
		IF pr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_juridica_ptp: ' ||SQLERRM;
	END pc_exclui_pessoa_juridica_ptp;

  -- Rotina para Retornar participacao societaria em outras empresas
  PROCEDURE pc_retorna_pessoa_juridica_ptp ( pr_idpessoa IN NUMBER   -- Registro de bens
                                            ,pr_retorno  OUT xmltype -- XML de retorno
                                            ,pr_dscritic OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_retorna_pessoa_juridica_ptp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Retornar participacao societaria em outras empresas
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;

  BEGIN
    -- Rotina generica para retornar os dados da tabela via xml
    pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa                    --> Id de pessoa
                         ,pr_nmtabela => 'TBCADAST_PESSOA_JURIDICA_PTP' --> Nome da tabela
                         ,pr_dsnoprin => 'participacoes'                --> Nó principal do xml
                         ,pr_dsnofilh => 'participacao'                 --> Nós filhos
                         ,pr_retorno  => pr_retorno                     --> XML de retorno
                         ,pr_dscritic => pr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_juridica_ptp: ' ||
                     SQLERRM;
  END pc_retorna_pessoa_juridica_ptp;

  -- Rotina para Cadastrar representantes da pessoa juridica.
  PROCEDURE pc_cadast_pessoa_juridica_rep ( pr_idpessoa	                 IN NUMBER      --> identificador unico da pessoa
                                           ,pr_nrseq_representante   IN OUT NUMBER      --> numero sequencial de representante
                                           ,pr_idpessoa_representante    IN NUMBER      --> indicador unico de pessoa representante da pessoa juridica
                                           ,pr_tpcargo_representante     IN NUMBER      --> tipo de cargo
                                           ,pr_dtvigencia                IN DATE        --> data de vigencia
                                           ,pr_dtadmissao                IN DATE        --> data de admissao como socio
                                           ,pr_persocio                  IN NUMBER      --> percentual societario
                                           ,pr_flgdependencia_economica  IN NUMBER      --> indicador de dependencia economica
                                           ,pr_cdoperad_altera           IN VARCHAR2    -->
                                           ,pr_dscritic                 OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_juridica_rep
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Cadastrar representantes da pessoa juridica.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_juridica_rep tbcadast_pessoa_juridica_rep%ROWTYPE;

  BEGIN

    vr_pessoa_juridica_rep.idpessoa                   := pr_idpessoa;
    vr_pessoa_juridica_rep.nrseq_representante        := pr_nrseq_representante;
    vr_pessoa_juridica_rep.idpessoa_representante     := pr_idpessoa_representante;
    vr_pessoa_juridica_rep.tpcargo_representante      := pr_tpcargo_representante;
    vr_pessoa_juridica_rep.dtvigencia                 := pr_dtvigencia;
    vr_pessoa_juridica_rep.dtadmissao                 := pr_dtadmissao;
    vr_pessoa_juridica_rep.persocio                   := pr_persocio;
    vr_pessoa_juridica_rep.flgdependencia_economica   := pr_flgdependencia_economica;
    vr_pessoa_juridica_rep.cdoperad_altera            := pr_cdoperad_altera;

    --Cadastrar representantes da pessoa juridica.
    CADA0010.pc_cadast_pessoa_juridica_rep( pr_pessoa_juridica_rep => vr_pessoa_juridica_rep
                                          , pr_cdcritic            => vr_cdcritic
                                          , pr_dscritic            => pr_dscritic);

    -- Retorna a sequencia
    pr_nrseq_representante := vr_pessoa_juridica_rep.nrseq_representante;

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_juridica_rep: ' ||
                     SQLERRM;
  END pc_cadast_pessoa_juridica_rep;

  -- Rotina para excluir representantes da pessoa juridica.
  PROCEDURE pc_exclui_pessoa_juridica_rep(pr_idpessoa            IN NUMBER   -- Identificador de pessoa
                                         ,pr_nrseq_representante IN NUMBER   -- Nr. de sequência
                                         ,pr_cdoperad_altera     IN VARCHAR2 -- Operador que esta efetuando a exclusao
                                         ,pr_cdcritic           OUT INTEGER                                          -- Codigo de erro
                                         ,pr_dscritic           OUT VARCHAR2) IS                                     -- Retorno de Erro
  /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_juridica_rep
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para excluir representantes da pessoa juridica.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <------------------
    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

    -- Chamar rotina para exclusão
		cada0010.pc_exclui_pessoa_juridica_rep ( pr_idpessoa            => pr_idpessoa
                                            ,pr_nrseq_representante => pr_nrseq_representante
                                            ,pr_cdoperad_altera     => pr_cdoperad_altera
                                            ,pr_cdcritic            => pr_cdcritic
                                            ,pr_dscritic            => pr_dscritic);

		-- Se retornou erro
		IF pr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_juridica_rep: ' ||SQLERRM;
	END pc_exclui_pessoa_juridica_rep;

  -- Rotina para Retornar representantes da pessoa juridica.
  PROCEDURE pc_retorna_pessoa_juridica_rep ( pr_idpessoa IN NUMBER   -- Registro de bens
                                            ,pr_retorno  OUT xmltype -- XML de retorno
                                            ,pr_dscritic             OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_retorna_pessoa_juridica_rep
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Retornar representantes da pessoa juridica.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;

  BEGIN
    -- Rotina generica para retornar os dados da tabela via xml
    pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa                    --> Id de pessoa
                         ,pr_nmtabela => 'TBCADAST_PESSOA_JURIDICA_REP' --> Nome da tabela
                         ,pr_dsnoprin => 'representantes'               --> Nó principal do xml
                         ,pr_dsnofilh => 'representante'                --> Nós filhos
                         ,pr_retorno  => pr_retorno                     --> XML de retorno
                         ,pr_dscritic => pr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_juridica_rep: ' ||
                     SQLERRM;
  END pc_retorna_pessoa_juridica_rep;

  -- Rotina para Cadastrar pessoas politicamente expostas.
  PROCEDURE pc_cadast_pessoa_polexp ( pr_idpessoa	                 IN NUMBER	     --> Identificador unico do cadastro de pessoa
                                     ,pr_tpexposto                 IN NUMBER       --> Identificacao do tipo de exposicao (tbcadas_dominio_campo) 1-exerce ou exerceu cargo politico/2-possui relacionamento
                                     ,pr_dtinicio                  IN DATE         --> Data de inicio da exposicao politica
                                     ,pr_dttermino                 IN DATE         --> Data de termino da exposicao politica
                                     ,pr_idpessoa_empresa          IN NUMBER       --> Identificador da empresa do politicamente exposto
                                     ,pr_cdocupacao                IN NUMBER       --> Codigo de ocupacao do politico exposto (fk gncdocp)
                                     ,pr_tprelacao_polexp          IN NUMBER       --> tipo de relacionamento (definicao em tbcadast_dominio_campo)
                                     ,pr_idpessoa_politico         IN NUMBER       --> Identificador do politicamente exposto de relacao
                                     ,pr_cdoperad_altera           IN VARCHAR2     -->
                                     ,pr_dscritic                 OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_polexp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Cadastrar pessoas politicamente expostas.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- PlTable que receberá os dados parametrizados
    vr_pessoa_polexp tbcadast_pessoa_polexp%ROWTYPE;

  BEGIN

    vr_pessoa_polexp.idpessoa          := pr_idpessoa;
    vr_pessoa_polexp.tpexposto         := pr_tpexposto;
    vr_pessoa_polexp.dtinicio          := pr_dtinicio;
    vr_pessoa_polexp.dttermino         := pr_dttermino;
    vr_pessoa_polexp.idpessoa_empresa  := pr_idpessoa_empresa;
    vr_pessoa_polexp.cdocupacao        := pr_cdocupacao;
    vr_pessoa_polexp.tprelacao_polexp  := pr_tprelacao_polexp;
    vr_pessoa_polexp.idpessoa_politico := pr_idpessoa_politico;
--    vr_pessoa_polexp.cdoperad_altera   := pr_cdoperad_altera;

    --Cadastrar representantes da pessoa juridica.
    CADA0010.pc_cadast_pessoa_polexp( pr_pessoa_polexp => vr_pessoa_polexp
                                    , pr_cdcritic      => vr_cdcritic
                                    , pr_dscritic      => pr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_polexp: ' ||
                     SQLERRM;
  END pc_cadast_pessoa_polexp;

  -- Rotina para excluir pessoas politicamente expostas.
  PROCEDURE pc_exclui_pessoa_polexp ( pr_idpessoa            IN NUMBER       -- Identificador de pessoa
                                     ,pr_cdoperad_altera     IN VARCHAR2     -- Operador que esta efetuando a exclusao
                                     ,pr_cdcritic           OUT INTEGER      -- Codigo de erro
                                     ,pr_dscritic           OUT VARCHAR2) IS -- Retorno de Erro
  /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_juridica_rep
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para excluir pessoas politicamente expostas.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <------------------
    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

    -- Chamar rotina para exclusão
		cada0010.pc_exclui_pessoa_polexp ( pr_idpessoa            => pr_idpessoa
                                      ,pr_cdoperad_altera     => pr_cdoperad_altera
                                      ,pr_cdcritic            => pr_cdcritic
                                      ,pr_dscritic            => pr_dscritic);

		-- Se retornou erro
		IF pr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_polexp: ' ||SQLERRM;
	END pc_exclui_pessoa_polexp;

  -- Rotina para Retornar pessoas politicamente expostas.
  PROCEDURE pc_retorna_pessoa_polexp ( pr_idpessoa IN NUMBER   -- Registro de bens
                                      ,pr_retorno  OUT xmltype -- XML de retorno
                                      ,pr_dscritic             OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_retorna_pessoa_polexp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Retornar pessoas politicamente expostas.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;

  BEGIN
    -- Rotina generica para retornar os dados da tabela via xml
    pc_retorna_dados_xml (pr_idpessoa => pr_idpessoa              --> Id de pessoa
                         ,pr_nmtabela => 'TBCADAST_PESSOA_POLEXP' --> Nome da tabela
                         ,pr_dsnoprin => 'polexp'                 --> Nó principal do xml
                         ,pr_dsnofilh => 'dados'                  --> Nós filhos
                         ,pr_retorno  => pr_retorno               --> XML de retorno
                         ,pr_dscritic => pr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_pessoa_polexp: ' ||
                     SQLERRM;
  END pc_retorna_pessoa_polexp;

  -- Rotina para efetuar a atualizacao de regras (Ex. Revisao Cadastral)
  PROCEDURE pc_atualiza_processo_regra(pr_idpessoa   IN NUMBER,  -- Registro de bens
                                       pr_idprocesso IN VARCHAR2,  -- Processo que sera utilizado (1-Revisao Cadastral)
                                       pr_dtprocesso IN DATE,    -- Data de processo da regra
                                       pr_dscritic OUT VARCHAR2) IS  -- Retorno de Erro
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_cdcritic PLS_INTEGER;
		vr_dscritic VARCHAR2(4000);

  BEGIN
    NULL;
  EXCEPTION
		WHEN vr_exc_erro THEN
			-- Se possui código da crítica
			IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
				-- Buscar descrição da crítica
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			END IF;
			-- Retornar crítica parametrizada
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_atualiza_processo_regra: ' ||
                     SQLERRM;
  END pc_atualiza_processo_regra;


  -- Rotina para efetuar a revisao cadastral
  PROCEDURE pc_efetiva_revisao(pr_idpessoa       IN NUMBER,  -- Registro de bens
                               pr_dtatualizacao  IN DATE, -- Data de atualizacao da regra
                               pr_cdoperad       IN VARCHAR2, -- Codigo do operador
                               pr_tpcanal_atualizacao IN NUMBER, -- Canal que foi feito a atualizacao (1-Ayllos/2-Caixa/3-Internet/4-Cash/5-Ayllos WEB/6-URA/7-Batch/8-Mensageria/9-Mobile/10-CRM)
                               pr_dscritic OUT VARCHAR2) IS  -- Retorno de Erro
    ---------------> CURSORES <-----------------
		-- Busca o tipo de pessoa
    CURSOR cr_pessoa IS
      SELECT tppessoa
        FROM tbcadast_pessoa
       WHERE idpessoa = pr_idpessoa;
    rw_pessoa cr_pessoa%ROWTYPE;

    -- Busca os dados de pessoa fisica
    CURSOR cr_pessoa_fisica IS
      SELECT *
        FROM vwcadast_pessoa_fisica
       WHERE idpessoa = pr_idpessoa;
    rw_pessoa_fisica cr_pessoa_fisica%ROWTYPE;

    -- Busca os dados de pessoa juridica
    CURSOR cr_pessoa_juridica IS
      SELECT *
        FROM vwcadast_pessoa_juridica
       WHERE idpessoa = pr_idpessoa;
    rw_pessoa_juridica cr_pessoa_juridica%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_cdcritic PLS_INTEGER;
		vr_dscritic VARCHAR2(4000);

  BEGIN
    -- Busca o tipo de pessoa
    OPEN cr_pessoa;
    FETCH cr_pessoa INTO rw_pessoa;
    IF cr_pessoa%NOTFOUND THEN
      CLOSE cr_pessoa;
      vr_dscritic := 'Pessoa nao encontrada!';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_pessoa;

    -- Se for pessoa fisica
    IF rw_pessoa.tppessoa = 1 THEN
      -- Busca os dados de pessoa fisica
      OPEN cr_pessoa_fisica;
      FETCH cr_pessoa_fisica INTO rw_pessoa_fisica;
      CLOSE cr_pessoa_fisica;

      -- Atualiza a data de revisao cadastral
      rw_pessoa_fisica.dtrevisao_cadastral := pr_dtatualizacao;

      -- Atualiza o cadastro de pessoa fisica
      cada0010.pc_cadast_pessoa_fisica(pr_pessoa_fisica => rw_pessoa_fisica
                                      ,pr_cdcritic      => vr_cdcritic
                                      ,pr_dscritic      => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    ELSE -- Se for PJ
      -- Busca os dados de pessoa juridica
      OPEN cr_pessoa_juridica;
      FETCH cr_pessoa_juridica INTO rw_pessoa_juridica;
      CLOSE cr_pessoa_juridica;

      -- Atualiza a data de revisao cadastral
      rw_pessoa_fisica.dtrevisao_cadastral := pr_dtatualizacao;

      -- Atualiza o cadastro de pessoa juridica
      cada0010.pc_cadast_pessoa_juridica(pr_pessoa_juridica => rw_pessoa_juridica
                                        ,pr_cdcritic        => vr_cdcritic
                                        ,pr_dscritic        => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;

  EXCEPTION
		WHEN vr_exc_erro THEN
			-- Se possui código da crítica
			IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
				-- Buscar descrição da crítica
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			END IF;
			-- Retornar crítica parametrizada
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_efetiva_revisao: ' ||
                     SQLERRM;
  END pc_efetiva_revisao;

  -- Rotina para validar senha da conta do cooperado
  PROCEDURE pc_valida_senha_cooperado (pr_cdcooper IN NUMBER,   -- Código da cooperativa
                                       pr_nrdconta IN VARCHAR2, -- Número da conta
                                       pr_dstoken OUT VARCHAR2, -- Token de retorno nos casos sucesso na validação
                                       pr_dscritic OUT VARCHAR2) IS  -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_valida_senha_usuario
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Everton Souza
    --  Data     : Agosto/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para validar a senha de acesso do cooperado
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

		-- Verificar acesso do cooperado
		CURSOR cr_crapsnh IS
      select cddsenha
        from crapsnh A
       WHERE a.nrdconta = pr_nrdconta -- conta do cooperado
         and a.cdcooper = pr_cdcooper -- cooperativa do cooperado
         and a.cdsitsnh = 1  -- senha ativa
         and a.tpdsenha = 1; -- senha de internet

		rw_crapsnh cr_crapsnh%ROWTYPE;
    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_cdcritic PLS_INTEGER;
		vr_dscritic VARCHAR2(4000);

  BEGIN

			-- Buscar registro de senha
			OPEN cr_crapsnh;
			FETCH cr_crapsnh INTO rw_crapsnh;

			-- Se não encontrou registro de senha
			IF cr_crapsnh%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_crapsnh;
				-- Gerar crítica
				vr_dscritic := 'Senha de cooperado não encontrada';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
			-- Fechar cursor
			CLOSE cr_crapsnh;

      -- Retorna o token de acesso
      pr_dstoken := rw_crapsnh.cddsenha;

  EXCEPTION
		WHEN vr_exc_erro THEN
			-- Se possui código da crítica
			IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
				-- Buscar descrição da crítica
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			END IF;
			-- Retornar crítica parametrizada
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_valida_senha_cooperado: ' ||
                     SQLERRM;
  END pc_valida_senha_cooperado;

  -- Rotina para verificar forma de pagamento de cotas na modalidade Desligamento
  PROCEDURE pc_retorna_forma_ago (pr_cdcooper IN NUMBER,   -- Código da cooperativa
                                  pr_formaago OUT NUMBER,  -- Forma de pagamento cotas desligamento
                                  pr_dscritic OUT VARCHAR2) IS  -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_retorna_forma_ago
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Everton Souza
    --  Data     : Setembro/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para validar forma de pagamento de cotas no momento do desligamento
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

		-- Verificar parâmetro forma de pagamento de cotas no momento do desligamento
		CURSOR cr_craptab IS
      SELECT craptab.tpregist
        FROM craptab
       where craptab.nmsistem = 'CRED'
         and craptab.tptabela = 'GENERI'
         and craptab.cdempres = 0
         and craptab.cdacesso = 'PRAZODESLIGAMENTO'
         and craptab.cdcooper = pr_cdcooper;


		rw_craptab cr_craptab%ROWTYPE;
    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_cdcritic PLS_INTEGER;
		vr_dscritic VARCHAR2(4000);

  BEGIN

			-- Buscar parâmetro forma de pagamento de cotas
			OPEN cr_craptab;
			FETCH cr_craptab INTO rw_craptab;

			-- Se não encontrou parâmetro forma de pagamento de cotas
			IF cr_craptab%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_craptab;
				-- Gerar crítica
				vr_dscritic := 'Parâmetro forma de pagamento de cotas AGO não encontrado';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;

      -- Retorna a forma de pagamento das cotas
      -- 1 - pagamento após a AGO
      -- 2 - pagamento antecipado
      pr_formaago := rw_craptab.tpregist;

			-- Fechar cursor
			CLOSE cr_craptab;

  EXCEPTION
		WHEN vr_exc_erro THEN
			-- Se possui código da crítica
			IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
				-- Buscar descrição da crítica
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			END IF;
			-- Retornar crítica parametrizada
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_forma_ago: ' ||
                     SQLERRM;
  END pc_retorna_forma_ago;


  -- Rotina para atualizar situação da conta para "em processo de demissão"
  PROCEDURE pc_atualiza_situacao_conta (pr_cdcooper IN NUMBER,   -- Código da cooperativa
                                        pr_nrdconta IN NUMBER,   -- Número da conta
                                        pr_cdmotdem IN NUMBER,   -- Código Motivo Demissão
                                        pr_dscritic OUT VARCHAR2) IS  -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_atualiza_situacao_conta
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Everton Souza
    --  Data     : Setembro/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para atualizar situação da conta para "em processo de demissão"
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
		-- Verificar existência de conta
		CURSOR cr_crapass IS
      SELECT cdsitdct
        FROM crapass
       where crapass.cdcooper = pr_cdcooper
         and crapass.nrdconta = pr_nrdconta;

		rw_crapass cr_crapass%ROWTYPE;


    CURSOR cr_log IS
      SELECT i.dsdadant,
             i.dsdadatu
        FROM craplgm m, craplgi i
       where m.cdcooper = i.cdcooper
         and m.nrdconta = i.nrdconta
         and m.idseqttl = i.idseqttl
         and m.dttransa = i.dttransa
         and m.hrtransa = i.hrtransa
         and m.nrsequen = i.nrsequen
         and m.cdcooper = pr_cdcooper
         and m.nrdconta = pr_nrdconta
         and m.dstransa = 'Alteração Situação Conta'
       order by m.dttransa desc, m.hrtransa desc;

     rw_log cr_log%ROWTYPE;

   ---------------> VARIAVEIS <-----------------
    vr_nrdrowid  ROWID;
    vr_dsorigem  VARCHAR2(30) := NULL;
    -- Tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_cdcritic PLS_INTEGER;
		vr_dscritic VARCHAR2(4000);

  BEGIN
		-- verifica existência da conta
		OPEN cr_crapass;
		FETCH cr_crapass INTO rw_crapass;

		-- Se não encontrou a conta
		IF cr_crapass%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapass;
			-- Gerar crítica
			vr_dscritic := 'Conta não encontrada';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
    --
		-- Fechar cursor
		CLOSE cr_crapass;
    --
    IF pr_cdmotdem = 0 THEN
      --
			-- verifica existência da conta
			OPEN cr_log;
			FETCH cr_log INTO rw_log;

			-- Se não encontrou a conta
			IF cr_log%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_log;
				-- Gerar crítica
				vr_dscritic := 'Situação anterior não cadastrada';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
      --
			-- Fechar cursor
			CLOSE cr_log;
      --
      --
     END IF;
     
     -- #PRB0040416 - Wagner - Sustentação --
     -- Tratar mudança indevida de situação de conta já encerrada
     -- Inicio 
     -- 1 - Liberada, 2 - Em prejuízo, 3 - Encerrada pela Cooperativa, 4 - Encerrada por demissão, 
     -- 5 - Restrita, 7 - Em processo de demissão, 8 - Em processo de demissão BACEN, 9 - Em análise
     IF rw_crapass.cdsitdct = 4 THEN
       -- Não iremos "Gerar crítica" para não levantar um erro no CRM, iremos apenas não acatar o pedido
       -- vr_dscritic := 'Conta em situação 4 - Encerrada por demissão, alteração não permitida.';       
       -- Levantar exceção
       RETURN;
     END IF;       
     -- Fim -- #PRB0040416
     
     --
     -- Atualiza tabela de contas
      BEGIN
        UPDATE crapass
           set cdsitdct = decode(pr_cdmotdem,0,rw_log.dsdadant,pr_cdmotdem)
         where cdcooper = pr_cdcooper
           and nrdconta = pr_nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
				  -- Gerar crítica
			  	vr_dscritic := 'Erro UPDATE tabela CRAPASS: ' ||
                     SQLERRM;
				  -- Levantar exceção
			  	RAISE vr_exc_erro;
      END;
      --
      vr_dsorigem := gene0001.vr_vet_des_origens(7);
      -- Gerar log
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => 1
                        ,pr_dscritic => null
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => 'Alteração Situação Conta'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => ' '
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

      IF pr_cdmotdem = 0 THEN
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'cdsitdct',
                                pr_dsdadant => rw_crapass.cdsitdct,
                                pr_dsdadatu => rw_log.dsdadant);
      ELSE
        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'cdsitdct',
                                pr_dsdadant => rw_crapass.cdsitdct,
                                pr_dsdadatu => pr_cdmotdem);
      END IF;
      --

  EXCEPTION
		WHEN vr_exc_erro THEN
			-- Se possui código da crítica
			IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
				-- Buscar descrição da crítica
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			END IF;
			-- Retornar crítica parametrizada
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_atualiza_situacao_conta: ' ||
                     SQLERRM;
  END pc_atualiza_situacao_conta;

  -- Rotina para verificar valor de cotas liberadas para saque
  PROCEDURE pc_retorna_cotas_liberada (pr_cdcooper IN NUMBER,   -- Código da cooperativa
                                       pr_nrdconta IN NUMBER,   -- Número da conta
                                       pr_vldcotas OUT NUMBER,  -- Forma de pagamento cotas desligamento
                                       pr_dscritic OUT VARCHAR2) IS  -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_retorna_forma_ago
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Everton Souza
    --  Data     : Setembro/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para verificar valor de cotas liberadas para saque
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

		-- Verificar valor de cotas
		CURSOR cr_crapcot IS
      select a.vldcotas
        from crapcot a
       where a.cdcooper = pr_cdcooper
         and a.nrdconta = pr_nrdconta;

		rw_crapcot cr_crapcot%ROWTYPE;

		-- Verificar valor bloqueado de cotas capital
		CURSOR cr_crapblj IS
      select c.vlbloque
        from crapblj c
       where c.cdcooper = pr_cdcooper
         and c.nrdconta = pr_nrdconta
         and c.cdmodali = 4 -- modalidade capital
         and c.dtblqini <= sysdate
         and (c.dtblqfim >= sysdate or c.dtblqfim is null);

		rw_crapblj cr_crapblj%ROWTYPE;

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
		vr_exc_erro EXCEPTION;
		vr_cdcritic PLS_INTEGER;
		vr_dscritic VARCHAR2(4000);

    -- variaveis locais]
    vr_vldcotas crapcot.vldcotas%type;
    vr_vlbloque crapblj.vlbloque%type;

  BEGIN

			-- Buscar valor de cotas
			OPEN cr_crapcot;
			FETCH cr_crapcot INTO rw_crapcot;

			-- Se não encontrou valor de cotas
			IF cr_crapcot%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_crapcot;
				-- Gerar crítica
				vr_dscritic := 'Cotas não encontrada';
				-- Levantar exceção
				RAISE vr_exc_erro;
			END IF;
      --
      vr_vldcotas := rw_crapcot.vldcotas;
			-- Fechar cursor
			CLOSE cr_crapcot;
      --
			-- Buscar valor de cotas bloqueadas judicialmente
			OPEN cr_crapblj;
			FETCH cr_crapblj INTO rw_crapblj;

			-- Se não encontrou valor de cotas bloqueadas
			IF cr_crapblj%NOTFOUND THEN
				-- Atribui 0
				vr_vlbloque := 0;
      ELSE
        vr_vlbloque := rw_crapblj.vlbloque;
			END IF;
			-- Fechar cursor
			CLOSE cr_crapblj;
      --
      -- Retorna o valor de cotas liberada
      pr_vldcotas := vr_vldcotas - vr_vlbloque;

  EXCEPTION
		WHEN vr_exc_erro THEN
			-- Se possui código da crítica
			IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
				-- Buscar descrição da crítica
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			END IF;
			-- Retornar crítica parametrizada
			pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_cotas_liberada: ' ||
                     SQLERRM;
  END pc_retorna_cotas_liberada;

  -- Rotina para cadastrar aprovação de saque de cotas
  PROCEDURE pc_cadast_aprov_saque_cotas( pr_cdcooper	     IN NUMBER	--> Codigo da cooperativa
                                        ,pr_nrdconta       IN NUMBER  --> Numero da conta
                                        ,pr_cdmotivo       IN NUMBER  --> Codigo do motivo de saque parcial ou desligamento
                                        ,pr_tpsaque        IN NUMBER  --> Identificador do tipo de saque (1-PARCIAL / 2-DESLIGAMENTO)
                                        ,pr_iddevolucao    IN NUMBER  --> Identificador de devolucao de cotas por desligamento (1-ANTECIPADO / 2-APOS AGO)
                                        ,pr_vlsaque        IN NUMBER  --> Valor do saque
                                        ,pr_tpiniciativa   IN NUMBER  --> Identificador da iniciativa de saque de cotas (1-COOPERATIVA / 2-COOPERADO)
                                        ,pr_dtaprovwork    IN DATE    --> Data de aprovacao final workflow CRM
                                        ,pr_dtdesligamento IN DATE    --> Data de desligamento do cooperado
                                        ,pr_dtsolicitacao  IN DATE    --> Data de solicitação de saque de cotas
                                        ,pr_dtcredito      IN DATE    --> Data de crédito das cotas
                                        ,pr_cdoperadaprov  IN VARCHAR2 --> Código do Operador aprovador final workflow CRM
                                        ,pr_dscritic      OUT VARCHAR2) IS

    /* ..........................................................................
    --
    --  Programa : pc_cadast_aprov_saque_cotas
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Everton Souza (Mouts)
    --  Data     : Setembro/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Cadastrar aprovação de saque de cotas.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    ---------------> CURSORES <-----------------

    ---------------> VARIAVEIS <-----------------
    -- Tratamento de erros
    vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    -- PlTable que receberá os dados parametrizados
    vr_tbcotas_saque_controle tbcotas_saque_controle%ROWTYPE;

  BEGIN
    --
    if pr_cdcooper is null then
      vr_dscritic := 'Parâmetro cooperativa é obrigatório.';
      RAISE vr_exc_erro;
    end if;
    --
    if pr_nrdconta is null then
      vr_dscritic := 'Parâmetro número da conta é obrigatório.';
      RAISE vr_exc_erro;
    end if;
    --
    if pr_cdmotivo is null then
      vr_dscritic := 'Parâmetro motivo de saque é obrigatório.';
      RAISE vr_exc_erro;
    end if;
    --
    if pr_tpsaque is null then
      vr_dscritic := 'Parâmetro tipo de saque é obrigatório.';
      RAISE vr_exc_erro;
    end if;
    --
    if pr_iddevolucao is null and  pr_tpsaque = 2 then
      vr_dscritic := 'Parâmetro identificador de devolução é obrigatório para Saque por desligamento.';
      RAISE vr_exc_erro;
    end if;
    --
    if pr_vlsaque is null then
      vr_dscritic := 'Parâmetro valor do saque é obrigatório.';
      RAISE vr_exc_erro;
    end if;
    --
    if pr_tpiniciativa is null then
      vr_dscritic := 'Parâmetro tipo de iniciativa é obrigatório.';
      RAISE vr_exc_erro;
    end if;
    --
    if pr_dtaprovwork is null then
      vr_dscritic := 'Parâmetro data de aprovação workflow é obrigatório.';
      RAISE vr_exc_erro;
    end if;
    --
    --if pr_dtdesligamento is null and  pr_tpsaque = 2 then
    --  vr_dscritic := 'Parâmetro data de desligamento é obrigatório para Saque por desligamento.';
    --  RAISE vr_exc_erro;
    --end if;
    --
    if pr_dtsolicitacao is null then
      vr_dscritic := 'Parâmetro data de solicitação workflow é obrigatório.';
      RAISE vr_exc_erro;
    end if;
    --
    --if pr_dtcredito is null then
    --  vr_dscritic := 'Parâmetro data de crédito de saque de cotas é obrigatório.';
    --  RAISE vr_exc_erro;
    --end if;
    --
    if pr_cdoperadaprov is null then
      vr_dscritic := 'Parâmetro data de operador aprovador de workflow é obrigatório.';
      RAISE vr_exc_erro;
    end if;
    --
    vr_tbcotas_saque_controle.cdcooper       := pr_cdcooper;
    vr_tbcotas_saque_controle.nrdconta       := pr_nrdconta;
    vr_tbcotas_saque_controle.cdmotivo       := pr_cdmotivo;
    vr_tbcotas_saque_controle.tpsaque        := pr_tpsaque;
    vr_tbcotas_saque_controle.iddevolucao    := pr_iddevolucao;
    vr_tbcotas_saque_controle.vlsaque        := pr_vlsaque;
    vr_tbcotas_saque_controle.tpiniciativa   := pr_tpiniciativa;
    vr_tbcotas_saque_controle.dtaprovwork    := pr_dtaprovwork;
    vr_tbcotas_saque_controle.dtdesligamento := null;--pr_dtdesligamento;
    vr_tbcotas_saque_controle.dtsolicitacao  := pr_dtsolicitacao;
    vr_tbcotas_saque_controle.dtcredito      := null;--pr_dtcredito;
    vr_tbcotas_saque_controle.cdoperad_aprov := pr_cdoperadaprov;


    --Cadastrar aprovação de saque de cotas.
    CADA0010.pc_cadast_aprov_saque_cotas( pr_tbcotas_saque_controle => vr_tbcotas_saque_controle
                                        , pr_cdcritic      => vr_cdcritic
                                        , pr_dscritic      => pr_dscritic);

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'CADA0012-Erro não tratado na pc_cadast_aprov_saque_cotas: ' ||
                     ' COOP:'||pr_cdcooper||
                     ' MOT:'||pr_cdmotivo||
                     ' CONTA:'||pr_nrdconta||
                     ' TIPO:'||pr_tpsaque||
                     ' DEV:'||pr_iddevolucao||
                     ' VALOR:'||pr_vlsaque||
                     ' INIC:'||pr_tpiniciativa||
                     ' DTWORK:'||pr_dtaprovwork||
                     ' DTSOL:'||pr_dtsolicitacao||
                     ' OPERA:'||pr_cdoperadaprov||' - '||
                     SQLERRM;
  END pc_cadast_aprov_saque_cotas;
  --
  PROCEDURE pc_retorna_instituicao_finan(pr_cdbccxlt  IN crapban.cdbccxlt%TYPE  --Código do banco 
                                        ,pr_idportab  IN NUMBER -- Indicador de Portabilidade
                                        ,pr_dsretxml  OUT xmltype -- XML de retorno CLOB
                                        ,pr_dscritic  OUT VARCHAR2) is
 /* ---------------------------------------------------------------------------------------------------------------

    Programa : pc_retorna_instituicao_finan
    Sistema  : Conta-Corrente - Cooperativa de Credito  
    Sigla    : CADA
    Autor    : Gilberto - Supero
    Data     : Fevereiro/2019.
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo  : Rotinas Retornar o retorno dos Bancos participantes da Portabilidade de Salário
    Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  -- Cursor para buscar os Bancos
    CURSOR cr_banco IS
       SELECT c.cdbccxlt cdbanco
                 ,UPPER(TRIM(c.nmextbcc))  dsbanco
                 ,c.nrispbif nrispbif
                 ,c.nrcnpjif nrcnpjif
                 ,ROWNUM - 1 seq
              FROM cecred.crapban c
             WHERE (c.cdbccxlt = 1 or c.nrispbif > 0 )
               AND c.cdbccxlt = decode(nvl(pr_cdbccxlt,0),0,c.cdbccxlt,pr_cdbccxlt)
               AND (c.nrcnpjif > 0 and NVL(pr_idportab,0) = 1)
           UNION  
         SELECT c.cdbccxlt cdbanco
               ,UPPER(TRIM(c.nmextbcc))  dsbanco
               ,c.nrispbif nrispbif
               ,c.nrcnpjif nrcnpjif
               ,ROWNUM - 1 seq
            FROM cecred.crapban c
           WHERE (c.cdbccxlt = 1 or c.nrispbif > 0 )
             AND  c.cdbccxlt = decode(nvl(pr_cdbccxlt,0),0,c.cdbccxlt,pr_cdbccxlt)
             AND NVL(pr_idportab,0) <> 1 
           order by 1;

   rw_banco cr_banco%ROWTYPE;

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  -- Variaveis gerais
  vr_clob     CLOB;
  vr_xml_temp VARCHAR2(32767);

  BEGIN
    -- Criar documento XML
    dbms_lob.createtemporary(vr_clob, TRUE); 
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite); 
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>'); 
    ---                       
    gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '<bancos>');
    -- Loop sobre a tabela de pessoas
    FOR rw_banco IN cr_banco LOOP
        -- Montar XML com registros do texto
        gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<banco>'
                                                   ||'<cdbanco>'||rw_banco.cdbanco||'</cdbanco>'
                                                   ||'<dsbanco>'||rw_banco.dsbanco||'</dsbanco>'
                                                   ||'<nrispbif>'||rw_banco.nrispbif||'</nrispbif>'
                                                   ||'<nrcnpjif>'||rw_banco.nrcnpjif||'</nrcnpjif>'
                                                   ||'</banco>'
                                                    );
    END LOOP;
    -- Encerrar a tag raiz 
    gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '</bancos>');
                                                          
    gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '</root>' 
                           ,pr_fecha_xml      => TRUE);
    -- Converte para XML

 
   pr_dsretxml := xmltype(vr_clob);
   
  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Falha ao listar Bancos. Dúvidas entrar em contato com o SAC pelo telefone 0800 647 2200. ';
  END pc_retorna_instituicao_finan;
  --
  PROCEDURE pc_retorna_empregador_coop(pr_cdcooper 	IN NUMBER
                                      ,pr_nrdconta 	IN NUMBER  
                                      ,pr_idseqttl 	IN NUMBER
                                      ,pr_nrcpfcgc 	IN NUMBER
                                      ,pr_dsretxml  OUT xmltype
                                      ,pr_dscritic  OUT VARCHAR2) is
 /* ---------------------------------------------------------------------------------------------------------------
    Programa : pc_retorna_empregador_coop
    Sistema  : Conta-Corrente - Cooperativa de Credito  
    Sigla    : CADA
    Autor    : Gilberto - Supero
    Data     : Março/2019.
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo  : Listar Empregador – Buscar a listagem dos empregadores do cooperado
    Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  -- Cursor para buscar os Empregadores
    CURSOR cr_emprega IS
      SELECT t.nrdconta
           , t.idseqttl
           , decode(t.cdempres, 9998, 1, 2) inpessoa -- 9999: empresa PF senão PJ
           , t.nrcpfemp nrdocemp
           , t.nmextemp nmempreg
           , t.dsproftl dsfuncao
           , to_char(t.dtadmemp,'DD/MM/RRRR') dtadmiss
        FROM crapttl t
       WHERE t.cdcooper    = pr_cdcooper
         AND t.nrdconta    = NVL(pr_nrdconta, t.nrdconta)
         AND ((t.idseqttl  = NVL(pr_idseqttl, t.idseqttl) AND pr_nrdconta IS NOT NULL) 
                OR pr_idseqttl IS NULL)
         AND t.nrcpfcgc    = NVL(pr_nrcpfcgc, t.nrcpfcgc);

  rw_emprega cr_emprega%ROWTYPE;
  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  -- Variaveis gerais
  vr_clob     CLOB;
  vr_xml_temp VARCHAR2(32767);

  BEGIN
    -- Criar documento XML
    dbms_lob.createtemporary(vr_clob, TRUE); 
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite); 
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>'); 
    ---                       
    gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '<empregadores>');
    -- Loop sobre a tabela de pessoas
    FOR rw_emprega IN cr_emprega LOOP
        -- Montar XML com registros do texto
        gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<empregador>'
                                ||'<nrdconta>'||rw_emprega.nrdconta ||'</nrdconta>'
                                ||'<idseqttl>'||rw_emprega.idseqttl ||'</idseqttl>'
                                ||'<inpessoa>'||rw_emprega.inpessoa ||'</inpessoa>'
                                ||'<nrdocemp>'||rw_emprega.nrdocemp ||'</nrdocemp>'
                                ||'<nmempreg>'||rw_emprega.nmempreg ||'</nmempreg>'
                                ||'<dsfuncao>'||rw_emprega.dsfuncao ||'</dsfuncao>'
                                ||'<dtadmiss>'||rw_emprega.dtadmiss ||'</dtadmiss>'
                                ||'</empregador>');
    END LOOP;
    -- Encerrar a tag raiz 
    gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '</empregadores>');
                                                          
    gene0002.pc_escreve_xml(pr_xml            => vr_clob 
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => '</root>' 
                           ,pr_fecha_xml      => TRUE);
    -- Converte para XML

   pr_dsretxml := xmltype(vr_clob);
   
  EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Falha ao listar Empregador. Dúvidas entrar em contato com o SAC pelo telefone 0800 647 2200. ';
  END pc_retorna_empregador_coop;
  --
  -- Rotina para retorno dos relacionamentos da pessoa
  PROCEDURE pc_retorna_relacionamentos( pr_idpessoa  IN NUMBER   -- Identificador da pessoa
                                       ,pr_tprelacao IN VARCHAR2 -- Filtro para o tipo de relacao
                                       ,pr_retorno   OUT xmltype -- XML de retorno
                                       ,pr_dscritic             OUT VARCHAR2) IS
  /* Tipos de relacao
    10  Pessoa de Referência
    11  Pessoa Referenciada
    20  Fonte de Renda
    21  Colaborador
    30  Representante Legal (com nivel)
    31  Representado Legalmente
    40  Representado Societario
    41  Sócio Participante
    50  Responsável legal (com nivel)
    51  Representado
    60  Dependente (possui dependente) (com nivel)
    61  Responsável do Dependente
    70  Pai
    71  Mâe
    72  Filho
    73  Cônjuge
    80  Ocupa Posição de Exposição Politica (com nivel)
    81  Tem membro PEP
    82  Relacionado próximo com Ocupante Posição de Exposição Politica (com nivel)
    83	PEP com relacionamento próximo
    90  Mandato Financeiro
    91  Administrado Financeiro
  */

    TYPE typ_reg_relacao IS
        RECORD (idpessoa           tbcadast_pessoa.idpessoa%TYPE, -- Pessoa na qual a pessoa solicitada possui relacao
                nrseq_relacao      NUMBER(05),
                tprelacao          NUMBER(02),   -- Tipo de relacao
                cdoperad_altera    tbcadast_pessoa.cdoperad_altera%TYPE,
                tpnivel_relacao    NUMBER(06)); -- Nivel da relacao (detalhes do tipo de relacao)
    /* Definicao de tabela que compreende os registros acima declarados */
    TYPE typ_tab_relacao IS
      TABLE OF typ_reg_relacao
      INDEX BY BINARY_INTEGER;
    /* Vetor com as informacoes de relacao */
    vr_relacao typ_tab_relacao;
    ind PLS_INTEGER := 0; -- Indice do verot
    
    -- Busca as pessoas de referencia
    CURSOR cr_referencia IS
      SELECT idpessoa_referencia,
             nrseq_referencia,
             cdoperad_altera
        FROM tbcadast_pessoa_referencia a
       WHERE idpessoa = pr_idpessoa;
    -- Busca as pessoas referenciadas
    CURSOR cr_referencia_2 IS
      SELECT idpessoa,
             nrseq_referencia,
             cdoperad_altera
        FROM tbcadast_pessoa_referencia
       WHERE idpessoa_referencia = pr_idpessoa;

    -- Busca a empresa de trabalho
    CURSOR cr_renda IS
      SELECT a.idpessoa_fonte_renda,
             a.nrseq_renda,
             cdoperad_altera
        FROM tbcadast_pessoa_renda a
       WHERE idpessoa = pr_idpessoa;
    -- Busca os colaboradores da empresa
    CURSOR cr_renda_2 IS
      SELECT idpessoa,
             nrseq_renda,
             cdoperad_altera
        FROM tbcadast_pessoa_renda
       WHERE idpessoa_fonte_renda = pr_idpessoa;
       
    -- Busca os representantes da PJ
    CURSOR cr_representante IS
      SELECT a.idpessoa_representante,
             a.tpcargo_representante,
             a.nrseq_representante,
             cdoperad_altera
        FROM tbcadast_pessoa_juridica_rep a
       WHERE idpessoa = pr_idpessoa;
    -- Busca os PJ representados 
    CURSOR cr_representante_2 IS
      SELECT idpessoa,
             nrseq_representante,
             cdoperad_altera
        FROM tbcadast_pessoa_juridica_rep
       WHERE idpessoa_representante = pr_idpessoa;
       
    -- Busca as participacoes societarias (pertence)
    CURSOR cr_participacao IS
      SELECT a.idpessoa_participacao,
             a.nrseq_participacao,
             cdoperad_altera
        FROM tbcadast_pessoa_juridica_ptp a
       WHERE idpessoa = pr_idpessoa;
    -- Busca as participacoes societarias (possui)
    CURSOR cr_participacao_2 IS
      SELECT idpessoa,
             nrseq_participacao,
             cdoperad_altera
        FROM tbcadast_pessoa_juridica_ptp
       WHERE idpessoa_participacao = pr_idpessoa;
       
    -- Busca os responsaveis legais
    CURSOR cr_responsavel IS
      SELECT idpessoa_resp_legal,
             cdrelacionamento,
             nrseq_resp_legal,
             cdoperad_altera
        FROM tbcadast_pessoa_fisica_resp a
       WHERE idpessoa = pr_idpessoa;
    -- Busca o incapaz do responsavel legal 
    CURSOR cr_responsavel_2 IS
      SELECT idpessoa,
             nrseq_resp_legal,
             cdoperad_altera
        FROM tbcadast_pessoa_fisica_resp
       WHERE idpessoa_resp_legal = pr_idpessoa;
       
    -- Busca os dependentes (possui dependente)
    CURSOR cr_dependente IS
      SELECT idpessoa_dependente,
             tpdependente,
             nrseq_dependente,
             cdoperad_altera
        FROM tbcadast_pessoa_fisica_dep a
       WHERE idpessoa = pr_idpessoa;
    -- Busca os dependentes (é dependente)
    CURSOR cr_dependente_2 IS
      SELECT idpessoa,
             nrseq_dependente,
             cdoperad_altera
        FROM tbcadast_pessoa_fisica_dep
       WHERE idpessoa_dependente = pr_idpessoa;
      
    -- Busca o pai e a mae e o conjuge
    CURSOR cr_relacao IS
      SELECT a.idpessoa_relacao,
             a.tprelacao,
             a.nrseq_relacao,
             cdoperad_altera
        FROM tbcadast_pessoa_relacao a
       WHERE idpessoa = pr_idpessoa
         AND a.tprelacao IN (1,3,4); -- 1=Conjuge, 3=Pai, 4=Mae
    -- Busca os filhos
    CURSOR cr_relacao_2 IS
      SELECT idpessoa,
             nrseq_relacao,
             cdoperad_altera
        FROM tbcadast_pessoa_relacao
       WHERE idpessoa_relacao = pr_idpessoa
         AND tprelacao IN (3,4); -- Pai e Mae

    -- Busca a empresa do politico exposto
    CURSOR cr_polexp IS
      SELECT a.idpessoa_empresa,
             a.cdocupacao,
             cdoperad_altera
        FROM tbcadast_pessoa_polexp a
       WHERE idpessoa = pr_idpessoa
         AND a.tpexposto = 1; -- Exerce ou Exerceu
    -- Busca os politicos expostos que trabalham na empresa
    CURSOR cr_polexp_2 IS
      SELECT idpessoa,
             cdoperad_altera
        FROM tbcadast_pessoa_polexp a
       WHERE idpessoa_empresa = pr_idpessoa
         AND a.tpexposto = 1; -- Exerce ou Exerceu;
    -- Relacionado próximo com Ocupante Posição de Exposição Politica
    CURSOR cr_polexp_3 IS
      SELECT a.idpessoa_politico,
             a.tprelacao_polexp,
             cdoperad_altera
        FROM tbcadast_pessoa_polexp a
       WHERE idpessoa = pr_idpessoa
         AND a.tpexposto = 2; -- Relacionamento
    -- PEP com relacionamento próximo
    CURSOR cr_polexp_4 IS
      SELECT a.idpessoa,
             cdoperad_altera
        FROM tbcadast_pessoa_polexp a
       WHERE idpessoa_politico = pr_idpessoa
         AND a.tpexposto = 2; -- Relacionamento


    -- Cursor sobre os operadores
    CURSOR cr_operador IS
      SELECT d.idpessoa,
             d.cdoperad_altera
        FROM tbcadast_pessoa d,
             crapopi c,
             crapass b,
             tbcadast_pessoa a
       WHERE a.idpessoa = pr_idpessoa
         AND b.nrcpfcgc = a.nrcpfcgc
         AND b.dtdemiss IS NULL
         AND c.cdcooper = b.cdcooper
         AND c.nrdconta = b.nrdconta
         AND d.nrcpfcgc = c.nrcpfope;

    -- Cursor sobre os administrados financeiros
    CURSOR cr_operador_2 IS
      SELECT a.idpessoa,
             d.cdoperad_altera
        FROM tbcadast_pessoa d,
             crapopi c,
             crapass b,
             tbcadast_pessoa a
       WHERE d.idpessoa = pr_idpessoa
         AND b.nrcpfcgc = a.nrcpfcgc
         AND b.dtdemiss IS NULL
         AND c.cdcooper = b.cdcooper
         AND c.nrdconta = b.nrdconta
         AND d.nrcpfcgc = c.nrcpfope;



    -- Cursor para buscar o nome da pessoa
    CURSOR cr_pessoa(pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT nmpessoa FROM tbcadast_pessoa WHERE idpessoa = pr_idpessoa;
    rw_pessoa cr_pessoa%ROWTYPE;

    -- Variavel para a geracao do XML
    vr_clob        CLOB;
    vr_xml_temp    VARCHAR2(32726) := '';
    
    -- Variaveis de erro
    vr_dscritic VARCHAR2(500);
 
    -- Variaveis gerais
    vr_parametro   VARCHAR2(500);


  BEGIN

    -- Atualiza a variavel de parametros com ponto-e-virgula antes e depois
    vr_parametro := ';'||pr_tprelacao||';';
    
    -- Pessoa de Referência
    IF instr(vr_parametro,';10;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_referencia IN cr_referencia LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_referencia.idpessoa_referencia;
        vr_relacao(ind).cdoperad_altera := rw_referencia.cdoperad_altera;
        vr_relacao(ind).nrseq_relacao := rw_referencia.nrseq_referencia;
        vr_relacao(ind).tprelacao := 10; -- Pessoa de Referência
      END LOOP;
    END IF;
    -- Pessoa referenciada
    IF instr(vr_parametro,';11;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_referencia IN cr_referencia_2 LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_referencia.idpessoa;
        vr_relacao(ind).cdoperad_altera := rw_referencia.cdoperad_altera;
        vr_relacao(ind).nrseq_relacao := rw_referencia.nrseq_referencia;
        vr_relacao(ind).tprelacao := 11; -- Pessoa Referenciada
      END LOOP;  
    END IF; 

    -- Fonte de renda
    IF instr(vr_parametro,';20;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_renda IN cr_renda LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_renda.idpessoa_fonte_renda;
        vr_relacao(ind).cdoperad_altera := rw_renda.cdoperad_altera;
        vr_relacao(ind).nrseq_relacao := rw_renda.nrseq_renda;
        vr_relacao(ind).tprelacao := 20; -- Pessoa de Referência
      END LOOP;
    END IF;
    -- Colaboradores da empresa
    IF instr(vr_parametro,';21;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_renda IN cr_renda_2 LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_renda.idpessoa;
        vr_relacao(ind).cdoperad_altera := rw_renda.cdoperad_altera;
        vr_relacao(ind).nrseq_relacao := rw_renda.nrseq_renda;
        vr_relacao(ind).tprelacao := 21; -- Colaborador
      END LOOP;
    END IF;

    
    -- Representante legal
    IF instr(vr_parametro,';30;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_representante IN cr_representante LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_representante.idpessoa_representante;
        vr_relacao(ind).nrseq_relacao := rw_representante.nrseq_representante;
        vr_relacao(ind).cdoperad_altera := rw_representante.cdoperad_altera;
        vr_relacao(ind).tprelacao := 30; -- Representante legal
        vr_relacao(ind).tpnivel_relacao := rw_representante.tpcargo_representante;
      END LOOP;
    END IF;
    -- Representado legalmente
    IF instr(vr_parametro,';31;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_representante IN cr_representante_2 LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_representante.idpessoa;
        vr_relacao(ind).nrseq_relacao := rw_representante.nrseq_representante;
        vr_relacao(ind).cdoperad_altera := rw_representante.cdoperad_altera;
        vr_relacao(ind).tprelacao := 31; -- Representado legalmente
      END LOOP;
    END IF;

    
    -- Representado Societario
    IF instr(vr_parametro,';40;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_participacao IN cr_participacao LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_participacao.idpessoa_participacao;
        vr_relacao(ind).nrseq_relacao := rw_participacao.nrseq_participacao;
        vr_relacao(ind).cdoperad_altera := rw_participacao.cdoperad_altera;
        vr_relacao(ind).tprelacao := 40; -- Representado Societario
      END LOOP;
    END IF;
    -- Socio Participante
    IF instr(vr_parametro,';41;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_participacao IN cr_participacao_2 LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_participacao.idpessoa;
        vr_relacao(ind).nrseq_relacao := rw_participacao.nrseq_participacao;
        vr_relacao(ind).cdoperad_altera := rw_participacao.cdoperad_altera;
        vr_relacao(ind).tprelacao := 41; -- Socio participante
      END LOOP;
    END IF;

    
    -- Responsavel legal
    IF instr(vr_parametro,';50;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_responsavel IN cr_responsavel LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_responsavel.idpessoa_resp_legal;
        vr_relacao(ind).nrseq_relacao := rw_responsavel.nrseq_resp_legal;
        vr_relacao(ind).cdoperad_altera := rw_responsavel.cdoperad_altera;
        vr_relacao(ind).tprelacao := 50; -- Responsavel legal
        vr_relacao(ind).tpnivel_relacao := rw_responsavel.cdrelacionamento;
      END LOOP;
    END IF;
    -- Representado legal
    IF instr(vr_parametro,';51;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_responsavel IN cr_responsavel_2 LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_responsavel.idpessoa;
        vr_relacao(ind).cdoperad_altera := rw_responsavel.cdoperad_altera;
        vr_relacao(ind).nrseq_relacao := rw_responsavel.nrseq_resp_legal;
        vr_relacao(ind).tprelacao := 51; -- Representado legal
      END LOOP;
    END IF;


    -- Dependente (possui dependente)
    IF instr(vr_parametro,';60;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_dependente IN cr_dependente LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_dependente.idpessoa_dependente;
        vr_relacao(ind).nrseq_relacao := rw_dependente.nrseq_dependente;
        vr_relacao(ind).cdoperad_altera := rw_dependente.cdoperad_altera;
        vr_relacao(ind).tprelacao := 60; -- Dependente (possui dependente)
        vr_relacao(ind).tpnivel_relacao := rw_dependente.tpdependente;
      END LOOP;
    END IF;
    -- Responsável do Dependente
    IF instr(vr_parametro,';61;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_dependente IN cr_dependente LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_dependente.idpessoa_dependente;
        vr_relacao(ind).nrseq_relacao := rw_dependente.nrseq_dependente;
        vr_relacao(ind).cdoperad_altera := rw_dependente.cdoperad_altera;
        vr_relacao(ind).tprelacao := 61; -- Responsável do Dependente
      END LOOP;
    END IF;

    -- Pai, mae e conjuge
    IF instr(vr_parametro,';70;') > 0 OR instr(vr_parametro,';71;') > 0 OR instr(vr_parametro,';73;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_relacao IN cr_relacao LOOP
        IF (instr(vr_parametro,';70;') > 0 AND rw_relacao.tprelacao = 3) OR -- Pai
           (instr(vr_parametro,';71;') > 0 AND rw_relacao.tprelacao = 4) OR -- Mae
           (instr(vr_parametro,';73;') > 0 AND rw_relacao.tprelacao = 1) OR -- Conjuge
           pr_tprelacao IS NULL THEN
          -- Incrementa o indice
          ind := ind + 1;
          vr_relacao(ind).idpessoa  := rw_relacao.idpessoa_relacao;
          vr_relacao(ind).cdoperad_altera := rw_relacao.cdoperad_altera;
          vr_relacao(ind).nrseq_relacao := rw_relacao.nrseq_relacao;
          -- Se for pai
          IF rw_relacao.tprelacao = 3 THEN 
            vr_relacao(ind).tprelacao := 70; -- Pai
          -- Se for mae
          ELSIF rw_relacao.tprelacao = 4 THEN 
            vr_relacao(ind).tprelacao := 71; -- Mae
          ELSE -- Conjuge
            vr_relacao(ind).tprelacao := 73; -- Conjuge
          END IF;
        END IF;
      END LOOP;
    END IF;
    -- Filhos
    IF instr(vr_parametro,';72;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_relacao IN cr_relacao_2 LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_relacao.idpessoa;
        vr_relacao(ind).nrseq_relacao := rw_relacao.nrseq_relacao;
        vr_relacao(ind).cdoperad_altera := rw_relacao.cdoperad_altera;
        vr_relacao(ind).tprelacao := 72; -- Filhos
      END LOOP;
    END IF;


    -- Ocupa Posição de Exposição Politica
    IF instr(vr_parametro,';80;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_polexp IN cr_polexp LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_polexp.idpessoa_empresa;
        vr_relacao(ind).cdoperad_altera := rw_polexp.cdoperad_altera;
        vr_relacao(ind).tprelacao := 80; -- Ocupa Posição de Exposição Politica
        vr_relacao(ind).tpnivel_relacao := rw_polexp.cdocupacao;
      END LOOP;
    END IF;
    -- Tem membro PEP
    IF instr(vr_parametro,';81;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_polexp IN cr_polexp_2 LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_polexp.idpessoa;
        vr_relacao(ind).cdoperad_altera := rw_polexp.cdoperad_altera;
        vr_relacao(ind).tprelacao := 81; -- Tem membro PEP
      END LOOP;
    END IF;
    -- Relacionado próximo com Ocupante Posição de Exposição Politica
    IF instr(vr_parametro,';82;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_polexp IN cr_polexp_3 LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_polexp.idpessoa_politico;
        vr_relacao(ind).cdoperad_altera := rw_polexp.cdoperad_altera;
        vr_relacao(ind).tprelacao := 82; -- Relacionado próximo com Ocupante Posição de Exposição Politica
        vr_relacao(ind).tpnivel_relacao := rw_polexp.tprelacao_polexp;
      END LOOP;
    END IF;
    -- PEP com relacionamento próximo
    IF instr(vr_parametro,';83;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_polexp IN cr_polexp_4 LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_polexp.idpessoa;
        vr_relacao(ind).cdoperad_altera := rw_polexp.cdoperad_altera;
        vr_relacao(ind).tprelacao := 83; -- PEP com relacionamento próximo
      END LOOP;
    END IF;


    -- Mandato Financeiro
    IF instr(vr_parametro,';90;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_operador IN cr_operador LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_operador.idpessoa;
        vr_relacao(ind).cdoperad_altera := rw_operador.cdoperad_altera;
        vr_relacao(ind).tprelacao := 90; -- Mandato Financeiro
      END LOOP;  
    END IF;
    -- Administrado Financeiro
    IF instr(vr_parametro,';91;') > 0 OR pr_tprelacao IS NULL THEN
      FOR rw_operador IN cr_operador_2 LOOP
        -- Incrementa o indice
        ind := ind + 1;
        vr_relacao(ind).idpessoa  := rw_operador.idpessoa;
        vr_relacao(ind).cdoperad_altera := rw_operador.cdoperad_altera;
        vr_relacao(ind).tprelacao := 91; -- Mandato Financeiro
      END LOOP;
    END IF;

    -- Verifica se existe algum relacionamento
    IF vr_relacao.count > 0 THEN
      -- Monta documento XML
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
      -- Criar cabeçalho do XML
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="UTF-8"?><relacoes>'||chr(13)||
                                                   '<idpessoa_parametro>'||pr_idpessoa||'</idpessoa_parametro>'||chr(13));

      -- Loop sobre a pl/table para gerar o xml
      FOR x IN vr_relacao.first..vr_relacao.last LOOP
        OPEN cr_pessoa(vr_relacao(x).idpessoa);
        FETCH cr_pessoa INTO rw_pessoa;
        CLOSE cr_pessoa;
        -- gera o detalhe da relacao
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => 
                                 '<relacao>'||chr(13)||
                                 '  <idpessoa>'       ||vr_relacao(x).idpessoa ||'</idpessoa>' ||chr(13)||
                                 '  <nmpessoa>'       ||rw_pessoa.nmpessoa     ||'</nmpessoa>' ||chr(13)||
                                 '  <nrseq_relacao>'  ||vr_relacao(x).nrseq_relacao||'</nrseq_relacao>'||chr(13)||
                                 '  <cdoperad_altera>'||vr_relacao(x).cdoperad_altera||'</cdoperad_altera>'||chr(13)||
                                 '  <tprelacao>'      ||vr_relacao(x).tprelacao||'</tprelacao>'||chr(13)||
                                 '  <tpnivel_relacao>'||vr_relacao(x).tpnivel_relacao||'</tpnivel_relacao>'||chr(13)||
                                 '</relacao>'||chr(13));
      END LOOP;
      -- Finaliza o XML
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</relacoes>'
                             ,pr_fecha_xml => TRUE);
      
      -- Converte para XML
      pr_retorno := xmltype(vr_clob);
    END IF;
    
    
	EXCEPTION
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_retorna_relacionamentos: ' ||SQLERRM;
	END pc_retorna_relacionamentos;

  PROCEDURE pc_busca_parametro_tarifas(pr_cdcooper IN NUMBER
                                      ,pr_cdpartar IN NUMBER
                                      ,pr_vlparamt OUT VARCHAR2
                                      ,pr_dscritic OUT VARCHAR2) IS
    /* ..........................................................................
    --
    --  Programa : pc_busca_parametro_tarifas
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CADA
    --  Autor    : Vitor S. Assanuma (GFT)
    --  Data     : Março/2019.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para buscar os parametros cadastrados na CADPAR
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(500);

    -- Cursor dos parametros
    CURSOR cr_crappat IS
      SELECT dsconteu
      FROM   crappat pat
      INNER JOIN crappco pco ON pat.cdpartar = pco.cdpartar
      WHERE pco.cdcooper = pr_cdcooper
        AND pat.cdpartar = pr_cdpartar;
    rw_crappat cr_crappat%ROWTYPE;
  BEGIN
    -- Abre o cursor buscando o parametro
    OPEN cr_crappat;
    FETCH cr_crappat INTO rw_crappat;
    IF (cr_crappat%NOTFOUND) THEN
      CLOSE cr_crappat;
      vr_dscritic := 'Parametro não encontrado.';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crappat;
    -- Retorna o parametro encontrado
    pr_vlparamt := rw_crappat.dsconteu;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_busca_parametro_tarifas: ' || SQLERRM;
  END pc_busca_parametro_tarifas;

  PROCEDURE pc_busca_parametro_tarifas_web(pr_cdcooper IN NUMBER
                                          ,pr_cdpartar IN NUMBER
                                          ,pr_retorno   IN OUT NOCOPY xmltype
                                          ,pr_dscritic OUT VARCHAR2) IS
    /* ..........................................................................
    --
    --  Programa : pc_busca_parametro_tarifas_web
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CADA
    --  Autor    : Vitor S. Assanuma (GFT)
    --  Data     : Março/2019.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para buscar os parametros cadastrados na CADPAR
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(500);

    -- Retorno da procedure
    vr_vlparamt VARCHAR(500);
    BEGIN
      pc_busca_parametro_tarifas(pr_cdcooper => pr_cdcooper
                                ,pr_cdpartar => pr_cdpartar
                                ,pr_vlparamt => vr_vlparamt
                                ,pr_dscritic => vr_dscritic);
      IF (TRIM(vr_dscritic) IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                      '<root><vlparamt>'||vr_vlparamt||'</vlparamt>');
      pc_escreve_xml ('</root>',true);
      pr_retorno := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na pc_busca_parametro_tarifas_web: ' || SQLERRM;
  END pc_busca_parametro_tarifas_web;

  -- Busca a situação, canal e data de revisão das tabelas de TBCADAST
  PROCEDURE pc_busca_tbcadast(pr_nrcpfcgc IN NUMBER
                             ,pr_idseqttl IN NUMBER
                             ,pr_nmtabela IN VARCHAR2
                             -- OUT
                             ,pr_insituac OUT NUMBER
                             ,pr_dssituac OUT VARCHAR2
                             ,pr_idcanal  OUT NUMBER
                             ,pr_dscanal  OUT VARCHAR2
                             ,pr_dtrevisa OUT DATE
                             ,pr_dscritic OUT VARCHAR2) IS
  /* ..........................................................................
  --
  --  Programa : pc_busca_tbcadast
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CADA
  --  Autor    : Vitor S. Assanuma (GFT)
  --  Data     : Março/2019.                   Ultima atualizacao:
  --
  --  Dados referentes ao programa:
  --
  --   Frequencia: Sempre que for chamado
  --   Objetivo  : Rotina para buscar os dados das tabelas de cadastro para ser consumido no progress
  --
  --  Alteração :
  --
  --
  -- ..........................................................................*/
  --> Tratamento de erros
  vr_exc_erro EXCEPTION;
  vr_dscritic VARCHAR2(500);

  --> Variáveis locais
  vr_idpessoa tbcadast_pessoa.idpessoa%TYPE;

  --> Cursores
  -- Endereço
  CURSOR cr_tbendereco(pr_idpessoa IN tbcadast_pessoa.idpessoa%TYPE) IS
    SELECT
       tpe.idpessoa
      ,tpe.statusrevisao
      ,tds.dscodigo AS dssituacao
      ,tpe.idcanal
      ,tdc.dscodigo AS dscanal
      ,to_char(tpe.dtrevisao, 'DD/MM/YYYY') AS dtrevisao
    FROM
      tbcadast_pessoa_endereco tpe
    LEFT JOIN
      tbcadast_dominio_campo tdc ON tpe.idcanal = tdc.cddominio AND tdc.nmdominio = 'TBCADAST_CANAL'
    LEFT JOIN
      tbcadast_dominio_campo tds ON tpe.statusrevisao = tds.cddominio AND tds.nmdominio = 'TBCADAST_STATUSREVISAO'
    WHERE tpe.idpessoa       = pr_idpessoa
      AND tpe.nrseq_endereco = pr_idseqttl;
  rw_tbendereco cr_tbendereco%ROWTYPE;

  -- Telefone
  CURSOR cr_tbtelefone(pr_idpessoa IN tbcadast_pessoa.idpessoa%TYPE) IS
    SELECT
       tpf.idpessoa
      ,tpf.insituacao
      ,CASE WHEN tpf.insituacao = 1 THEN 'Ativo' ELSE 'Inativo' END AS dssituacao
      ,tpf.idcanal
      ,tdc.dscodigo AS dscanal
      ,to_char(tpf.dtrevisao, 'DD/MM/YYYY') AS dtrevisao
    FROM
      crapass ass
    JOIN 
      crapttl ttl ON ass.cdcooper = ttl.cdcooper AND ass.nrdconta = ttl.nrdconta AND ass.nrcpfcgc = ttl.nrcpfcgc
    JOIN 
      craptfc tfc ON ass.cdcooper = tfc.cdcooper AND ass.nrdconta = tfc.nrdconta AND ttl.idseqttl = tfc.idseqttl 
    JOIN 
      tbcadast_pessoa pes ON pes.nrcpfcgc = ass.nrcpfcgc
    JOIN 
      tbcadast_pessoa_telefone tpf ON pes.idpessoa = tpf.idpessoa AND tfc.nrtelefo = tpf.nrtelefone
    LEFT JOIN
      tbcadast_dominio_campo tdc ON tpf.idcanal = tdc.cddominio AND tdc.nmdominio = 'TBCADAST_CANAL'
    WHERE tpf.idpessoa       = pr_idpessoa
      AND tfc.cdseqtfc = pr_idseqttl;
  rw_tbtelefone cr_tbtelefone%ROWTYPE;

  -- Email
  CURSOR cr_tbemail(pr_idpessoa IN tbcadast_pessoa.idpessoa%TYPE) IS
    SELECT
       tpe.idpessoa
      ,tpe.insituacao
      ,CASE WHEN tpe.insituacao = 1 THEN 'Ativo' ELSE 'Inativo' END AS dssituacao
      ,tpe.idcanal
      ,tdc.dscodigo AS dscanal
      ,to_char(tpe.dtrevisao, 'DD/MM/YYYY') AS dtrevisao
    FROM
      tbcadast_pessoa_email tpe
    LEFT JOIN
      tbcadast_dominio_campo tdc ON tpe.idcanal = tdc.cddominio AND tdc.nmdominio = 'TBCADAST_CANAL'
    WHERE tpe.idpessoa       = pr_idpessoa
      AND tpe.nrseq_email = pr_idseqttl;
  rw_tbemail cr_tbemail%ROWTYPE;

  -- Renda
  CURSOR cr_tbrenda(pr_idpessoa IN tbcadast_pessoa.idpessoa%TYPE) IS
    SELECT
       tpr.idpessoa
      ,tpr.statusrevisao_renda
      ,tds.dscodigo AS dssituacao
      ,tpr.idcanal_renda   AS idcanal
      ,tdc.dscodigo        AS dscanal
      ,to_char(tpr.dtrevisao_renda, 'DD/MM/YYYY') AS dtrevisao
    FROM
      tbcadast_pessoa_renda tpr
    LEFT JOIN
      tbcadast_dominio_campo tdc ON tpr.idcanal_renda = tdc.cddominio AND tdc.nmdominio = 'TBCADAST_CANAL'
    LEFT JOIN
      tbcadast_dominio_campo tds ON tpr.statusrevisao_renda = tds.cddominio AND tds.nmdominio = 'TBCADAST_STATUSREVISAO'
    WHERE tpr.idpessoa       = pr_idpessoa
      AND tpr.nrseq_renda = pr_idseqttl;
  rw_tbrenda cr_tbrenda%ROWTYPE;

  -- Empresa
  CURSOR cr_tbempresa(pr_idpessoa IN tbcadast_pessoa.idpessoa%TYPE) IS
    SELECT
       tpr.idpessoa
      ,tpr.statusrevisao_empresa
      ,tds.dscodigo AS dssituacao
      ,tpr.idcanal_empresa   AS idcanal
      ,tdc.dscodigo          AS dscanal
      ,to_char(tpr.dtrevisao_empresa, 'DD/MM/YYYY') AS dtrevisao
    FROM
      tbcadast_pessoa_renda tpr
    LEFT JOIN
      tbcadast_dominio_campo tdc ON tpr.idcanal_empresa = tdc.cddominio AND tdc.nmdominio = 'TBCADAST_CANAL'
    LEFT JOIN
      tbcadast_dominio_campo tds ON tpr.statusrevisao_empresa = tds.cddominio AND tds.nmdominio = 'TBCADAST_STATUSREVISAO'
    WHERE tpr.idpessoa       = pr_idpessoa
      AND tpr.nrseq_renda = pr_idseqttl;
  rw_tbempresa cr_tbempresa%ROWTYPE;

  BEGIN
    -- Checa os parametros
    IF (pr_nrcpfcgc is NULL OR pr_idseqttl IS NULL OR pr_nmtabela IS NULL) THEN
      vr_dscritic := 'CPF, Sequencial ou Tabela esta vazio';
      RAISE vr_exc_erro;
    END IF;

    --Start dos outs
    pr_insituac := 1;
    pr_dssituac := 'Ativo';
    pr_idcanal  := 0;
    pr_dscanal  := '';

    --Busca a IDPESSOA pelo CPF
    SELECT idpessoa INTO vr_idpessoa FROM TBCADAST_PESSOA WHERE nrcpfcgc = pr_nrcpfcgc;
    IF vr_idpessoa IS NULL THEN
      vr_dscritic := 'Erro ao buscar a pessoa, pessoa nao encontrada';
      RAISE vr_exc_erro;
    END IF;

    -- Tratamento para cada tabela
    CASE UPPER(pr_nmtabela)
      WHEN 'ENDERECO' THEN
        OPEN cr_tbendereco(pr_idpessoa => vr_idpessoa);
        FETCH cr_tbendereco INTO rw_tbendereco;
        IF cr_tbendereco%NOTFOUND THEN
          CLOSE cr_tbendereco;
          RETURN;
        END IF;
        CLOSE cr_tbendereco;

        -- Retorno dos valores
        pr_insituac := rw_tbendereco.statusrevisao;
        pr_dssituac := rw_tbendereco.dssituacao;
        pr_idcanal  := NVL(rw_tbendereco.idcanal, 0);
        pr_dscanal  := rw_tbendereco.dscanal;
        pr_dtrevisa := TO_DATE(rw_tbendereco.dtrevisao, 'DD/MM/RRRR');
      WHEN 'TELEFONE' THEN
        OPEN cr_tbtelefone(pr_idpessoa => vr_idpessoa);
        FETCH cr_tbtelefone INTO rw_tbtelefone;
        IF cr_tbtelefone%NOTFOUND THEN
          CLOSE cr_tbtelefone;
          RETURN;
        END IF;
        CLOSE cr_tbtelefone;

        -- Retorno dos valores
        pr_insituac := rw_tbtelefone.insituacao;
        pr_dssituac := rw_tbtelefone.dssituacao;
        pr_idcanal  := NVL(rw_tbtelefone.idcanal, 0);
        pr_dscanal  := rw_tbtelefone.dscanal;
        pr_dtrevisa := TO_DATE(rw_tbtelefone.dtrevisao, 'DD/MM/RRRR');
      WHEN 'EMAIL' THEN
        OPEN cr_tbemail(pr_idpessoa => vr_idpessoa);
        FETCH cr_tbemail INTO rw_tbemail;
        IF cr_tbemail%NOTFOUND THEN
          CLOSE cr_tbemail;
          RETURN;
        END IF;
        CLOSE cr_tbemail;

        -- Retorno dos valores
        pr_insituac := rw_tbemail.insituacao;
        pr_dssituac := rw_tbemail.dssituacao;
        pr_idcanal  := NVL(rw_tbemail.idcanal, 0);
        pr_dscanal  := rw_tbemail.dscanal;
        pr_dtrevisa := TO_DATE(rw_tbemail.dtrevisao, 'DD/MM/RRRR');
     WHEN 'EMPRESA' THEN
        OPEN cr_tbempresa(pr_idpessoa => vr_idpessoa);
        FETCH cr_tbempresa INTO rw_tbempresa;
        IF cr_tbempresa%NOTFOUND THEN
          CLOSE cr_tbempresa;
          RETURN;
        END IF;
        CLOSE cr_tbempresa;

        -- Retorno dos valores
        pr_insituac := rw_tbempresa.statusrevisao_empresa;
        pr_dssituac := rw_tbempresa.dssituacao;
        pr_idcanal  := NVL(rw_tbempresa.idcanal, 0);
        pr_dscanal  := rw_tbempresa.dscanal;
        pr_dtrevisa := TO_DATE(rw_tbempresa.dtrevisao, 'DD/MM/RRRR');
      WHEN 'RENDA' THEN
        OPEN cr_tbrenda(pr_idpessoa => vr_idpessoa);
        FETCH cr_tbrenda INTO rw_tbrenda;
        IF cr_tbrenda%NOTFOUND THEN
          CLOSE cr_tbrenda;
          RETURN;
        END IF;
        CLOSE cr_tbrenda;

        -- Retorno dos valores
        pr_insituac := rw_tbrenda.statusrevisao_renda;
        pr_dssituac := rw_tbrenda.dssituacao;
        pr_idcanal  := NVL(rw_tbrenda.idcanal, 0);
        pr_dscanal  := rw_tbrenda.dscanal;
        pr_dtrevisa := TO_DATE(rw_tbrenda.dtrevisao, 'DD/MM/RRRR');
      ELSE
        vr_dscritic := 'Opcao de tabela nao encontrada';
        RAISE vr_exc_erro;
    END CASE;
  EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na pc_busca_tbcadast: ' || SQLERRM;
  END pc_busca_tbcadast;
END cada0012;
/
