-- Create table
create table CECRED.TBGEN_ANALISE_CREDITO
(
  CDCOOPER          NUMBER(5) not null,
  NRDCONTA          NUMBER(10) not null,  
  NRCPFCGC          NUMBER(25) not null,
  NRCONTRATO        NUMBER(10) not null,
  DHINICIO_ANALISE  DATE default SYSDATE not null,
  DTMVTOLT          DATE not null,
  TPPRODUTO         NUMBER(2) not null,
  NRANALISE_CONTRATO NUMBER(5) not null,
  XMLANALISE        SYS.XMLTYPE,
  DSCRITIC          VARCHAR2(245));

-- Add comments to the table 
  comment on table CECRED.TBGEN_ANALISE_CREDITO
  is 'Controle de analise de credito via tela analise credito';
-- Add comments to the columns 
  comment on column CECRED.TBGEN_ANALISE_CREDITO.CDCOOPER
  is 'Cooperativa';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.NRDCONTA
  is 'Numero da conta ';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.NRCPFCGC
  is 'CPF ou CNPJ';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.NRCONTRATO
  is 'Numero do contrato';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.DHINICIO_ANALISE
  is 'Data e Hora inicio da analise';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.DTMVTOLT
  is 'Data movimento';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.TPPRODUTO
  is 'Codigo do produto';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.NRANALISE_CONTRATO
  is 'Numero da analise de contrato - sequencial';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.XMLANALISE
  is 'Xml gerado';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.DSCRITIC
  is 'Critica caso ocorra erro na geração do xml';
    
-- Create/Recreate primary, unique and foreign key constraints 
alter table CECRED.TBGEN_ANALISE_CREDITO
  add constraint TBGEN_ANALISE_CREDITO primary key (CDCOOPER,NRDCONTA,NRCONTRATO,TPPRODUTO,NRANALISE_CONTRATO)
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

  
