-- Create table
create table CECRED.TBCTD_TRANS_PEND
(
  cdtransacao_pendente NUMBER(15) default 0 not null,
  cdcooper             NUMBER(5) default 0 not null,
  nrdconta             NUMBER(10) default 0 not null,
  tpcontrato           NUMBER(2) default 0,
  dscontrato           VARCHAR2(100),
  nrcontrato           NUMBER(20) default 0,
  vlcontrato           NUMBER(25,2) default 0,
  dhcontrato           DATE,
  cdoperad             VARCHAR2(10) default '',
  cdrecid_crapcdc      NUMBER(20) default 0
);
-- Add comments to the table
comment on table CECRED.TBCTD_TRANS_PEND  is 'Dados da transacao de contrato pendente de efetivacao';
-- Add comments to the columns
comment on column CECRED.TBCTD_TRANS_PEND.cdtransacao_pendente  is 'Codigo sequencial da transacao contrato';
comment on column CECRED.TBCTD_TRANS_PEND.cdcooper  is 'Codigo da cooperativa';
comment on column CECRED.TBCTD_TRANS_PEND.nrdconta  is 'Numero da conta';
comment on column CECRED.TBCTD_TRANS_PEND.tpcontrato  is 'Identificacao do tipo de contrato';
comment on column CECRED.TBCTD_TRANS_PEND.dscontrato  is 'Descricao do tipo de contrato';
comment on column CECRED.TBCTD_TRANS_PEND.nrcontrato  is 'Numero do contrato no CRAPDOC';
comment on column CECRED.TBCTD_TRANS_PEND.vlcontrato  is 'Valor do contrato';
comment on column CECRED.TBCTD_TRANS_PEND.dhcontrato  is 'Data/hora da inclusao do contrato';
comment on column CECRED.TBCTD_TRANS_PEND.cdoperad  is 'Codigo do operador';
comment on column CECRED.TBCTD_TRANS_PEND.cdrecid_crapcdc  is 'PROGRESS_RECID da tabela CRAPCDC';
-- Create/Recreate primary, unique and foreign key constraints
alter table CECRED.TBCTD_TRANS_PEND
  add constraint TBCTD_TRANS_PEND_PK primary key (CDTRANSACAO_PENDENTE);