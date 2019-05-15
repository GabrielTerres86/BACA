-- Create table
create table TBEPR_CONSIG_MOVIMENTO_TMP
( IDSEQMOV                NUMBER(15)   NOT NULL,
  CDCOOPER                NUMBER(12)   NOT NULL,   
  NRDCONTA                NUMBER(12)   NOT NULL,   
  NRCTREMP                NUMBER(12)   NOT NULL,
  NRPARCELA               NUMBER(4)    NOT NULL, 
  DTMOVIMENTO             DATE         NOT NULL,           
  DTGRAVACAO              DATE         DEFAULT SYSDATE,      
  VLDEBITO                NUMBER(15,2), 
  VLCREDITO               NUMBER(15,2), 
  VLSALDO                 NUMBER(15,2), 
	INTPLANCAMENTO          NUMBER(3),
  INSTATUSPROCES          VARCHAR2(1),
  DSERROPROCES            VARCHAR2(500)
);

-- Add comments to the table 
comment on table TBEPR_CONSIG_MOVIMENTO_TMP is 'Tabela que armazena as informacoes do movimento do contrato consignado enviados pela FIS Brasil';

-- Add comments to the columns 
comment on column TBEPR_CONSIG_MOVIMENTO_TMP.IDSEQMOV              is 'Sequencia da Tabela';
comment on column TBEPR_CONSIG_MOVIMENTO_TMP.CDCOOPER              is 'Codigo que identifica a cooperativa';
comment on column TBEPR_CONSIG_MOVIMENTO_TMP.NRDCONTA              is 'Numero da conta';
comment on column TBEPR_CONSIG_MOVIMENTO_TMP.NRCTREMP              is 'Numero do contrato';
comment on column TBEPR_CONSIG_MOVIMENTO_TMP.NRPARCELA             is 'Quando for Pagamento de parcelas o Numero dela';
comment on column TBEPR_CONSIG_MOVIMENTO_TMP.DTMOVIMENTO           is 'Data que o lancamento foi realizado';         
comment on column TBEPR_CONSIG_MOVIMENTO_TMP.DTGRAVACAO            is 'Data em que o registro foi gravado na tabela';           
comment on column TBEPR_CONSIG_MOVIMENTO_TMP.VLDEBITO              is 'Valor lancado a Debito';
comment on column TBEPR_CONSIG_MOVIMENTO_TMP.VLCREDITO             is 'Valor lancado a Credito';
comment on column TBEPR_CONSIG_MOVIMENTO_TMP.VLSALDO               is 'Saldo Final';
comment on column TBEPR_CONSIG_MOVIMENTO_TMP.INTPLANCAMENTO        is '1 - Valor liberado para o cliente (Debito)
                                                                      2 - Valor de Pagamento - Valor Principal amortizada (Credito)
                                                                      3 - Valor de Pagamento - Valor Juros amortizado (Credito)
                                                                      4 - Valor de Pagamento de Juros de Mora por atraso (Debito)
                                                                      5 - Valor de Pagamento de Multa por Atraso (Debito)
                                                                      6 - Valor de Pagamento de IOF Atraso (Debito)
                                                                      7 - Valor de Desconto (Credito)
                                                                      8 - Valor de IOF cobrado (Credito)
                                                                      9 - Valor de TAC cobrada (Credito)
                                                                      10 - Valor do Juros Renumeratorio (Credito)
                                                                      11 - Estorno Pagamento - Valor Principal amortizada (Credito)
                                                                      12 - Estorno Pagamento - Valor Juros amortizado (Credito)
                                                                      13 - Estorno Pagamento - Juros de Mora (Credito)
                                                                      14 - Estorno Pagamento - Multa (Credito)
                                                                      15 - Estorno Pagamento - IOF Atraso (Credito)
                                                                      16 - Estorno Pagamento - Desconto Parcela (Debito)';
comment on column TBEPR_CONSIG_MOVIMENTO_TMP.INSTATUSPROCES       is 'Indicador do status do processamento(1 - Pendente/2 - Processado/3 - Erro)';
comment on column TBEPR_CONSIG_MOVIMENTO_TMP.DSERROPROCES         is 'Descrição do erro de processamento';

-- Create/Recreate primary, unique and foreign key constraints 
alter table TBEPR_CONSIG_MOVIMENTO_TMP
  add constraint TBEPR_CONSIG_MOVIMENTO_TMP_PK primary key (IDSEQMOV);

-- Create/Recreate indexes 
create index TBEPR_CONSIG_MOVIMENTO_TMP_IDX1 
    on TBEPR_CONSIG_MOVIMENTO_TMP(CDCOOPER,NRDCONTA,NRCTREMP,NRPARCELA,DTMOVIMENTO );    

-- Create sequence 
create sequence SEQTBEPR_CONSIG_MOVIMENTO_TMP
minvalue 1
maxvalue 999999999999999
start with 1
increment by 1
nocache
order;

-- Create Trigger
CREATE OR REPLACE TRIGGER TRGTBEPR_CONSIG_MOVIMENTO_TMP
BEFORE INSERT ON TBEPR_CONSIG_MOVIMENTO_TMP

FOR EACH ROW

BEGIN
  
  IF :NEW.IDSEQMOV IS NULL THEN
    :NEW.IDSEQMOV := SEQTBEPR_CONSIG_MOVIMENTO_TMP.NEXTVAL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO GERACAO SEQUENCE IDSEQMOV - TABELA TBEPR_CONSIG_MOVIMENTO_TMP!');
END;         
 

