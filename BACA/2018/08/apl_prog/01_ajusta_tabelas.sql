--Ajuste das tabelas
-- CRAPRPP
-- Add/modify columns 
alter table CECRED.CRAPRPP add cdprodut NUMBER(5) default 0;
alter table CECRED.CRAPRPP add dsfinali VARCHAR2(20) default '';
alter table CECRED.CRAPRPP add flgteimo NUMBER(1) default 0;
alter table CECRED.CRAPRPP add flgdbpar NUMBER(1) default 0;
-- Add comments to the columns 
comment on column CECRED.CRAPRPP.cdprodut
  is 'Codigo do produto de captacao';
comment on column CECRED.CRAPRPP.dsfinali
  is 'Descricao da finalidade para a aplicacao programada';
comment on column CECRED.CRAPRPP.flgteimo
  is 'Indica se a teimosinha foi contratada ( 0 - nao, 1 - sim)';
comment on column CECRED.CRAPRPP.flgdbpar
  is 'Efetua debito parcial (0 - não, 1 - sim)';

-- CRAPCPC
-- Add/modify columns 
alter table CECRED.CRAPCPC add indplano NUMBER(1) default 0 not null;
-- Add comments to the columns 
comment on column CECRED.CRAPCPC.indplano
  is 'Indica se é um produto de aplicacao programada (0 - Nao / 1 - Sim)';
  
-- CRAPRAC
-- Add/modify columns 
alter table CECRED.CRAPRAC add nrctrrpp NUMBER(10) default 0;
-- Add comments to the columns 
comment on column CECRED.CRAPRAC.nrctrrpp
  is 'Numero da poupanca programada - Apenas aplicacoes automaticas';
  
 
-- Novas tabelas
-- Create TBCAPT_CONFIG_PLANOS_APL_PROG
-- Create table
create table CECRED.TBCAPT_CONFIG_PLANOS_APL_PROG
(
  idconfiguracao    number(5) not null,
  cdcooper          number(10) not null,
  cdprodut          number(5) not null,
  flgteimosinha     number(1) default 0 not null,
  flgdebito_parcial number(1) default 0 not null,
  vlminimo          number(25,2) default 0
)
;
-- Add comments to the table 
comment on table CECRED.TBCAPT_CONFIG_PLANOS_APL_PROG
  is 'Configuracao especifica dos planos de aplicacao programada';
-- Add comments to the columns 
comment on column CECRED.TBCAPT_CONFIG_PLANOS_APL_PROG.idconfiguracao
  is 'Identificador da configuracao do plano de aplicacao programada';
comment on column CECRED.TBCAPT_CONFIG_PLANOS_APL_PROG.cdcooper
  is 'Codigo da cooperativa';
comment on column CECRED.TBCAPT_CONFIG_PLANOS_APL_PROG.cdprodut
  is 'Codigo do produto de captacao';
comment on column CECRED.TBCAPT_CONFIG_PLANOS_APL_PROG.flgteimosinha
  is 'Teimosinha para o produto (0 - nao / 1 - sim)';
comment on column CECRED.TBCAPT_CONFIG_PLANOS_APL_PROG.flgdebito_parcial
  is 'Debito parcial para o produto (0 - nao / 1 - sim)';
comment on column CECRED.TBCAPT_CONFIG_PLANOS_APL_PROG.vlminimo
  is 'Valor minimo do debito mensal do plano';
-- Create/Recreate indexes 
create unique index CECRED.tbcapt_config_planos_apl_prog_idx01 on CECRED.TBCAPT_CONFIG_PLANOS_APL_PROG (cdcooper, cdprodut);
-- Create/Recreate primary, unique and foreign key constraints 
alter table CECRED.TBCAPT_CONFIG_PLANOS_APL_PROG
  add constraint tbcapt_config_planos_apl_prog_pk primary key (IDCONFIGURACAO);
alter table CECRED.TBCAPT_CONFIG_PLANOS_APL_PROG
  add constraint tbcapt_config_planos_apl_prog_fk01 foreign key (CDPRODUT)
  references CECRED.crapcpc (CDPRODUT);

  
