-- Create table
create table TBEPR_CONSIGNADO_PAGAMENTO
( IDSEQUENCIA  NUMBER       NOT NULL,
  CDCOOPER     NUMBER(10)   NOT NULL,
  NRDCONTA     NUMBER(10)   NOT NULL,
  NRCTREMP     NUMBER(10)   NOT NULL,
  NRPAREPR     NUMBER(5)    NOT NULL,
  INORGPGT     NUMBER(1),
  VLPAREPR     NUMBER(25,2),
  VLPAGPAR     NUMBER(25,2),
  DTVENCTO     DATE,
  INSTATUS     NUMBER(5),    
  DTINCREG     DATE         DEFAULT SYSDATE NOT NULL,           
  DTUPDREG     DATE);

-- Add comments to the table 
comment on table TBEPR_CONSIGNADO_PAGAMENTO is 'Tabela de controle do pagamento de parcelas do consignado.';
-- Add comments to the columns 
comment on column TBEPR_CONSIGNADO_PAGAMENTO.IDSEQUENCIA  is 'Numero sequencial da tabela.';
comment on column TBEPR_CONSIGNADO_PAGAMENTO.CDCOOPER is 'Codigo da Cooperativa.';
comment on column TBEPR_CONSIGNADO_PAGAMENTO.NRDCONTA is 'Numero da conta/dv do associado.';
comment on column TBEPR_CONSIGNADO_PAGAMENTO.NRCTREMP is 'Numero do contrato de emprestimo.';
comment on column TBEPR_CONSIGNADO_PAGAMENTO.NRPAREPR is 'Numero da parcela do emprestimo.';
comment on column TBEPR_CONSIGNADO_PAGAMENTO.INORGPGT is 'Indicador da origem do pagamento(1-Debitador unico, 2-Tela Pagar, 3-Boleto)';
comment on column TBEPR_CONSIGNADO_PAGAMENTO.VLPAREPR is 'Valor da parcela.';
comment on column TBEPR_CONSIGNADO_PAGAMENTO.VLPAGPAR is 'Valor pago da parcela.';
comment on column TBEPR_CONSIGNADO_PAGAMENTO.DTVENCTO is 'Data do vencimento da parcela.';
comment on column TBEPR_CONSIGNADO_PAGAMENTO.INSTATUS is 'Indicador do status do processamento (1 - Enviado, 2 - Pagamento efetuado FIS, 3- Erro)';
comment on column TBEPR_CONSIGNADO_PAGAMENTO.DTINCREG is 'Data de inclusao do registro';
comment on column TBEPR_CONSIGNADO_PAGAMENTO.DTUPDREG is 'Data de alteracao do registro';

-- Create/Recreate primary, unique and foreign key constraints 
alter table TBEPR_CONSIGNADO_PAGAMENTO
  add constraint TBEPR_CONSIGNADO_PAGAMENTO_PK primary key (IDSEQUENCIA);
  
-- Create sequence 
create sequence TBEPR_CONSIGNADO_PAGAMENTO_SEQ
minvalue 1
maxvalue 9999999999999999999999999999
start with 1
increment by 1
nocache
order;

insert into tbcadast_dominio_campo values ('INORGPGT','1','Debitador Único');
insert into tbcadast_dominio_campo values ('INORGPGT','2','Tela Pagar');
insert into tbcadast_dominio_campo values ('INORGPGT','3','Boleto');
commit;

-- Create Trigger
CREATE OR REPLACE TRIGGER CECRED.TBEPR_CONSIGNADO_PAGAMENTO
BEFORE INSERT ON TBEPR_CONSIGNADO_PAGAMENTO

FOR EACH ROW

BEGIN
  
  IF :NEW.IDSEQUENCIA IS NULL THEN
    :NEW.IDSEQUENCIA := TBEPR_CONSIGNADO_PAGAMENTO_SEQ.NEXTVAL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO GERACAO SEQUENCE IDSEQUENCIA - TABELA TBEPR_CONSIGNADO_PAGAMENTO!');
END;  
  
