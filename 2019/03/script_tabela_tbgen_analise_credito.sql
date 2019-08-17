-- Create table
create table CECRED.TBGEN_ANALISE_CREDITO
(
  IDANALISE_CONTRATO NUMBER(15) not null,
  CDCOOPER          NUMBER(5) not null,
  NRDCONTA          NUMBER(10) not null,  
  NRCPFCGC          NUMBER(25) not null,
  NRCONTRATO        NUMBER(10) not null,
  NRVERSAO_ANALISE  NUMBER(5) not null,
  DHINICIO_ANALISE  DATE default SYSDATE not null,
  DTMVTOLT          DATE not null,
  TPPRODUTO         NUMBER(2) not null,
  XMLANALISE        CLOB,
  DSCRITIC          VARCHAR2(245));

-- Add comments to the table 
  comment on table CECRED.TBGEN_ANALISE_CREDITO
  is 'Controle de analise de credito via tela analise credito';
-- Add comments to the columns
  comment on column CECRED.TBGEN_ANALISE_CREDITO.IDANALISE_CONTRATO
  is 'Numero da analise de contrato - sequencial'; 
  comment on column CECRED.TBGEN_ANALISE_CREDITO.CDCOOPER
  is 'Cooperativa';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.NRDCONTA
  is 'Numero da conta ';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.NRCPFCGC
  is 'CPF ou CNPJ';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.NRCONTRATO
  is 'Numero do contrato';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.NRVERSAO_ANALISE
  is 'NR Versao da analise por contrato';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.DHINICIO_ANALISE
  is 'Data e Hora inicio da analise';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.DTMVTOLT
  is 'Data movimento';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.TPPRODUTO
  is 'Codigo do produto';
  
  comment on column CECRED.TBGEN_ANALISE_CREDITO.XMLANALISE
  is 'Xml gerado';
  comment on column CECRED.TBGEN_ANALISE_CREDITO.DSCRITIC
  is 'Critica caso ocorra erro na geração do xml';
    
-- Create/Recreate primary, unique and foreign key constraints 
alter table CECRED.TBGEN_ANALISE_CREDITO
  add constraint TBGEN_ANALISE_CREDITO_PK primary key (IDANALISE_CONTRATO);
  
CREATE INDEX CECRED.TBGEN_ANALISE_CREDITO_idx01 on CECRED.TBGEN_ANALISE_CREDITO(cdcooper,nrdconta,NRCONTRATO);


-- Create sequence 
create sequence CECRED.TBGEN_ANALISE_CREDITO_seq
minvalue 1
maxvalue 99999999999999999999999
start with 1
increment by 1
nocache
order;

CREATE OR REPLACE TRIGGER CECRED.TRG_TBGEN_ANALISE_CREDITO_ID BEFORE
    INSERT ON TBGEN_ANALISE_CREDITO
    FOR EACH ROW
    WHEN ( new.IDANALISE_CONTRATO IS NULL )
BEGIN
    :new.IDANALISE_CONTRATO := TBGEN_ANALISE_CREDITO_SEQ.nextval;
END;
  
