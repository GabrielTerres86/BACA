-- Create table
create table CECRED.TBEPR_LIQUIDADO_FINANCIADO
(
  cdcooper     NUMBER(5) default 0 not null,
  nrdconta     NUMBER(10) default 0 not null,
  qtdia_atraso NUMBER(10) default 0,
  cdmodali     NUMBER(5) default 0,
  nrctremp     NUMBER(10) default 0 not null,
  vljuros60    NUMBER(25,2) default 0
)
tablespace TBS_GERAL_D
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
comment on table CECRED.TBEPR_LIQUIDADO_FINANCIADO
  is 'Contratos que foram refinanciados';
-- Add comments to the columns 
comment on column CECRED.TBEPR_LIQUIDADO_FINANCIADO.cdcooper
  is 'Código da cooperativa';
comment on column CECRED.TBEPR_LIQUIDADO_FINANCIADO.nrdconta
  is 'Numero da conta/dv do associado.';
comment on column CECRED.TBEPR_LIQUIDADO_FINANCIADO.qtdia_atraso
  is 'Dias em atraso.';
comment on column CECRED.TBEPR_LIQUIDADO_FINANCIADO.cdmodali
  is 'Modalidade';
comment on column CECRED.TBEPR_LIQUIDADO_FINANCIADO.nrctremp
  is 'Numero Contrato/Conta';
comment on column CECRED.TBEPR_LIQUIDADO_FINANCIADO.vljuros60
  is 'Juros de Parcelas em Atraso a mais de 60 dias.';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CECRED.TBEPR_LIQUIDADO_FINANCIADO
  add constraint TBEPR_LIQUIDADO_FINANCIADO_PK primary key (CDCOOPER, NRDCONTA, NRCTREMP)
  using index 
  tablespace TBS_GERAL_I
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
