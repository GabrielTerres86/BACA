-- Create table
create table CECRED.tbgen_analise_credito_acessos
( idanalise_contrato_acesso NUMBER(15) not null,
  idanalise_contrato NUMBER(15) not null,
  dhinicio_acesso date default sysdate not null,
  dhfim_acesso    date
)
tablespace TBS_GERAL_D
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table CECRED.tbgen_analise_credito_acessos
  is 'Armazena os acessos a tela única e o tempo que cada operador permaneceu visualizando as propostas';
-- Add comments to the columns 
comment on column CECRED.tbgen_analise_credito_acessos.IDANALISE_CONTRATO_ACESSO
  is 'Sequencial de Acesso';
comment on column CECRED.tbgen_analise_credito_acessos.IDANALISE_CONTRATO
  is 'FK com tabela tbgen_analise_credito.idanalise_contrato';
comment on column CECRED.tbgen_analise_credito_acessos.dhinicio_acesso
  is 'Data e Hora inicio do acesso a tela';
comment on column CECRED.tbgen_analise_credito_acessos.dhfim_acesso
  is 'Data e Hora final do acesso a tela';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CECRED.tbgen_analise_credito_acessos
  add constraint tbgen_analise_credito_acessos_PK primary key (idanalise_contrato_acesso)
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
alter table CECRED.tbgen_analise_credito_acessos
  add constraint analise_cred_acessos_FK01 foreign key (idanalise_contrato)
  references CECRED.tbgen_analise_credito (idanalise_contrato);