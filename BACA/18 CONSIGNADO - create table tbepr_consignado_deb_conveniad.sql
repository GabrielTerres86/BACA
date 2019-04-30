-- Create table
create table TBEPR_CONSIGNADO_DEBCONVEN
( IDSEQUENCIA  NUMBER NOT NULL,
  CDCOOPER     NUMBER(10)   NOT NULL,
  CDEMPRES     NUMBER(10)   NOT NULL,
  IDPAGTO      NUMBER       NOT NULL,
  VRDEBITO     NUMBER(25,2) NOT NULL, 
  INSTATUS     NUMBER(5),    
  CDOPERAD     VARCHAR2(10) NOT NULL,
  DTINCREG     DATE         DEFAULT SYSDATE NOT NULL,           
  DTUPDREG     DATE);

-- Add comments to the table 
comment on table TBEPR_CONSIGNADO_DEBCONVEN is 'Tabela de controle de debito da conveiada.';
-- Add comments to the columns 
comment on column TBEPR_CONSIGNADO_DEBCONVEN.IDSEQUENCIA  is 'Numero sequencial da tabela';
comment on column TBEPR_CONSIGNADO_DEBCONVEN.CDCOOPER is 'Codigo da Cooperativa';
comment on column TBEPR_CONSIGNADO_DEBCONVEN.CDEMPRES is 'Codigo da empresa';
comment on column TBEPR_CONSIGNADO_DEBCONVEN.IDPAGTO  is 'Identificador de pagamento da FIS';
comment on column TBEPR_CONSIGNADO_DEBCONVEN.VRDEBITO is 'Valor do debito da conveniada';
comment on column TBEPR_CONSIGNADO_DEBCONVEN.INSTATUS is 'Indicador de processamento';
comment on column TBEPR_CONSIGNADO_DEBCONVEN.CDOPERAD is 'Codigo do Operador';
comment on column TBEPR_CONSIGNADO_DEBCONVEN.DTINCREG is 'Data de inclusao do registro';
comment on column TBEPR_CONSIGNADO_DEBCONVEN.DTUPDREG is 'Data de alteracao do registro';

-- Create/Recreate primary, unique and foreign key constraints 
alter table TBEPR_CONSIGNADO_DEBCONVEN
  add constraint TBEPR_CONSIGNADO_DEBCONVEN_PK primary key (IDSEQUENCIA);
  
-- Create sequence 
create sequence CECRED.TBEPR_CONSIG_DEBCONV_SEQ
minvalue 1
maxvalue 9999999999999999999999999999
start with 1
increment by 1
nocache
order;

-- Create Trigger
CREATE OR REPLACE TRIGGER CECRED.TBEPR_CONSIGNADO_DEBCONVEN
BEFORE INSERT ON TBEPR_CONSIGNADO_DEBCONVEN

FOR EACH ROW

BEGIN
  
  IF :NEW.IDSEQUENCIA IS NULL THEN
    :NEW.IDSEQUENCIA := TBEPR_CONSIG_DEBCONV_SEQ.NEXTVAL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO GERACAO SEQUENCE IDSEQUENCIA - TABELA TBEPR_CONSIGNADO_DEBCONVEN!');
END;  
  
  
 
