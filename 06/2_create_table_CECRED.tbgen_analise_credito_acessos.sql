
-- Create table
create table CECRED.tbgen_analise_credito_acessos
( idanalise_contrato_acesso NUMBER(15) not null,
  idanalise_contrato NUMBER(15) not null,
  cdcooper           NUMBER(10) not null,
  cdoperad           VARCHAR2(10) not null,
  dhinicio_acesso date default sysdate not null,
  dhfim_acesso    date
);


-- Add comments to the table 
comment on table CECRED.tbgen_analise_credito_acessos
  is 'Armazena os acessos a tela única e o tempo que cada operador permaneceu visualizando as propostas';
-- Add comments to the columns 
comment on column CECRED.tbgen_analise_credito_acessos.IDANALISE_CONTRATO_ACESSO
  is 'Sequencial de Acesso';
comment on column CECRED.tbgen_analise_credito_acessos.IDANALISE_CONTRATO
  is 'FK com tabela tbgen_analise_credito.idanalise_contrato';
comment on column CECRED.tbgen_analise_credito_acessos.cdcooper
  is 'Codigo que identifica a Cooperativa.';
comment on column CECRED.tbgen_analise_credito_acessos.cdoperad
  is 'Codigo do operador.';  
comment on column CECRED.tbgen_analise_credito_acessos.dhinicio_acesso
  is 'Data e Hora inicio do acesso a tela';
comment on column CECRED.tbgen_analise_credito_acessos.dhfim_acesso
  is 'Data e Hora final do acesso a tela';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CECRED.tbgen_analise_credito_acessos
  add constraint tbgen_analise_credito_acessos_PK primary key (idanalise_contrato_acesso);
  
alter table CECRED.tbgen_analise_credito_acessos
  add constraint analise_cred_acessos_FK01 foreign key (idanalise_contrato)
  references CECRED.tbgen_analise_credito (idanalise_contrato);
/  
-- Create sequence 
create sequence CECRED.tbgen_analise_cred_acessos_SEQ
minvalue 1
maxvalue 99999999999999999999999
start with 0
increment by 1
nocache
order;

/
CREATE OR REPLACE TRIGGER CECRED.TRG_tbgen_analise_cred_aces_ID BEFORE
    INSERT ON tbgen_analise_credito_acessos
    FOR EACH ROW
    WHEN ( new.idanalise_contrato_acesso IS NULL )
BEGIN
    :new.idanalise_contrato_acesso := tbgen_analise_credito_acessos_SEQ.nextval;
END;  