-- Create table
create table WT_EREL_EXTRAC07_MOV
( NUM_SEQ_MOV                 NUMBER(15)   NOT NULL,         
  DATA_GRAVACAO               DATE,   
  COD_COOPERATIVA             NUMBER(12)   NOT NULL,   
  NUM_CONTA                   NUMBER(12)   NOT NULL,   
  NUM_CONTRATO_AILOS          NUMBER(12)   NOT NULL,
  DATA_MOVIMENTO              DATE         NOT NULL, 
  NUM_PARC                    NUMBER(4)    NOT NULL,    
  VAL_DEBITO                  NUMBER(15,2), 
  VAL_CREDITO                 NUMBER(15,2), 
  VAL_SALDO                   NUMBER(15,2), 
	FLAG_TIPO_LANCAMENTO        NUMBER(3)	
);

-- Add comments to the table 
comment on table WT_EREL_EXTRAC07_MOV is 'Tabela que armazena as informa��es do movimento do contrato consignado enviados pela FIS Brasil';

-- Add comments to the columns 
comment on column WT_EREL_EXTRAC07_MOV.NUM_SEQ_MOV                is 'Sequencia da Tabela';
comment on column WT_EREL_EXTRAC07_MOV.DATA_GRAVACAO              is 'Data em que o registro foi gravado na tabela';           
comment on column WT_EREL_EXTRAC07_MOV.COD_COOPERATIVA            is 'C�digo que identifica a cooperativa';
comment on column WT_EREL_EXTRAC07_MOV.NUM_CONTA                  is 'N�mero da conta';
comment on column WT_EREL_EXTRAC07_MOV.NUM_CONTRATO_AILOS         is 'N�mero do contrato';
comment on column WT_EREL_EXTRAC07_MOV.DATA_MOVIMENTO             is 'Data que o lan�amento foi realizado';         
comment on column WT_EREL_EXTRAC07_MOV.NUM_PARC                   is 'Quando for Pagamento de parcelas o Numero dela';
comment on column WT_EREL_EXTRAC07_MOV.VAL_DEBITO                 is 'Valor lan�ado a Debito';
comment on column WT_EREL_EXTRAC07_MOV.VAL_CREDITO                is 'Valor lan�ado a Cr�dito';
comment on column WT_EREL_EXTRAC07_MOV.VAL_SALDO                  is 'Saldo Final';
comment on column WT_EREL_EXTRAC07_MOV.FLAG_TIPO_LANCAMENTO       is '1 - Valor liberado para o cliente (Debito)
                                                                      2 - Valor de Pagamento - Valor Principal amortizada (Cr�dito)
                                                                      3 - Valor de Pagamento - Valor Juros amortizado (Cr�dito)
                                                                      4 - Valor de Pagamento de Juros de Mora por atraso (Debito)
                                                                      5 - Valor de Pagamento de Multa por Atraso (Debito)
                                                                      6 - Valor de Pagamento de IOF Atraso (Debito)
                                                                      7 - Valor de Desconto (Cr�dito)
                                                                      8 - Valor de IOF cobrado (Cr�dito)
                                                                      9 - Valor de TAC cobrada (Cr�dito)
                                                                      10 - Valor do Juros Renumeratorio (Cr�dito)
                                                                      11 - Estorno Pagamento - Valor Principal amortizada (Credito)
                                                                      12 - Estorno Pagamento - Valor Juros amortizado (Cr�dito)
                                                                      13 - Estorno Pagamento - Juros de Mora (Cr�dito)
                                                                      14 - Estorno Pagamento - Multa (Cr�dito)
                                                                      15 - Estorno Pagamento - IOF Atraso (Cr�dito)
                                                                      16 - Estorno Pagamento - Desconto Parcela (Debito)';

-- Create/Recreate primary, unique and foreign key constraints 
alter table WT_EREL_EXTRAC07_MOV
  add constraint WT_EREL_EXTRAC07_MOV_PK primary key (NR_SEQUENCIA_MOV);

-- Create/Recreate indexes 
create unique index CECRED.WT_EREL_EXTRAC07_CONTR_I1 
    on CECRED.WT_EREL_EXTRAC07_CONTR (COD_COOPERATIVA,NUM_CONTA,NUM_CONTRATO_AILOS,NUM_PARC,DATA_MOVIMENTO )   
 

