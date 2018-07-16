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
              is 'Configuracao das alcadas de aprovacao dos convênios de cobranca.';
-- Add comments to the columns 
comment on column cecred.tbrecip_param_workflow.cdcooper
              is 'Codigo que identifica a Cooperativa.';
comment on column cecred.tbrecip_param_workflow.cdalcada_aprovacao
              is 'Codigo das alcadas de aprovacao.';
comment on column cecred.tbrecip_param_workflow.flregra_aprovacao
              is 'Flag de regras de aprovacao (0=Nao/1=Sim).';
comment on column cecred.tbrecip_param_workflow.flcadastra_aprovador
              is 'Flag para permitir o cadastro de mais de um aprovador por alcada (0=Nao/1=Sim).';

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
              is 'Configuracao dos aprovadores por alcadas de aprovacao dos convenios de cobranca.';

-- Add comments to the columns 
comment on column cecred.tbrecip_param_aprovador.cdcooper
              is 'Codigo que identifica a Cooperativa.';
comment on column cecred.tbrecip_param_aprovador.cdalcada_aprovacao
              is 'Codigo das alcadas de aprovacao.';
comment on column cecred.tbrecip_param_aprovador.cdaprovador
              is 'Codigo do usuario do aprovador.';

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
              is 'Aprovacoes por cooperativa, alcada e calculo de reciprocidade.';

-- Add comments to the columns 
comment on column cecred.tbrecip_aprovador_calculo.cdcooper
              is 'Codigo que identifica a Cooperativa.';
comment on column cecred.tbrecip_aprovador_calculo.cdalcada_aprovacao
              is 'Codigo das alcadas de aprovacao.';
comment on column cecred.tbrecip_aprovador_calculo.idcalculo_reciproci
              is 'ID unico do calculo de reciprocidade atrelado a contratacao.';
comment on column cecred.tbrecip_aprovador_calculo.cdaprovador
              is 'Codigo do usuario do aprovador.';
comment on column cecred.tbrecip_aprovador_calculo.idstatus
              is 'Status da avaliacao do aprovador (A=Aprovado, R=Rejeitado).';
comment on column cecred.tbrecip_aprovador_calculo.dtalteracao_status
              is 'Data da avaliacao do aprovador.';

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
  is 'Identificador da quantidade de meses para o fim de vigencia do contrato';
comment on column cecred.tbrecip_calculo.vldesconto_adicional_coo
  is 'Valor de desconto adicional COO';
comment on column cecred.tbrecip_calculo.idfim_desc_adicional_coo
  is 'Identificador da quantidade de meses para o fim de vigencia do desconto adicional COO';
comment on column cecred.tbrecip_calculo.vldesconto_adicional_cee
  is 'Valor de desconto adicional CEE';
comment on column cecred.tbrecip_calculo.idfim_desc_adicional_cee
  is 'Identificador da quantidade de meses para o fim de vigencia do desconto adicional CEE';
comment on column cecred.tbrecip_calculo.dtinicio_vigencia_contrato
  is 'Data de inicio de vigencia do contrato.';
comment on column cecred.tbrecip_calculo.dtfim_vigencia_contrato
  is 'Data do fim da vigencia do contrato.';

-- ---------------------------------------------------------
-- Alteração das tabelas de parametrização da reciprocidade
-- ---------------------------------------------------------

-- Create table
CREATE TABLE cecred.tbrecip_vinculacao_parame
(
  idparame_reciproci       NUMBER(10)   NOT NULL
 ,idvinculacao_reciproci   NUMBER(2)    NOT NULL
 ,tpindicador              VARCHAR2(1)  NOT NULL
 ,vlpercentual_vinculacao  NUMBER(5,2)
 ,flgativo                 NUMBER(1)    DEFAULT 1 NOT NULL
};

-- Add comments to the table 
comment on table cecred.tbrecip_vinculacao_parame
              is 'Parametrizacao dos graus de vinculacao.';
-- Add comments to the columns 
comment on column cecred.tbrecip_vinculacao_parame.idparame_reciproci
              is 'ID unico da parametrizacao de calculo.';
comment on column cecred.tbrecip_vinculacao_parame.idvinculacao_reciproci
              is 'ID do grau de vinculacao.';
comment on column cecred.tbrecip_vinculacao_parame.tpindicador
              is 'Tipo do Indicador de Reciprocidade (A=Adesao/Q=Quantidade/M=Moeda).';
comment on column cecred.tbrecip_vinculacao_parame.vlpercentual_vinculacao
              is 'Percentual do grau de vinculacao.';
comment on column cecred.tbrecip_vinculacao_parame.flgativo
              is 'Flag de ativacao ou nao da vinculacao.';

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
					 ,vlpeso_boleto    NUMBER(5,2)
					 ,vlpeso_adicional NUMBER(5,2)
				   );

-- Add comments to the columns 
comment on column cecred.tbrecip_parame_calculo.vlcusto_cee
               is 'Valor de custo quando o Cooperado emite e expede.';
comment on column cecred.tbrecip_parame_calculo.vlcusto_coo
               is 'Valor de custo quando a Cooperativa emite e expede.';
comment on column cecred.tbrecip_parame_calculo.vlpeso_boleto
               is 'Percentual de peso do boleto no calculo de reciprocidade.';
comment on column cecred.tbrecip_parame_calculo.vlpeso_adicional
               is 'Percentual de peso do adicional no calculo de reciprocidade.';

-- Alter table
ALTER TABLE tbrecip_parame_indica_calculo
        ADD(vlpercentual_peso  NUMBER(5,2)
				   );

-- Add comments to the columns 
comment on column cecred.tbrecip_parame_indica_calculo.vlpercentual_peso
               is 'Peso do indicador no calculo de reciprocidade.';

-- Alter table
ALTER TABLE tbrecip_parame_indica_coop
        ADD(vlpercentual_peso  NUMBER(5,2)
				   );

-- Add comments to the columns 
comment on column cecred.tbrecip_parame_indica_coop.vlpercentual_peso
               is 'Parametrizacao do peso do indicador no calculo de reciprocidade.';
