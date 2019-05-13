-- Create table
CREATE TABLE WT_EREL_EXTRAC07_PARC 
(NR_SEQ_PARC                   NUMBER(15)   NOT NULL,
 DATA_MOVIMENTO                DATE         NOT NULL, 
 NUM_PARC                      NUMBER(4)    NOT NULL,     
 DATA_GRAVACAO                 DATE,          
 COD_COOPERATIVA               NUMBER(12)   NOT NULL,    
 NUM_CONTA                     NUMBER(12)   NOT NULL,    
 NUM_CONTRATO_AILOS            NUMBER(12)   NOT NULL,  
 VAL_SALDO_PARC                NUMBER(15,2),  
 VAL_MORA_ATRASO               NUMBER(15,2),  
 VAL_MULTA_ATRASO              NUMBER(15,2),  
 VAL_IOF_ATRASO                NUMBER(15,2),  
 VAL_DESC_ANTECIPACAO          NUMBER(15,2),  
 DATA_PAGTO_PARC               DATE, 
 FLAG_PARCELA                  VARCHAR2(1)  
);

-- Add comments to the table 
comment on table WT_EREL_EXTRAC07_PARC is 'Tabela que armazena as informações das parcelas do contrato consignado enviados pela FIS Brasil';

-- Add comments to the columns 
comment on column WT_EREL_EXTRAC07_PARC.NR_SEQ_PARC                is 'Sequencial da tabela.';
comment on column WT_EREL_EXTRAC07_PARC.DATA_MOVIMENTO             is 'Data  que será foi usada para efetuar a seleção das informações e gravação, data informada no inicio do processamento';  
comment on column WT_EREL_EXTRAC07_PARC.NUM_PARC                   is 'Numero da Parcela'; 
comment on column WT_EREL_EXTRAC07_PARC.DATA_GRAVACAO              is 'Data em que o registro foi gravado na tabela';           
comment on column WT_EREL_EXTRAC07_PARC.COD_COOPERATIVA            is 'Código que identifica a cooperativa';  
comment on column WT_EREL_EXTRAC07_PARC.NUM_CONTA                  is 'Número da conta';         
comment on column WT_EREL_EXTRAC07_PARC.NUM_CONTRATO_AILOS         is 'Número do contrato'; 
comment on column WT_EREL_EXTRAC07_PARC.VAL_SALDO_PARC             is 'Saldo da Parcela que falta ser cobrada';     
comment on column WT_EREL_EXTRAC07_PARC.VAL_MORA_ATRASO            is 'Valor da Mora';   
comment on column WT_EREL_EXTRAC07_PARC.VAL_MULTA_ATRASO           is 'valor da Multa';  
comment on column WT_EREL_EXTRAC07_PARC.VAL_IOF_ATRASO             is 'Valor de IOF por Atraso';    
comment on column WT_EREL_EXTRAC07_PARC.VAL_DESC_ANTECIPACAO       is 'Valor dos Descontos Antecipados';
comment on column WT_EREL_EXTRAC07_PARC.DATA_PAGTO_PARC            is 'Data do Pagamento da Parcela';    
comment on column WT_EREL_EXTRAC07_PARC.FLAG_PARCELA               is 'Indicador se o empréstimo foi liquidado(0 – Em aberto, 1 – Liquidado)';

-- Create/Recreate primary, unique and foreign key constraints 
alter table WT_EREL_EXTRAC07_PARC
  add constraint WT_EREL_EXTRAC07_PARC_PK primary key (NR_SEQUENCIA_PARC);

-- Create/Recreate indexes 
create index CECRED.WT_EREL_EXTRAC07_CONTR_I1 
    on CECRED.WT_EREL_EXTRAC07_CONTR (COD_COOPERATIVA,NUM_CONTA,NUM_CONTRATO_AILOS,NUM_PARC ) 
  
