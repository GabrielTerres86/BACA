-- Create table
create table CECRED.TBHIST_ATIVO_PROBL
(
  cdcooper     NUMBER(10) not null,
  nrdconta     NUMBER(10) not null,
  nrctremp     NUMBER(10) not null,
  dtinreg      DATE not null,
  dthistreg    DATE,
  cdmotivo     NUMBER(10) not null,
  dsobserv     VARCHAR2(100),
  idtipo_envio NUMBER(1) not null
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
comment on table CECRED.TBHIST_ATIVO_PROBL
  is 'Cadastro de Registro Manual de Ativo Problematico';
-- Add comments to the columns 
comment on column CECRED.TBHIST_ATIVO_PROBL.cdcooper
  is 'C�digo da cooperativa';
comment on column CECRED.TBHIST_ATIVO_PROBL.nrdconta
  is 'Numero da conta/dv do associado';
comment on column CECRED.TBHIST_ATIVO_PROBL.nrctremp
  is 'Numero do contrato de emprestimo';
comment on column CECRED.TBHIST_ATIVO_PROBL.dtinreg
  is 'Data de inclusao do registro no Ativo Problematico';
comment on column CECRED.TBHIST_ATIVO_PROBL.dthistreg
  is 'Data do hist�rico do registro no Ativo Problematico';
comment on column CECRED.TBHIST_ATIVO_PROBL.cdmotivo
  is 'Motivo da inclusao do registro no Ativo Problematico';
comment on column CECRED.TBHIST_ATIVO_PROBL.dsobserv
  is 'Observacao do operador';
comment on column CECRED.TBHIST_ATIVO_PROBL.idtipo_envio
  is 'Indicador de tipo de envio(1-Automatico 2-Manual';
