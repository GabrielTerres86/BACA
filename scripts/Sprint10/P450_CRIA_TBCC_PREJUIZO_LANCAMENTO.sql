-- Create table
create table CECRED.TBCC_PREJUIZO_LANCAMENTO
(
  idlancto_prejuizo       NUMBER(10) not null,
  dtmvtolt       DATE,
  cdagenci       NUMBER(5) default 0,
  nrdconta       NUMBER(10) default 0,
  nrdocmto       NUMBER(25) default 0,
  cdhistor       NUMBER(5) default 0,
  vllanmto       NUMBER(25,2) default 0,
  dthrtran       DATE,
  cdoperad       VARCHAR2(10) default ' ',
  cdcooper       NUMBER(10) default 0,
  cdorigem       NUMBER(3) default 0,
  dtliberacao    DATE,
  cdoperad_liberacao VARCHAR2(10) default ' '
);

-- Add comments to the table 
comment on table CECRED.TBCC_PREJUIZO_LANCAMENTO
  is 'Lancamentos bloqueados por conta em prejuízo';


comment on column CECRED.TBCC_PREJUIZO_LANCAMENTO.idlancto_prejuizo 
 is 'Identificador do lançamento (PK)';
comment on column CECRED.TBCC_PREJUIZO_LANCAMENTO.cdcooper 
 is 'Codigo da cooperativa';
comment on column CECRED.TBCC_PREJUIZO_LANCAMENTO.cdagenci  
 is 'Codigo da agencia do lancamento';
comment on column CECRED.TBCC_PREJUIZO_LANCAMENTO.nrdconta 
 is 'Numero da conta ';
comment on column CECRED.TBCC_PREJUIZO_LANCAMENTO.dtmvtolt 
 is 'Data do movimento';
comment on column CECRED.TBCC_PREJUIZO_LANCAMENTO.cdhistor 
 is 'Codigo do historico';
comment on column CECRED.TBCC_PREJUIZO_LANCAMENTO.nrdocmto 
 is 'Numero do Documento';
comment on column CECRED.TBCC_PREJUIZO_LANCAMENTO.vllanmto 
 is 'Valor do lancamento';
comment on column CECRED.TBCC_PREJUIZO_LANCAMENTO.cdoperad 
 is 'Codigo do operador do lancamento';
comment on column CECRED.TBCC_PREJUIZO_LANCAMENTO.cdorigem 
 is 'Origem do lancamento';
comment on column CECRED.TBCC_PREJUIZO_LANCAMENTO.dthrtran 
 is 'Data e hora do lancamento';
comment on column CECRED.TBCC_PREJUIZO_LANCAMENTO.dtliberacao 
 is 'Data e hora de liberação do credito';
comment on column CECRED.TBCC_PREJUIZO_LANCAMENTO.cdoperad_liberacao  
 is 'Codigo do operador da liberação do credito';

-- Constraints
alter table CECRED.TBCC_PREJUIZO_LANCAMENTO
  add constraint TBCC_PREJUIZO_LANCAMENTO_PK primary key (idlancto_prejuizo);

-- Create sequence 
create sequence CECRED.SEQ_CC_LANCTO_PREJUZ_ID
minvalue 1
maxvalue 9999999999
start with 1
increment by 1
cache 20;

-- Trigger para geração do ID
CREATE OR REPLACE TRIGGER CECRED.TRG_CC_LANCTO_PREJUZ_ID
  BEFORE INSERT
  ON TBCC_PREJUIZO_LANCAMENTO
  FOR EACH ROW
    BEGIN
      SELECT CECRED.SEQ_CC_LANCTO_PREJUZ_ID.NEXTVAL
        INTO :NEW.idlancto_prejuizo
        FROM DUAL;

    EXCEPTION 
	  WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20100,'ERRO GERACAO SEQ_CC_LANCTO_PREJUZ_ID!');
    END;
/