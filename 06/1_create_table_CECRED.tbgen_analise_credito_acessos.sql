-- Create table
create table CECRED.tbgen_analise_credito_acessos
(
  cdcooper        NUMBER(5) not null,
  nrdconta        NUMBER(10) not null,
  cdoperador      NUMBER(10) not null,
  nrcontrato      NUMBER(10) not null,
  tpproduto       number(2) not null,
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
comment on column CECRED.tbgen_analise_credito_acessos.cdcooper
  is 'Codigo da Cooperativa';
comment on column CECRED.tbgen_analise_credito_acessos.nrdconta
  is 'Numero da Conta';
comment on column CECRED.tbgen_analise_credito_acessos.cdoperador
  is 'Codigo do Operador';
comment on column CECRED.tbgen_analise_credito_acessos.nrcontrato
  is 'Numero do Contrato';
comment on column CECRED.tbgen_analise_credito_acessos.tpproduto
  is 'Tipo do Produto';
comment on column CECRED.tbgen_analise_credito_acessos.dhinicio_acesso
  is 'Data e Hora inicio do acesso a tela';
comment on column CECRED.tbgen_analise_credito_acessos.dhfim_acesso
  is 'Data e Hora final do acesso a tela';
-- Create/Recreate indexes 
create index CECRED.IX_tbgen_analise_credito_acessos_01 on CECRED.tbgen_analise_credito_acessos (cdcooper, nrdconta);
create index CECRED.IX_tbgen_analise_credito_acessos_02 on CECRED.tbgen_analise_credito_acessos (cdoperador);
