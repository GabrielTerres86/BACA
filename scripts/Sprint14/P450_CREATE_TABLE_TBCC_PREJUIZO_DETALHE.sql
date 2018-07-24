-- Create table
create table CECRED.TBCC_PREJUIZO_DETALHE
(
  idlancto           NUMBER(10) not null,
  dtmvtolt           DATE,
  nrdconta           NUMBER(10) default 0,
  cdhistor           NUMBER(5) default 0,
  vllanmto           NUMBER(25,2) default 0,
  dthrtran           DATE,
  cdoperad           VARCHAR2(10) default ' ',
  cdcooper           NUMBER(10) default 0
);
-- Add comments to the table 
comment on table CECRED.TBCC_PREJUIZO_DETALHE
  is 'Lancamentos detalhados do extrato do prejuizo';
-- Add comments to the columns 
comment on column CECRED.TBCC_PREJUIZO_DETALHE.idlancto
  is 'Identificador do lancamento (PK)';
comment on column CECRED.TBCC_PREJUIZO_DETALHE.dtmvtolt
  is 'Data do movimento';
comment on column CECRED.TBCC_PREJUIZO_DETALHE.nrdconta
  is 'Numero da conta ';
comment on column CECRED.TBCC_PREJUIZO_DETALHE.cdhistor
  is 'Codigo do historico';
comment on column CECRED.TBCC_PREJUIZO_DETALHE.vllanmto
  is 'Valor do lancamento';
comment on column CECRED.TBCC_PREJUIZO_DETALHE.dthrtran
  is 'Data e hora do lancamento';
comment on column CECRED.TBCC_PREJUIZO_DETALHE.cdoperad
  is 'Codigo do operador do lancamento';
comment on column CECRED.TBCC_PREJUIZO_DETALHE.cdcooper
  is 'Codigo da cooperativa';

-- Create/Recreate primary, unique and foreign key constraints 
alter table CECRED.TBCC_PREJUIZO_DETALHE
  add constraint TBCC_PREJUIZO_DETALHE_PK primary key (IDLANCTO);

-- Create sequence 
create sequence CECRED.SEQ_CC_DETALHE_PREJUZ_ID
minvalue 1
maxvalue 9999999999
start with 1
increment by 1
cache 20;

-- Trigger para geração do ID
CREATE OR REPLACE TRIGGER CECRED.TRG_CC_DETALHE_PREJUZ_ID
  BEFORE INSERT
  ON TBCC_PREJUIZO_DETALHE
  FOR EACH ROW
    BEGIN
      SELECT CECRED.SEQ_CC_DETALHE_PREJUZ_ID.NEXTVAL
        INTO :NEW.idlancto
        FROM DUAL;

    EXCEPTION 
	  WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20100,'ERRO GERACAO SEQ_CC_DETALHE_PREJUZ_ID!');
    END;
/
