------ Tabela de parametros de envio de cartao para endereco do cooperado ------ 

CREATE TABLE CECRED.TBCRD_ENVIO_CARTAO
  (
    cdcooper                NUMBER(5) NOT NULL,
	idfuncionalidade        NUMBER(5) NOT NULL,
	flghabilitar			NUMBER(1) NOT NULL,
    dtatualizacao	        DATE NOT NULL,
	cdoperador	            VARCHAR2(10) NOT NULL
  );
  
COMMENT ON TABLE CECRED.TBCRD_ENVIO_CARTAO IS 
'Tabela de parametrizacao de entrega de cartao para o cooperado';
  
COMMENT ON COLUMN CECRED.TBCRD_ENVIO_CARTAO.cdcooper IS 
'Codigo da cooperativa';

COMMENT ON COLUMN CECRED.TBCRD_ENVIO_CARTAO.idfuncionalidade IS 
'ID da funcionalidade para ligacao com a tabela filha (buscar descricao pelo dominio)';

COMMENT ON COLUMN CECRED.TBCRD_ENVIO_CARTAO.flghabilitar IS 
'Flag de habilitar a cooperativa e PAs para envio do cartao ao endereco do cooperado';

COMMENT ON COLUMN CECRED.TBCRD_ENVIO_CARTAO.dtatualizacao IS 
'Data de atualizacao das informacoes de parametrizacao';

COMMENT ON COLUMN CECRED.TBCRD_ENVIO_CARTAO.cdoperador IS 
'Usuario que realizou a atualizacao das informacoes de parametrizacao';

ALTER TABLE CECRED.TBCRD_ENVIO_CARTAO ADD CONSTRAINT TBCRD_ENVIO_CARTAO_PK PRIMARY KEY (cdcooper, idfuncionalidade);


------ Tabela filha de relacionamento de parametros de entrega de cartao por produto: funcionalidade x tipo de envio por cooperativa ------

CREATE TABLE CECRED.TBCRD_TIPO_ENVIO_CARTAO
  (
    cdcooper                NUMBER(5) NOT NULL,
	idfuncionalidade        NUMBER(5) NOT NULL,
	idtipoenvio				NUMBER(5) NOT NULL
  );
  
COMMENT ON TABLE CECRED.TBCRD_TIPO_ENVIO_CARTAO IS 
'Tabela filha de relacionamento de parametros de entrega de cartao por produto: funcionalidade x tipo de envio por cooperativa';
  
COMMENT ON COLUMN CECRED.TBCRD_TIPO_ENVIO_CARTAO.cdcooper IS 
'Codigo da cooperativa';

COMMENT ON COLUMN CECRED.TBCRD_TIPO_ENVIO_CARTAO.idfuncionalidade IS 
'ID da funcionalidade (buscar descricao pelo dominio: envio de cartao de credito para endereco, envio de talionario...)';

COMMENT ON COLUMN CECRED.TBCRD_TIPO_ENVIO_CARTAO.idtipoenvio IS 
'ID do tipo de envio/endereco (buscar descricao pelo dominio: TPENDERECO. Ex.: residencial, comercial...)';

ALTER TABLE CECRED.TBCRD_TIPO_ENVIO_CARTAO ADD CONSTRAINT TBCRD_TIPO_ENVIO_CARTAO_PK PRIMARY KEY (cdcooper, idfuncionalidade, idtipoenvio);

ALTER TABLE CECRED.TBCRD_TIPO_ENVIO_CARTAO
  ADD CONSTRAINT TBCRD_TIPO_ENVIO_CARTAO_FK1 FOREIGN KEY (cdcooper, idfuncionalidade)
  REFERENCES CECRED.TBCRD_ENVIO_CARTAO (cdcooper, idfuncionalidade);


------ Tabela auxiliar para lista de PAs que podem ou nao enviar ------

CREATE TABLE CECRED.TBCRD_PA_ENVIO_CARTAO
  (
	cdcooper                NUMBER(5) NOT NULL,
	idfuncionalidade        NUMBER(5) NOT NULL,
	idtipoenvio				NUMBER(5) NOT NULL,
	cdagencia				NUMBER(5) NOT NULL,
	dtatualizacao	        DATE NOT NULL,
	cdoperador	            VARCHAR2(10) NOT NULL
  );
  
COMMENT ON TABLE CECRED.TBCRD_PA_ENVIO_CARTAO IS 
'Tabela filha auxiliar de relacionamento parametrizacao da lista de PAs para entrega de cartao ao cooperado (podem ou nao enviar ao endereco do cooperado)';

COMMENT ON COLUMN CECRED.TBCRD_PA_ENVIO_CARTAO.cdcooper IS 
'Codigo da cooperativa';

COMMENT ON COLUMN CECRED.TBCRD_PA_ENVIO_CARTAO.idfuncionalidade IS 
'ID da funcionalidade para ligacao com a tabela pai (buscar descricao pelo dominio)';

COMMENT ON COLUMN CECRED.TBCRD_PA_ENVIO_CARTAO.idtipoenvio IS 
'ID do tipo de envio/endereco com a tabela pai (buscar descricao pelo dominio: TPENDERECO. Ex.: residencial, comercial...)';
  
COMMENT ON COLUMN CECRED.TBCRD_PA_ENVIO_CARTAO.cdagencia IS 
'Codigo da agencia/PA';

COMMENT ON COLUMN CECRED.TBCRD_PA_ENVIO_CARTAO.dtatualizacao IS 
'Data de atualizacao das informacoes de parametrizacao da lista de PAs';

COMMENT ON COLUMN CECRED.TBCRD_PA_ENVIO_CARTAO.cdoperador IS 
'Usuario que realizou a atualizacao das informacoes de parametrizacao da lista de PAs';

ALTER TABLE CECRED.TBCRD_PA_ENVIO_CARTAO ADD CONSTRAINT TBCRD_PA_ENVIO_CARTAO_PK PRIMARY KEY (cdcooper, idfuncionalidade, idtipoenvio, cdagencia);

ALTER TABLE CECRED.TBCRD_PA_ENVIO_CARTAO
  ADD CONSTRAINT TBCRD_PA_ENVIO_CARTAO_FK1 FOREIGN KEY (cdcooper, idfuncionalidade, idtipoenvio)
  REFERENCES CECRED.TBCRD_TIPO_ENVIO_CARTAO (cdcooper, idfuncionalidade, idtipoenvio);


------ Tabela de historico de enderecos --------

CREATE TABLE CECRED.TBCRD_ENDERECO_ENTREGA
  (
    cdcooper               NUMBER(5) NOT NULL,
	nrdconta			   NUMBER(10) NOT NULL,
	nrctrcrd			   NUMBER(10) NOT NULL,
	idtipoenvio			   NUMBER(5) NOT NULL,
	nmlogradouro           VARCHAR2(60),
	nrlogradouro           NUMBER(10),
	dscomplemento          VARCHAR2(60),
	nmbairro               VARCHAR2(40),
	idcidade               NUMBER(10),
	nrcep                  NUMBER(10)
  );
  
COMMENT ON TABLE CECRED.TBCRD_ENDERECO_ENTREGA IS 
'Tabela de historico de enderecos dos cooperados para envio do cartao';

COMMENT ON COLUMN CECRED.TBCRD_ENDERECO_ENTREGA.cdcooper IS 
'Codigo da cooperativa';

COMMENT ON COLUMN CECRED.TBCRD_ENDERECO_ENTREGA.nrdconta IS 
'Numero da conta do cooperado';
  
COMMENT ON COLUMN CECRED.TBCRD_ENDERECO_ENTREGA.nrctrcrd IS 
'Numero da proposta da solicitacao de cartao';

COMMENT ON COLUMN CECRED.TBCRD_ENDERECO_ENTREGA.idtipoenvio IS 
'ID do tipo de envio/endereco com a tabela pai (buscar descricao pelo dominio: TPENDERECO. Ex.: residencial, comercial...)';

COMMENT ON COLUMN CECRED.TBCRD_ENDERECO_ENTREGA.nmlogradouro IS
'Nome do logradouro/endereco';
  
COMMENT ON COLUMN CECRED.TBCRD_ENDERECO_ENTREGA.nrlogradouro IS
'Numero do logradouro/endereco';
  
COMMENT ON COLUMN CECRED.TBCRD_ENDERECO_ENTREGA.dscomplemento IS
'Complemento do logradouro/endereco';
  
COMMENT ON COLUMN CECRED.TBCRD_ENDERECO_ENTREGA.nmbairro IS
'Nome do bairro';
  
COMMENT ON COLUMN CECRED.TBCRD_ENDERECO_ENTREGA.idcidade IS
'Identificador unico do registro de cidade (FK crapmun)';
  
COMMENT ON COLUMN CECRED.TBCRD_ENDERECO_ENTREGA.nrcep IS
'Numero do CEP';

ALTER TABLE CECRED.TBCRD_ENDERECO_ENTREGA ADD CONSTRAINT TBCRD_ENDERECO_ENTREGA_PK PRIMARY KEY (cdcooper, nrdconta, nrctrcrd);


------ Tabela de estrutura de termos --------

CREATE TABLE CECRED.TBGEN_VERSAO_TERMO
  (
    cdcooper               NUMBER(5) NOT NULL,
	dschave_versao		   VARCHAR(50) NOT NULL,
	dtinicio_vigencia	   DATE NOT NULL,
	dtfim_vigencia	   	   DATE,
	dsnome_jasper		   VARCHAR(100) NOT NULL,
	dtcadastro			   DATE,
	dsdescricao			   VARCHAR2(200)
  );
  
COMMENT ON TABLE CECRED.TBGEN_VERSAO_TERMO IS 
'Tabela generica de parametrizacao de termos/relatorios/contratos entre outros';

COMMENT ON COLUMN CECRED.TBGEN_VERSAO_TERMO.cdcooper IS 
'Codigo da cooperativa';
  
COMMENT ON COLUMN CECRED.TBGEN_VERSAO_TERMO.dschave_versao IS 
'Identificador/chave unica para versao do termo/relatorio/contrato';

COMMENT ON COLUMN CECRED.TBGEN_VERSAO_TERMO.dtinicio_vigencia IS 
'Data de inicio da vigencia do termo/relatorio/contrato';

COMMENT ON COLUMN CECRED.TBGEN_VERSAO_TERMO.dtfim_vigencia IS 
'Data fim da vigencia do termo/relatorio/contrato (opcional)';

COMMENT ON COLUMN CECRED.TBGEN_VERSAO_TERMO.dsnome_jasper IS 
'Nome do fonte jasper do termo/relatorio/contrato';

COMMENT ON COLUMN CECRED.TBGEN_VERSAO_TERMO.dtcadastro IS 
'Data de cadastro do termo/relatorio/contrato (opcional)';

COMMENT ON COLUMN CECRED.TBGEN_VERSAO_TERMO.dsdescricao IS 
'Breve descricao do termo/relatorio/contrato (opcional)';

ALTER TABLE CECRED.TBGEN_VERSAO_TERMO ADD CONSTRAINT TBGEN_VERSAO_TERMO_PK PRIMARY KEY (cdcooper, dschave_versao, dtinicio_vigencia);