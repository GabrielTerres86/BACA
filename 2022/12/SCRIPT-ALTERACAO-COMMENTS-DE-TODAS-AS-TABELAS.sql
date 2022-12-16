BEGIN
    --
	/* Alteração dos comments da tabela - HT_CONTRATACAO_CESTAS*/
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.HT_CONTRATACAO_CESTAS.IDCONTRATACAO_CESTAS IS ''Código Identificador do Histórico de Contratação de Cestas, codigo SYS_GUID definido pelo Oracle. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.HT_CONTRATACAO_CESTAS.CDCESTA IS ''Código da Cesta Contratada, representa o código de identificação da cesta contratada na conta do cooperado  no sistema. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.HT_CONTRATACAO_CESTAS.CDEMPRESA IS ''Código da empresa retornado pelo Topaz, representa o código de identificação da cooperativa cadastrada no Topaz, não sendo necessariamente o mesmo do Aimaro. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.HT_CONTRATACAO_CESTAS.DTHISCESTA IS ''Data da Cesta Contratada, essa data é utilizada para identificar em qual a data a cesta foi contratada  e passou a estar vigente na conta do cooperado. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.HT_CONTRATACAO_CESTAS.NRDCONTA IS ''Número da Conta, representa o numero da conta de movimentacao do cooperado. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON TABLE TARIFAS.HT_CONTRATACAO_CESTAS IS ''Definicao: Tabela de Históricos de Contratação de Cestas. Volumetria: Media, sem uma estimativa de crescimente, depende de vendas de cestas realizadas. Politica de Expurgo: Nao aplicada. #CLASSIFICACAO_DADO: I'' ';

	/* Alteração dos comments da tabela - HT_ESTORNO_BAIXA_TARIFA*/
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.HT_ESTORNO_BAIXA_TARIFA.IDESTORNO_BAIXA_TARIFA IS ''Codigo Identificador da Baixa ou Estorno da Tarifa, codigo SYS_GUID definido pelo Oracle. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.HT_ESTORNO_BAIXA_TARIFA.NRCONTA_BAIXA IS ''Numero da Conta do Cooperado que gerou a Baixa ou o Estorno da Tarifa. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.HT_ESTORNO_BAIXA_TARIFA.NRCOMPROVANTE_BAIXA IS ''Numero do Comprovante que foi gerado referente a Baixa ou Estorno da Tarifa. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.HT_ESTORNO_BAIXA_TARIFA.CDEMPRESA_BAIXA IS ''Codigo da Empresa referente em qual cooperativa a conta que originou a Baixa ou Estorno da Tarifa, esta vinculada. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.HT_ESTORNO_BAIXA_TARIFA.CDOPERADOR_BAIXA IS ''Codigo com a identificação do Operador que efetuou a Baixa ou Estorno da Tarifa. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.HT_ESTORNO_BAIXA_TARIFA.IDMOTIVO_ESTORNO IS ''Código referente ao Identificador do Motivo de Baixa ou Estorno da Tarifa. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.HT_ESTORNO_BAIXA_TARIFA.DHMOVIMENTACAO_BAIXA IS ''Data e Hora da Movimentacao da Baixa ou Estorno da Tarifa. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.HT_ESTORNO_BAIXA_TARIFA.TPSITUACAO_BAIXA IS ''Tipo da Situação do movimento:  Baixa ou Estorno da Tarifa sendo 1 - Estorno e 2 - Baixa. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.HT_ESTORNO_BAIXA_TARIFA.VLTARIFA_BAIXA IS ''Valor da Tarifa que foi baixado ou estornado. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON TABLE TARIFAS.HT_ESTORNO_BAIXA_TARIFA IS ''Definicao: Tabela Cadastro e registro do histórico de Baixas ou Estorno de Tarifas - utilizada para consulta e acompanhamento. Volumetria: Media, sem uma estimativa de crescimente, depende de negociacoes com o cooperado. Politica de Expurgo: Nao aplicada. #CLASSIFICACAO_DADO: I'' ';

	/* Alteração dos comments da tabela - TA_CESTA_PRODUTO*/
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_CESTA_PRODUTO.IDCESTA_PRODUTO IS ''Código Identificador da Cesta de Tarifas, codigo SYS_GUID definido pelo Oracle. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_CESTA_PRODUTO.CDCESTA IS ''Codigo da Cesta de tarifas, a cesta de tarifas é um conjunto de diferentes tarifas  que podem ter um valor diferenciado de cobrança e/ou uma gratuidade, com a intenção de beneficiar o cooperado que a contratar. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_CESTA_PRODUTO.NRDIACOBRANCA IS ''Dia que será efetuado a cobrança da Cesta de tarifas. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_CESTA_PRODUTO.NMTIPOCONTA IS IS ''Nomenclatura do tipo de conta vinculado a Cesta de Tarifas, nome pre definido no Topaz. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON TABLE TARIFAS.TA_CESTA_PRODUTO IS ''Definicao: Cadastro de Cesta de Tarifas. Volumetria: Baixa, sem uma estimativa de crescimente, depende da criacao de cesta para serem ofertadas ao cooperado. Politica de Expurgo: Nao aplicada. #CLASSIFICACAO_DADO: I'' ';

	/* Alteração dos comments da tabela - TA_GRUPO*/
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_GRUPO.IDGRUPO IS ''Codigo Identificador do Grupo, codigo SYS_GUID definido pelo Oracle. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_GRUPO.CDGRUPO IS ''Codigo do Grupo de Tarifas. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_GRUPO.DSGRUPO IS ''Descricao do Grupo de Tarifas. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON TABLE TARIFAS.TA_GRUPO IS ''Definicao: Tabela Cadastro de Grupos de Tarifas. Volumetria: Baixa, sem uma estimativa de crescimente. Politica de Expurgo: Nao aplicada. #CLASSIFICACAO_DADO: I'' ';

	/* Alteração dos comments da tabela - TA_MOTIVO_ESTORNO*/
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_MOTIVO_ESTORNO.IDMOTIVO_ESTORNO IS ''Codigo Identificador do Motivo de Estorno de Tarifas, codigo SYS_GUID definido pelo Oracle. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_MOTIVO_ESTORNO.DSMOTIVO_ESTORNO IS ''Descricao do Motivo de Estorno de Tarifas. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON TABLE TARIFAS.TA_MOTIVO_ESTORNO IS ''Definicao: Tabela Cadastro de Motivos de Baixa e Estorno de Tarifas. Volumetria: Baixa, sem uma estimativa de crescimente. Politica de Expurgo: Nao aplicada. #CLASSIFICACAO_DADO: I'' ';

	/* Alteração dos comments da tabela - TA_PARAMETRO_TARIFA_PRODUTO*/
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_PARAMETRO_TARIFA_PRODUTO.IDPARAMETRO_TARIFA_PRODUTO IS ''Identificacao unica do Cadastro de Parâmetros de Tarifas, codigo SYS_GUID definido pelo Oracle. #CLASSIFICACAO_DADO: I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_PARAMETRO_TARIFA_PRODUTO.CDTARIFA_PRODUTO IS ''Codigo de identificação de cada Tarifa, este código é gerado pelo Topaz. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_PARAMETRO_TARIFA_PRODUTO.DSTARIFA_PRODUTO IS ''Nome da tarifa utilizado para identificação descritiva. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_PARAMETRO_TARIFA_PRODUTO.IDCADASTRO_TARIFA IS ''Codigo Identificador do Cadastro de Tarifas FK da tabela TB_CADASTRO_TARIFA. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON TABLE TARIFAS.TA_PARAMETRO_TARIFA_PRODUTO IS ''Definicao: Cadastro de Parâmetros de Tarifas por Produtos. Volumetria: Baixa, sem uma estimativa de crescimente. Politica de Expurgo: Nao aplicada. #CLASSIFICACAO_DADO: I'' ';

	/* Alteração dos comments da tabela - TA_SUBGRUPO*/
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_SUBGRUPO.IDSUBGRUPO IS ''Codigo Identificador do SubGrupo de Tarifas o subgrupo de tarifas obrigatoriamente é vinculado a um grupo de tarifas principal, codigo SYS_GUID definido pelo Oracle. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_SUBGRUPO.IDGRUPO IS ''Codigo Identificador do Grupo de Tarifas. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_SUBGRUPO.CDSUBGRUPO IS ''Codigo do SubGrupo de Tarifas. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TA_SUBGRUPO.DSSUBGRUPO IS ''Descricao do SubGrupo de Tarifas. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON TABLE TARIFAS.TA_SUBGRUPO IS ''Definicao: Tabela de Cadastro de SubGrupos de Tarifas. Volumetria: Baixa, sem uma estimativa de crescimente. Politica de Expurgo: Nao aplicada. #CLASSIFICACAO_DADO: I'' ';

	/* Alteração dos comments da tabela - TB_CADASTRO_TARIFA*/
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_CADASTRO_TARIFA.IDCADASTRO_TARIFA IS ''Identificacao unica do cadastro de tarfias, codigo SYS_GUID definido pelo Oracle. #CLASSIFICACAO_DADO: I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_CADASTRO_TARIFA.CDTARIFA IS ''Codigo de identificação de cada Tarifa, este código é gerado pelo Topaz. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_CADASTRO_TARIFA.DSTARIFA IS ''Nome da tarifa utilizado para identificação descritiva. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_CADASTRO_TARIFA.IDGRUPO IS ''Codigo Identificador do Grupo de Tarifas. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_CADASTRO_TARIFA.IDSUBGRUPO IS ''Codigo Identificador do SubGrupo de Tarifas. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_CADASTRO_TARIFA.FLSITUACAO IS ''Tipo de Situacao da Tarifa (0 - Inativa | 1 - Ativa). #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_CADASTRO_TARIFA.TPPERFIL IS ''Tipo do Perfil da Tarifa relacionado ao perfil do cooperado (1 - Pessoa Fisica | 2 - Pessoa Juridica | 3 - Entidade Publica). #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_CADASTRO_TARIFA.CDBACEN IS ''Codigo do BACEN - Identificação da tarifa no Banco Central. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_CADASTRO_TARIFA.FLTARIFA IS ''Tipo de Tarifa (0 - Manual | 1 - Automatica). #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_CADASTRO_TARIFA.DSFATOGERADOR IS ''Descricao do Fato Gerador. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_CADASTRO_TARIFA.CDREFERENCIA IS ''Codigo de Referencia cadastrado no Aimaro. #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_CADASTRO_TARIFA.FLTARIFAPA IS ''Tipo de atualizacao da tarifa (0 - Nao Atualizada no PA | 1 - Atualizada no PA). #CLASSIFICACAO_DADO:I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON TABLE TARIFAS.TB_CADASTRO_TARIFA IS ''Definicao: Cadastro de Tarifas. Volumetria: Baixa, sem uma estimativa de crescimente. Politica de Expurgo: Nao aplicada. #CLASSIFICACAO_DADO: I'' ';

	/* Alteração dos comments da tabela - TB_PARAMETRO_TARIFA_COOPERATIVA*/
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_PARAMETRO_TARIFA_COOPERATIVA.IDPARAMETRO_TARIFA_COOPERATIVA IS ''Identificacao unica do cadastro de informações de parâmetros de tarifas por cooperativa, codigo SYS_GUID definido pelo Oracle. #CLASSIFICACAO_DADO: I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_PARAMETRO_TARIFA_COOPERATIVA.CDCOOPERATIVA IS ''Codigo da cooperativa que est[a sendo registrado as informações de parâmetros de tarifas por cooperativa. #CLASSIFICACAO_DADO: I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_PARAMETRO_TARIFA_COOPERATIVA.PERIODORENOVACAOCDC IS ''Periodo de renovacao do CDC podendo ser ANUL, SEMESTRAL ou MENSAL. #CLASSIFICACAO_DADO: I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_PARAMETRO_TARIFA_COOPERATIVA.CDOPERADOR IS ''Codigo do operador de cadastro as informacoes referente as informações de parâmetros de tarifas por cooperativa. #CLASSIFICACAO_DADO: I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_PARAMETRO_TARIFA_COOPERATIVA.DHATUALIZACAO IS ''Data e hora de atualizacao do registro de informações de parâmetros de tarifas por cooperativa. #CLASSIFICACAO_DADO: I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON COLUMN TARIFAS.TB_PARAMETRO_TARIFA_COOPERATIVA.DHATUALIZACAO IS ''Data e hora de registro na base de dados. #CLASSIFICACAO_DADO: I'' ';
	EXECUTE IMMEDIATE 'COMMENT ON TABLE TARIFAS.TB_PARAMETRO_TARIFA_COOPERATIVA IS ''Definicao: Tabela Cadastro de informações de parâmetros de tarifas por cooperativa. Volumetria: 13 registros, sem estimativa de crescimento. Politica de Expurgo: Nao aplicada. #CLASSIFICACAO_DADO: I'' ';
    --
    COMMIT;
    --
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK; 
END;
/	