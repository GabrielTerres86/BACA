-- Create table
create table CECRED.TBCADAST_ATIVO_PROBL
(
  cdcooper NUMBER(10) not null,
  nrdconta NUMBER(10) not null,
  nrctremp NUMBER(10) not null,
  dtinclus DATE not null,
  dtexclus DATE,
  cdmotivo NUMBER(10) not null,
  dsobserv VARCHAR2(100),
  idativo  NUMBER(1) default 1
)
tablespace TBS_CREDITO_D
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
comment on table CECRED.TBCADAST_ATIVO_PROBL
  is 'Cadastro de Registro Manual de Ativo Problematico';
-- Add comments to the columns 
comment on column CECRED.TBCADAST_ATIVO_PROBL.cdcooper
  is 'Código da cooperativa';
comment on column CECRED.TBCADAST_ATIVO_PROBL.nrdconta
  is 'Numero da conta/dv do associado.';
comment on column CECRED.TBCADAST_ATIVO_PROBL.nrctremp
  is 'Numero do contrato de emprestimo';
comment on column CECRED.TBCADAST_ATIVO_PROBL.dtinclus
  is 'Data de inclusao do registro no Ativo Problematico';
comment on column CECRED.TBCADAST_ATIVO_PROBL.dtexclus
  is 'Data de exclusao do registro no Ativo Problematico';
comment on column CECRED.TBCADAST_ATIVO_PROBL.cdmotivo
  is 'Motivo da inclusao do registro no Ativo Problematico.';
comment on column CECRED.TBCADAST_ATIVO_PROBL.dsobserv
  is 'Observacao do operador.';
comment on column CECRED.TBCADAST_ATIVO_PROBL.idativo
  is 'Operação ativa (0- Desativado 1 Ativado';
