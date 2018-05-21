-- Criação da tabela
create table CECRED.TBCC_PREJUIZO
(idprejuizo        NUMBER(10) not null,
,cdcooper          NUMBER(10)   NOT NULL
,nrdconta          NUMBER(10)   NOT NULL
,dtinclusao        DATE         NOT NULL
,dtliquidacao      DATE
,cdsitdct_original NUMBER(5)  NOT NULL
,vldivida_original NUMBER(25,2)  NOT NULL);

-- Comentário na tabela
comment on table CECRED.TBCC_PREJUIZO is 'Historico de Prejuizo da Conta Corrente';

-- Comentários nas colunas da tabela
comment on column CECRED.TBCC_PREJUIZO.idprejuizo is 'ID de prejuizo';

comment on column CECRED.TBCC_PREJUIZO.cdcooper is 'Codigo que identifica a cooperativa';

comment on column CECRED.TBCC_PREJUIZO.nrdconta is 'Numero da conta';

comment on column CECRED.TBCC_PREJUIZO.dtinclusao is 'Data de inclusao no prejuizo';

comment on column CECRED.TBCC_PREJUIZO.dtliquidacao is 'Data de liquidacao do prejuizo';

comment on column CECRED.TBCC_PREJUIZO.cdsitdct_original is 'Codigo da situacao da conta original(CRAPASS.CDSITDCT)';

comment on column CECRED.TBCC_PREJUIZO.vldivida_original is 'Valor da divida original';

-- Constraints
alter table CECRED.TBCC_PREJUIZO
  add constraint TBCC_PREJUIZO_PK primary key (idprejuizo);

alter table CECRED.TBCC_PREJUIZO
  add constraint TBCC_PREJUIZO_UK unique key (cdcooper, nrdconta, dtinc_prejuizo);

-- Create sequence 
create sequence CECRED.SEQ_CC_PREJUIZO_ID
minvalue 1
maxvalue 9999999999
start with 1
increment by 1
cache 20;

-- Trigger para geração do ID
CREATE OR REPLACE TRIGGER CECRED.TRG_CC_PREJUIZO_ID
  BEFORE INSERT
  ON TBCC_PREJUIZO
  FOR EACH ROW
    BEGIN
      SELECT CECRED.SEQ_CC_PREJUIZO_ID.NEXTVAL
        INTO :NEW.idprejuizo
        FROM DUAL;

    EXCEPTION 
	  WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20100,'ERRO GERACAO SEQ_CC_PREJUIZO_ID!');
    END;
/	
  