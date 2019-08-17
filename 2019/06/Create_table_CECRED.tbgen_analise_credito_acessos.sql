-- Create table
create table cecred.tbgen_analise_credito_acessos
( idanalise_contrato_acesso NUMBER(15) not null,
  idanalise_contrato NUMBER(15) not null,
  cdcooper           NUMBER(10) not null,
  cdoperad           VARCHAR2(10) not null,
  dhinicio_acesso date default sysdate not null,
  dhfim_acesso    date
);

-- Add comments to the table 
comment on cecred.table tbgen_analise_credito_acessos
  is 'Armazena os acessos a tela única e o tempo que cada operador permaneceu visualizando as propostas';
-- Add comments to the columns 
comment on column cecred.tbgen_analise_credito_acessos.IDANALISE_CONTRATO_ACESSO
  is 'Sequencial de Acesso';
comment on column cecred.tbgen_analise_credito_acessos.IDANALISE_CONTRATO
  is 'FK com tabela tbgen_analise_credito.idanalise_contrato';
comment on column cecred.tbgen_analise_credito_acessos.cdcooper
  is 'Codigo que identifica a Cooperativa.';
comment on column cecred.tbgen_analise_credito_acessos.cdoperad
  is 'Codigo do operador.';  
comment on column cecred.tbgen_analise_credito_acessos.dhinicio_acesso
  is 'Data e Hora inicio do acesso a tela';
comment on column cecred.tbgen_analise_credito_acessos.dhfim_acesso
  is 'Data e Hora final do acesso a tela';
-- Create/Recreate primary, unique and foreign key constraints 
alter table cecred.tbgen_analise_credito_acessos
  add constraint analise_credito_aces_PK primary key (idanalise_contrato_acesso);
  
alter table cecred.tbgen_analise_credito_acessos
  add constraint analise_cred_aces_FK01 foreign key (idanalise_contrato)
  references tbgen_analise_credito (idanalise_contrato);
/  
-- Create/Recreate indexes 
create index TBGEN_ANALISE_CREDITO_ACES_IDX01 on cecred.TBGEN_ANALISE_CREDITO_ACESSOS (CDCOOPER, CDOPERAD);
/
-- Create sequence 
create sequence cecred.tbgen_analise_cred_aces_SEQ
minvalue 1
maxvalue 99999999999999999999999
start with 1
increment by 1
nocache
order;

/
CREATE OR REPLACE TRIGGER cecred.TRG_analise_cred_aces_ID BEFORE
    INSERT ON cecred.tbgen_analise_credito_acessos
    FOR EACH ROW
    WHEN ( new.idanalise_contrato_acesso IS NULL )
BEGIN
    :new.idanalise_contrato_acesso := tbgen_analise_cred_aces_SEQ.nextval;
END;