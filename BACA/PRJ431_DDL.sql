-- Comandos DDL referente ao PRJ431

-- -----------------------------------------
-- Criação da tabela de domínio da Cobrança
-- -----------------------------------------
-- Create table
create table cecred.tbcobran_dominio_campo
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
comment on table cecred.tbcobran_dominio_campo
  is 'Tabela de dominios dos campos do modulo COBRANCA';
-- Add comments to the columns 
comment on column cecred.tbcobran_dominio_campo.nmdominio
  is 'Nome do campo dominio';
comment on column cecred.tbcobran_dominio_campo.cddominio
  is 'Codigo do dominio';
comment on column cecred.tbcobran_dominio_campo.dscodigo
  is 'Descricao do codigo dominio';
-- Create/Recreate primary, unique and foreign key constraints 
alter table cecred.tbcobran_dominio_campo
  add constraint tbcobran_dominio_campo_pk primary key (nmdominio, cddominio);

-- ---------------------------------------------------------------------------------
-- Criação das tabelas referente ao workflow de aprovação dos convênios de cobrança
-- ---------------------------------------------------------------------------------
-- Create table
CREATE TABLE cecred.tbrecip_param_workflow
(
  cdcooper                 NUMBER(10) NOT NULL
 ,cdalcada_aprovacao       NUMBER(10) NOT NULL
 ,flregra_aprovacao        NUMBER(1)  DEFAULT 0 NOT NULL
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
  cdcooper           NUMBER(10)    NOT NULL
 ,cdalcada_aprovacao NUMBER(10)    NOT NULL
 ,cdaprovador        VARCHAR2(10)  NOT NULL
 ,dsemail_aprovador  VARCHAR2(100) NOT NULL
 ,flativo            NUMBER(1) DEFAULT 0 NOT NULL
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
comment on column cecred.tbrecip_param_aprovador.dsemail_aprovador
              is 'Endreco de ermail do aprovador.';
comment on column cecred.tbrecip_param_aprovador.flativo
              is 'Flag para indicar se o aprovador está ativo (0=Nao/1=Sim).';

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
 ,cdoperador               VARCHAR2(10) NOT NULL
 ,idstatus                 VARCHAR2(1)  NOT NULL
 ,dtalteracao_status       DATE         NOT NULL
 ,dsjustificativa          CLOB
);

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
comment on column cecred.tbrecip_aprovador_calculo.cdoperador
              is 'Codigo do usuario operador que efetuou o cancelamento.';
comment on column cecred.tbrecip_aprovador_calculo.idstatus
              is 'Status da avaliacao do aprovador (A=Aprovado, R=Rejeitado, C=Cancelado).';
comment on column cecred.tbrecip_aprovador_calculo.dtalteracao_status
              is 'Data da avaliacao do aprovador.';
comment on column cecred.tbrecip_aprovador_calculo.dsjustificativa
              is 'Justificativa para a aprovacao/rejeição realizada pelo aprovador.';

-- Create/Recreate primary, unique and foreign key constraints 
alter table cecred.tbrecip_aprovador_calculo
  add constraint tbrecip_aprovador_calculo_pk primary KEY(cdcooper, cdalcada_aprovacao, idcalculo_reciproci, cdaprovador);

alter table cecred.tbrecip_aprovador_calculo
  add constraint tbrecip_aprovador_calculo_fk foreign KEY(idcalculo_reciproci)
  references cecred.tbrecip_calculo(idcalculo_reciproci);

-- Create table
CREATE TABLE cecred.tbrecip_log_contrato
(
  cdcooper            NUMBER(10)   NOT NULL
 ,idcalculo_reciproci NUMBER(10)   NOT NULL
 ,cdoperador          VARCHAR2(10) NOT NULL
 ,dshistorico         CLOB         NOT NULL
 ,dthistorico         DATE         NOT NULL
);

-- Add comments to the table 
comment on table cecred.tbrecip_log_contrato
              is 'Log das operacoes realizadas no contrato de reciprocidade.';

-- Add comments to the columns 
comment on column cecred.tbrecip_log_contrato.cdcooper
              is 'Codigo que identifica a Cooperativa.';
comment on column cecred.tbrecip_log_contrato.idcalculo_reciproci
              is 'ID unico do calculo de reciprocidade atrelado a contratacao.';
comment on column cecred.tbrecip_log_contrato.cdoperador
              is 'Codigo do usuario que realizou a alteracao.';
comment on column cecred.tbrecip_log_contrato.dshistorico
              is 'Descricao da alteracao realizada.';
comment on column cecred.tbrecip_log_contrato.dthistorico
              is 'Data da alteracao realizada.';

alter table cecred.tbrecip_log_contrato
  add constraint tbrecip_log_contrato_fk foreign KEY(idcalculo_reciproci)
  references cecred.tbrecip_calculo(idcalculo_reciproci);

-- --------------------------------------------------------
-- Criação das tabelas referente ao cadastro de vinculação
-- --------------------------------------------------------
-- Create table
CREATE TABLE cecred.tbrecip_vinculacao
(
  idvinculacao NUMBER(5) NOT NULL
 ,nmvinculacao VARCHAR2(100) NOT NULL
 ,flgativo     NUMBER(1) DEFAULT 1 NOT NULL
);

-- Add comments to the table 
comment on table cecred.tbrecip_vinculacao
              is 'Cadatro generico dos indicadores de vinculacao.';
-- Add comments to the columns 
comment on column cecred.tbrecip_vinculacao.idvinculacao
              is 'ID unico do indicador de vinculacao.';
comment on column cecred.tbrecip_vinculacao.nmvinculacao
              is 'Nome para o indicador de vinculacao.';
comment on column cecred.tbrecip_vinculacao.flgativo
              is 'Flag para permitir a ativacao do indicador de vinculacao (0=Nao/1=Sim).';

-- Create/Recreate primary, unique and foreign key constraints 
alter table cecred.tbrecip_vinculacao
  add constraint tbrecip_vinculacao_pk primary KEY(idvinculacao);

-- ----------------------------------------------------------------------------------------
-- Criação da tabela referente ao cadastro de parametrização da vinculação por cooperativa
-- ----------------------------------------------------------------------------------------

-- Create table
CREATE TABLE cecred.tbrecip_vinculacao_parame
(
  idparame_reciproci       NUMBER(10)   NOT NULL
 ,idvinculacao_reciproci   NUMBER(2)    NOT NULL
 ,vlpercentual_desconto    NUMBER(5,2)  NOT NULL
 ,vlpercentual_peso        NUMBER(5,2)  NOT NULL
 ,flgativo                 NUMBER(1)    DEFAULT 1 NOT NULL
);

-- Add comments to the table 
comment on table cecred.tbrecip_vinculacao_parame
              is 'Parametrizacao dos graus de vinculacao.';
-- Add comments to the columns 
comment on column cecred.tbrecip_vinculacao_parame.idparame_reciproci
              is 'ID unico da parametrizacao de calculo.';
comment on column cecred.tbrecip_vinculacao_parame.idvinculacao_reciproci
              is 'ID do grau de vinculacao.';
comment on column cecred.tbrecip_vinculacao_parame.vlpercentual_desconto
              is 'Percentual do desconto da vinculacao no calculo de reciprocidade.';
comment on column cecred.tbrecip_vinculacao_parame.vlpercentual_peso
              is 'Percentual do peso da vinculacao no calculo de reciprocidade.';
comment on column cecred.tbrecip_vinculacao_parame.flgativo
              is 'Flag de ativacao ou nao da vinculacao.';

-- Create/Recreate primary, unique and foreign key constraints 
alter table cecred.tbrecip_vinculacao_parame
  add constraint tbrecip_vinculacao_parame_pk primary KEY(idparame_reciproci, idvinculacao_reciproci);

alter table cecred.tbrecip_vinculacao_parame
  add constraint tbrecip_vinculacao_parame_fk foreign KEY(idparame_reciproci)
  references cecred.tbrecip_parame_calculo(idparame_reciproci);

alter table cecred.tbrecip_vinculacao_parame
  add constraint tbrecip_vinculacao_parame_fk2 foreign KEY(idvinculacao_reciproci)
  references cecred.tbrecip_vinculacao(idvinculacao_reciproci);

-- Create table
CREATE TABLE cecred.tbrecip_vinculacao_parame_coop
(
  cdcooper                 NUMBER(5)    NOT NULL
 ,idvinculacao_reciproci   NUMBER(2)    NOT NULL
 ,cdproduto                NUMBER(5)    NOT NULL
 ,inpessoa                 NUMBER(1)    NOT NULL
 ,vlpercentual_desconto    NUMBER(5,2)  NOT NULL
 ,vlpercentual_peso        NUMBER(5,2)  NOT NULL
);

-- Add comments to the table 
comment on table cecred.tbrecip_vinculacao_parame_coop
              is 'Parametrizacao dos graus de vinculacao por cooperativa.';
-- Add comments to the columns 
comment on column cecred.tbrecip_vinculacao_parame_coop.cdcooper
              is 'Codigo da Cooperativa.';
comment on column cecred.tbrecip_vinculacao_parame_coop.idvinculacao_reciproci
              is 'ID do grau de vinculacao.';
comment on column cecred.tbrecip_vinculacao_parame_coop.cdproduto
              is 'Codigo do produto de abertura de conta.';
comment on column cecred.tbrecip_vinculacao_parame_coop.inpessoa
              is 'Tipo de pessoa (1=Fisica/2=Juridica/3=Cheque adm.).';
comment on column cecred.tbrecip_vinculacao_parame_coop.vlpercentual_desconto
              is 'Percentual do desconto da vinculacao no calculo de reciprocidade.';
comment on column cecred.tbrecip_vinculacao_parame_coop.vlpercentual_peso
              is 'Percentual do peso da vinculacao no calculo de reciprocidade.';

-- Create/Recreate primary, unique and foreign key constraints 
alter table cecred.tbrecip_vinculacao_parame_coop
  add constraint tbrecip_vinc_par_coop_pk primary KEY(cdcooper, idvinculacao_reciproci, cdproduto, inpessoa);

alter table cecred.tbrecip_vinculacao_parame_coop
  add constraint tbrecip_vinc_par_coop_fk foreign KEY(idvinculacao_reciproci)
  references cecred.tbrecip_vinculacao(idvinculacao_reciproci);

-- ------------------------------------------------
-- Alteração da tabela de cálculo da reciprocidade
-- ------------------------------------------------

-- Alter table
ALTER TABLE cecred.tbrecip_calculo
        ADD(idvinculacao               NUMBER(2)
				   ,idfim_contrato             NUMBER(2)
					 ,vldesconto_concedido_coo   NUMBER(5,2)
					 ,vldesconto_concedido_cee   NUMBER(5,2)
					 ,vldesconto_adicional_coo   NUMBER(5,2)
					 ,idfim_desc_adicional_coo   NUMBER(2)
					 ,vldesconto_adicional_cee   NUMBER(5,2)
					 ,idfim_desc_adicional_cee   NUMBER(2)					 
					 ,dtinicio_vigencia_contrato DATE
					 ,dtfim_vigencia_contrato    DATE
					 ,dsjustificativa_desc_adic  CLOB
				   );

-- Add comments to the columns
comment on column cecred.tbrecip_calculo.idvinculacao
  is 'Identificador da vinculacao';
comment on column cecred.tbrecip_calculo.idfim_contrato
  is 'Identificador da quantidade de meses para o fim de vigencia do contrato';
comment on column cecred.tbrecip_calculo.vldesconto_concedido_coo
  is 'Percentual de desconto concedido COO';
comment on column cecred.tbrecip_calculo.vldesconto_concedido_cee
  is 'Percentual de desconto concedido CEE';
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
comment on column cecred.tbrecip_calculo.dsjustificativa_desc_adic
  is 'Justificativa para o desconto adicional.';
	
-- ---------------------------------------------------------
-- Alteração das tabelas de parametrização da reciprocidade
-- ---------------------------------------------------------

-- Alter table
ALTER TABLE cecred.tbrecip_parame_calculo
        ADD(vldesconto_maximo_cee NUMBER(5,2)
				   ,vldesconto_maximo_coo NUMBER(5,2)
				   );

-- Add comments to the columns 
comment on column cecred.tbrecip_parame_calculo.vldesconto_maximo_cee
               is 'Percentual de desconto maximo permitido quando a Cooperativa emite e expede.';
comment on column cecred.tbrecip_parame_calculo.vldesconto_maximo_coo
               is 'Percentual de desconto maximo permitido quando o Cooperado emite e expede.';

-- Alter table
ALTER TABLE cecred.tbrecip_parame_indica_calculo
        ADD(vlpercentual_peso     NUMBER(5,2)
				   ,vlpercentual_desconto NUMBER(5,2)
				   );

-- Add comments to the columns 
comment on column cecred.tbrecip_parame_indica_calculo.vlpercentual_peso
               is 'Peso do indicador no calculo de reciprocidade.';
comment on column cecred.tbrecip_parame_indica_calculo.vlpercentual_peso
               is 'Desconto do indicador no calculo de reciprocidade.';

-- Alter table
ALTER TABLE cecred.tbrecip_parame_indica_coop
        ADD(vlpercentual_peso     NUMBER(5,2)
				   ,vlpercentual_desconto NUMBER(5,2)
				   );

-- Add comments to the columns 
comment on column cecred.tbrecip_parame_indica_coop.vlpercentual_peso
               is 'Parametrizacao do peso do indicador no calculo de reciprocidade.';
comment on column cecred.tbrecip_parame_indica_calculo.vlpercentual_peso
               is 'Parametrizacao do desconto do indicador no calculo de reciprocidade.';

-- -------------------
-- Criação de índice
-- -------------------

CREATE INDEX CRAPCOB##CRAPCOB13
  ON cecred.crapcob(cdcooper, nrcnvcob, incobran, dtdpagto, dtdbaixa, dtelimin);
