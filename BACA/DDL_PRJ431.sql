-- Comandos DDL referente ao PRJ431

-- -----------------------------------------
-- Criação da tabela de domínio da Cobrança
-- -----------------------------------------
-- Create table
create table CECRED.TBCOBRAN_DOMINIO_CAMPO
(
  nmdominio VARCHAR2(30) not null,
  cddominio VARCHAR2(10) not null,
  dscodigo  VARCHAR2(100) not null
)
tablespace TBS_CADASTRO_D
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  )
compress for all operations;
-- Add comments to the table 
comment on table CECRED.TBCOBRAN_DOMINIO_CAMPO
  is 'Tabela de dominios dos campos do modulo COBRANCA';
-- Add comments to the columns 
comment on column CECRED.TBCOBRAN_DOMINIO_CAMPO.nmdominio
  is 'Nome do campo dominio';
comment on column CECRED.TBCOBRAN_DOMINIO_CAMPO.cddominio
  is 'Codigo do dominio';
comment on column CECRED.TBCOBRAN_DOMINIO_CAMPO.dscodigo
  is 'Descricao do codigo dominio';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CECRED.TBCOBRAN_DOMINIO_CAMPO
  add constraint TBCOBRAN_DOMINIO_CAMPO_PK primary key (NMDOMINIO, CDDOMINIO)
  using index 
  tablespace TBS_GERAL_D
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

-- ---------------------------------------------------------------------------------
-- Criação das tabelas referente ao workflow de aprovação dos convênios de cobrança
-- ---------------------------------------------------------------------------------
-- Create table
CREATE TABLE cecred.tbrecip_param_workflow
(
  cdcooper                 NUMBER(10) NOT NULL
 ,cdalcada_aprovacao       NUMBER(10) NOT NULL
 ,flregra_aprovacao        NUMBER(1)  NOT NULL DEFAULT 0
 ,flcadastra_aprovador     NUMBER(1)  NOT NULL
);

-- Add comments to the table 
comment on table cecred.tbrecip_param_workflow
              is 'Configuração das alçadas de aprovação dos convênios de cobrança.';
-- Add comments to the columns 
comment on column cecred.tbrecip_param_workflow.cdcooper
              is 'Código que identifica a Cooperativa.';
comment on column cecred.tbrecip_param_workflow.cdalcada_aprovacao
              is 'Código das alçadas de aprovação.';
comment on column cecred.tbrecip_param_workflow.flregra_aprovacao
              is 'Flag de regras de aprovação (0=Não/1=Sim).';
comment on column cecred.tbrecip_param_workflow.flcadastra_aprovador
              is 'Flag para permitir o cadastro de mais de um aprovador por alçada (0=Não/1=Sim).';

-- Create/Recreate primary, unique and foreign key constraints 
alter table cecred.tbrecip_param_workflow
  add constraint tbrecip_param_workflow_pk primary KEY(cdcooper, cdalcada_aprovacao);

-- Create table
CREATE TABLE cecred.tbrecip_param_aprovador
(
  cdcooper                 NUMBER(10)   NOT NULL
 ,cdalcada_aprovacao       NUMBER(10)   NOT NULL
 ,cdaprovador              VARCHAR2(10) NOT NULL
);

-- Add comments to the table 
comment on table cecred.tbrecip_param_aprovador
              is 'Configuração dos aprovadores por alçadas de aprovação dos convênios de cobrança.';

-- Add comments to the columns 
comment on column cecred.tbrecip_param_aprovador.cdcooper
              is 'Código que identifica a Cooperativa.';
comment on column cecred.tbrecip_param_aprovador.cdalcada_aprovacao
              is 'Código das alçadas de aprovação.';
comment on column cecred.tbrecip_param_aprovador.cdaprovador
              is 'Código do usuário do aprovador.';

-- Create/Recreate primary, unique and foreign key constraints 
alter table cecred.tbrecip_param_aprovador
  add constraint tbrecip_param_aprovador_pk primary KEY(cdcooper, cdalcada_aprovacao, cdaprovador);

alter table cecred.tbrecip_param_aprovador
  add constraint tbrecip_param_aprovador_fk foreign KEY(cdcooper, cdalcada_aprovacao)
  references cecred.tbrecip_param_workflow(cdcooper, cdalcada_aprovacao);

-- Create table
CREATE TABLE cecred.tbrecip_aprovador_calculo
(
  cdcooper                 NUMBER(10)   NOT NULL
 ,cdalcada_aprovacao       NUMBER(10)   NOT NULL
 ,idcalculo_reciproci      NUMBER(10)   NOT NULL
 ,cdaprovador              VARCHAR2(10) NOT NULL
 ,idstatus                 VARCHAR2(1)  NOT NULL
 ,dtalteracao_status       DATE         NOT NULL
};

-- Add comments to the table 
comment on table cecred.tbrecip_aprovador_calculo
              is 'Aprovações por cooperativa, alçada e cálculo de reciprocidade.';

-- Add comments to the columns 
comment on column cecred.tbrecip_aprovador_calculo.cdcooper
              is 'Código que identifica a Cooperativa.';
comment on column cecred.tbrecip_aprovador_calculo.cdalcada_aprovacao
              is 'Código das alçadas de aprovação.';
comment on column cecred.tbrecip_aprovador_calculo.idcalculo_reciproci
              is 'ID único do cálculo de reciprocidade atrelado a contratação.';
comment on column cecred.tbrecip_aprovador_calculo.cdaprovador
              is 'Código do usuário do aprovador.';
comment on column cecred.tbrecip_aprovador_calculo.idstatus
              is 'Status da avaliação do aprovador (A=Aprovado, R=Rejeitado).';
comment on column cecred.tbrecip_aprovador_calculo.dtalteracao_status
              is 'Data da avaliação do aprovador.';

-- Create/Recreate primary, unique and foreign key constraints 
alter table cecred.tbrecip_aprovador_calculo
  add constraint tbrecip_aprovador_calculo_pk primary KEY(cdcooper, cdalcada_aprovacao, idcalculo_reciproci, cdaprovador);

alter table cecred.tbrecip_aprovador_calculo
  add constraint tbrecip_aprovador_calculo_fk1 foreign KEY(cdcooper, cdalcada_aprovacao, cdaprovador)
  references cecred.tbrecip_param_aprovador(cdcooper, cdalcada_aprovacao, cdaprovador);

alter table cecred.tbrecip_aprovador_calculo
  add constraint tbrecip_aprovador_calculo_fk2 foreign KEY(idcalculo_reciproci)
  references cecred.tbrecip_calculo(idcalculo_reciproci);

-- ------------------------------------------------
-- Alteração da tabela de cálculo da reciprocidade
-- ------------------------------------------------

-- Alter table
ALTER TABLE tbrecip_calculo
        ADD(idfim_contrato             NUMBER(2)
					 ,vldesconto_adicional_coo   NUMBER(18,2)
					 ,idfim_desc_adicional_coo   NUMBER(2)
					 ,vldesconto_adicional_cee   NUMBER(18,2)
					 ,idfim_desc_adicional_cee   NUMBER(2)
					 ,dtinicio_vigencia_contrato DATE
					 ,dtfim_vigencia_contrato    DATE
				   );

-- Add comments to the columns 
comment on column cecred.tbrecip_calculo.idfim_contrato
  is 'Identificador da quantidade de meses para o fim de vigência do contrato';
comment on column cecred.tbrecip_calculo.vldesconto_adicional_coo
  is 'Valor de desconto adicional COO';
comment on column cecred.tbrecip_calculo.idfim_desc_adicional_coo
  is 'Identificador da quantidade de meses para o fim de vigência do desconto adicional COO';
comment on column cecred.tbrecip_calculo.vldesconto_adicional_cee
  is 'Valor de desconto adicional CEE';
comment on column cecred.tbrecip_calculo.idfim_desc_adicional_cee
  is 'Identificador da quantidade de meses para o fim de vigência do desconto adicional CEE';
comment on column cecred.tbrecip_calculo.dtinicio_vigencia_contrato
  is 'Data de início de vigência do contrato.';
comment on column cecred.tbrecip_calculo.dtfim_vigencia_contrato
  is 'Data do fim da vigência do contrato.';

-- -------------------------------------------------------
-- Alteração da tabela de parametrização da reciprocidade
-- -------------------------------------------------------

-- Create table
CREATE TABLE cecred.tbrecip_vinculacao_parame
(
  idparame_reciproci       NUMBER(10)   NOT NULL
 ,idvinculacao_reciproci   NUMBER(2)    NOT NULL
 ,tpindicador              VARCHAR2(1)  NOT NULL
 ,vlpercentual_vinculacao  NUMBER(10,2)
 ,flgativo                 NUMBER(1)    DEFAULT 1 NOT NULL
};

-- Add comments to the table 
comment on table cecred.tbrecip_vinculacao_parame
              is 'Parametrização dos graus de vinculação.';
-- Add comments to the columns 
comment on column cecred.tbrecip_vinculacao_parame.idparame_reciproci
              is 'ID único da parametrização de cálculo.';
comment on column cecred.tbrecip_vinculacao_parame.idvinculacao_reciproci
              is 'ID do grau de vinculação.';
comment on column cecred.tbrecip_vinculacao_parame.tpindicador
              is 'Tipo do Indicador de Reciprocidade (A=Adesão/Q=Quantidade/M=Moeda).';
comment on column cecred.tbrecip_vinculacao_parame.vlpercentual_vinculacao
              is 'Percentual do grau de vinculação.';
comment on column cecred.tbrecip_vinculacao_parame.flgativo
              is 'Flag de ativação ou não da vinculação.';

-- Create/Recreate primary, unique and foreign key constraints 
alter table cecred.tbrecip_vinculacao_parame
  add constraint tbrecip_vinculacao_parame_pk primary KEY(idparame_reciproci, idvinculacao_reciproci);

alter table cecred.tbrecip_vinculacao_parame
  add constraint tbrecip_vinculacao_parame_fk foreign KEY(idparame_reciproci)
  references cecred.tbrecip_parame_calculo(idparame_reciproci);

-- Alter table
ALTER TABLE tbrecip_parame_calculo
        ADD(vlcusto_cee      NUMBER(18,2)
				   ,vlcusto_coo      NUMBER(18,2)
					 ,vlpeso_boleto    NUMBER(10,2)
					 ,vlpeso_adicional NUMBER(10,2)
				   );

-- Add comments to the columns 
comment on column cecred.tbrecip_parame_calculo.vlcusto_cee
  is 'Valor de custo quando o Cooperado emite e expede.';
comment on column cecred.tbrecip_parame_calculo.vlcusto_coo
  is 'Valor de custo quando a Cooperativa emite e expede.';
comment on column cecred.tbrecip_parame_calculo.vlpeso_boleto
  is 'Percentual de peso do boleto no cálculo de reciprocidade.';
comment on column cecred.tbrecip_parame_calculo.vlpeso_adicional
  is 'Percentual de peso do adicional no cálculo de reciprocidade.';
