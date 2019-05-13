-- Create table
create table WT_EREL_EXTRAC07_CONTR
(	NR_SEQ_CONTR                NUMBER(15)   NOT NULL,
  DATA_GRAVACAO               DATE,          
	DATA_MOVIMENTO              DATE         NOT NULL, 
	CLIENTE_DESLIGADO           VARCHAR2(1), 
	COD_COOPERATIVA             NUMBER(12)   NOT NULL,   
	NUM_CONTA                   NUMBER(12)   NOT NULL,   
	NUM_CONTRATO_AILOS          NUMBER(12)   NOT NULL,   
	VALOR_IOF                   NUMBER(15,2),  
	VALOR_IOF_ADIC              NUMBER(15,2), 
	QTDE_PRESTACOES_PAGAS       NUMBER(6),    
	VAL_JUR_ACUM_MES_ATU        NUMBER(15,2), 
	VAL_JUR_ACUM_MES_ANT        NUMBER(15,2), 
	VAL_SALDO_DEV_EMPR_ATU_D0   NUMBER(15,2), 
	VAL_SALDO_DEV_EMPR_ATU_D1   NUMBER(15,2), 
	VAL_JUR_60_DIAS             NUMBER(15,2), 
	STATUS_CONTRATO             VARCHAR2(1)
);

-- Add comments to the table 
comment on table WT_EREL_EXTRAC07_CONTR is 'Tabela que armazena as informações do contrato consignado enviados pela FIS Brasil';

-- Add comments to the columns 
comment on column WT_EREL_EXTRAC07_CONTR.NR_SEQ_CONTR               is 'Sequencial da tabela.';    
comment on column WT_EREL_EXTRAC07_CONTR.DATA_GRAVACAO              is 'Data em que o registro foi gravado na tabela';           
comment on column WT_EREL_EXTRAC07_CONTR.DATA_MOVIMENTO             is 'Data  que será foi usada para efetuar a seleção das informações e gravação, data informada no inicio do processamento';         
comment on column WT_EREL_EXTRAC07_CONTR.CLIENTE_DESLIGADO          is 'Indica se o cliente foi desligado (1 = Sim / 2 = Não)';      
comment on column WT_EREL_EXTRAC07_CONTR.COD_COOPERATIVA            is 'Código que identifica a cooperativa';
comment on column WT_EREL_EXTRAC07_CONTR.NUM_CONTA                  is 'Número da conta';      
comment on column WT_EREL_EXTRAC07_CONTR.NUM_CONTRATO_AILOS         is 'Número do contrato';      
comment on column WT_EREL_EXTRAC07_CONTR.VALOR_IOF                  is 'Valor do IOF Normal ( Valor do IOF cobrado - Valor do IOF Adicional)';      
comment on column WT_EREL_EXTRAC07_CONTR.VALOR_IOF_ADIC             is 'Valor do IOF Adicional - Calcula o valor do IOF Adcional';      
comment on column WT_EREL_EXTRAC07_CONTR.QTDE_PRESTACOES_PAGAS      is 'Quantidade de Prestação Paga';   
comment on column WT_EREL_EXTRAC07_CONTR.VAL_JUR_ACUM_MES_ATU       is 'Soma dos Juros acumulados no mês corrente, que será zerado na virada do mês. Iremos Somar os juros da parcela ( Valor da PMT - Valor principal da parcela), das parcelas vencidas até a data do movimento';
comment on column WT_EREL_EXTRAC07_CONTR.VAL_JUR_ACUM_MES_ANT       is 'Soma dos Juros acumulados no mês anterior. Iremos Somar os juros da parcela ( Valor da PMT - Valor principal da parcela), de todas as parcelas vencidas no mês anterior a data do movimento';
comment on column WT_EREL_EXTRAC07_CONTR.VAL_SALDO_DEV_EMPR_ATU_D0  is 'Saldo do contrato: parcelas vencidas atualizadas + parcelas a vencer trazidas a valor presente (DO)';
comment on column WT_EREL_EXTRAC07_CONTR.VAL_SALDO_DEV_EMPR_ATU_D1  is 'Saldo do contrato: parcelas vencidas atualizadas + parcelas a vencer trazidas a valor presente (D1)'; 
comment on column WT_EREL_EXTRAC07_CONTR.VAL_JUR_60_DIAS            is 'Valor dos juros cobrados até 60 dias, quando se congela o accrual de juros'; 
comment on column WT_EREL_EXTRAC07_CONTR.STATUS_CONTRATO            is 'Indica se o empréstimo foi liquidado(1 – Em aberto/2 – Liquidado/3 – Cancelado/4 - Prejuizo');


-- Create/Recreate primary, unique and foreign key constraints 
alter table WT_EREL_EXTRAC07_CONTR
  add constraint WT_EREL_EXTRAC07_CONTR_PK primary key (NR_SEQUENCIA_CONTR); 

-- Create/Recreate indexes 
create unique index CECRED.WT_EREL_EXTRAC07_CONTR_I1 
    on CECRED.WT_EREL_EXTRAC07_CONTR (COD_COOPERATIVA,NUM_CONTA,NUM_CONTRATO_AILOS ) 

