-- Create table
create table TBEPR_CONSIG_CONTRATO_TMP
(	IDSEQCONTR               NUMBER(15)   NOT NULL,
  CDCOOPER                 NUMBER(12)   NOT NULL,   
	NRDCONTA                 NUMBER(12)   NOT NULL,   
	NRCTREMP                 NUMBER(12)   NOT NULL,
  DTMOVIMENTO              DATE         NOT NULL,
  DTGRAVACAO               DATE         DEFAULT SYSDATE,
	INCLIDESLIGADO           VARCHAR2(1),
	VLIOFEPR                 NUMBER(15,2),  
	VLIOFADIC                NUMBER(15,2), 
	QTPRESTPAGAS             NUMBER(6),    
	VLJURAMESATU             NUMBER(15,2), 
	VLJURAMESANT             NUMBER(15,2), 
	VLSDEV_EMPRATU_D0        NUMBER(15,2), 
	VLSDEV_EMPRATU_D1        NUMBER(15,2), 
	VLJURA60DIAS             NUMBER(15,2), 
	INSTATUSCONTR            VARCHAR2(1),
  INSTATUSPROCES           VARCHAR2(1),
  DSERROPROCES             VARCHAR2(500));

-- Add comments to the table 
comment on table TBEPR_CONSIG_CONTRATO_TMP is 'Tabela que armazena as informacoes do contrato consignado enviados pela FIS Brasil';

-- Add comments to the columns 
comment on column TBEPR_CONSIG_CONTRATO_TMP.IDSEQCONTR          is 'Sequencial da tabela.';    
comment on column TBEPR_CONSIG_CONTRATO_TMP.CDCOOPER            is 'Codigo que identifica a cooperativa';
comment on column TBEPR_CONSIG_CONTRATO_TMP.NRDCONTA            is 'Numero da conta';      
comment on column TBEPR_CONSIG_CONTRATO_TMP.NRCTREMP            is 'Numero do contrato';      
comment on column TBEPR_CONSIG_CONTRATO_TMP.DTMOVIMENTO         is 'Data usada para efetuar a selecao das informacoes e gravacao, data informada no inicio do processamento';         
comment on column TBEPR_CONSIG_CONTRATO_TMP.DTGRAVACAO          is 'Data em que o registro foi gravado na tabela';           
comment on column TBEPR_CONSIG_CONTRATO_TMP.INCLIDESLIGADO      is 'Indica se o cliente foi desligado (1 = Sim / 2 = Nao)';      
comment on column TBEPR_CONSIG_CONTRATO_TMP.VLIOFEPR            is 'Valor do IOF Normal ( Valor do IOF cobrado - Valor do IOF Adicional)';      
comment on column TBEPR_CONSIG_CONTRATO_TMP.VLIOFADIC           is 'Valor do IOF Adicional - Calcula o valor do IOF Adcional';      
comment on column TBEPR_CONSIG_CONTRATO_TMP.QTPRESTPAGAS        is 'Quantidade de Prestacao Paga';   
comment on column TBEPR_CONSIG_CONTRATO_TMP.VLJURAMESATU        is 'Soma dos Juros acumulados no mes corrente, que sera zerado na virada do mes. Iremos Somar os juros da parcela ( Valor da PMT - Valor principal da parcela), das parcelas vencidas ate a data do movimento';
comment on column TBEPR_CONSIG_CONTRATO_TMP.VLJURAMESANT        is 'Soma dos Juros acumulados no mes anterior. Iremos Somar os juros da parcela ( Valor da PMT - Valor principal da parcela), de todas as parcelas vencidas no mes anterior a data do movimento';
comment on column TBEPR_CONSIG_CONTRATO_TMP.VLSDEV_EMPRATU_D0   is 'Saldo do contrato: parcelas vencidas atualizadas + parcelas a vencer trazidas a valor presente (DO)';
comment on column TBEPR_CONSIG_CONTRATO_TMP.VLSDEV_EMPRATU_D1   is 'Saldo do contrato: parcelas vencidas atualizadas + parcelas a vencer trazidas a valor presente (D1)'; 
comment on column TBEPR_CONSIG_CONTRATO_TMP.VLJURA60DIAS        is 'Valor dos juros cobrados ate 60 dias, quando se congela o accrual de juros'; 
comment on column TBEPR_CONSIG_CONTRATO_TMP.INSTATUSCONTR       is 'Indica se o emprestimo foi liquidado(1 – Em aberto/2 – Liquidado/3 – Cancelado/4 - Prejuizo');
comment on column TBEPR_CONSIG_CONTRATO_TMP.INSTATUSPROCES      is 'Indicador do status do processamento(1 - Pendente/2 - Processado/3 - Erro)';
comment on column TBEPR_CONSIG_CONTRATO_TMP.DSERROPROCES        is 'Descrição do erro de processamento';

-- Create/Recreate primary, unique and foreign key constraints 
alter table TBEPR_CONSIG_CONTRATO_TMP
  add constraint TBEPR_CONSIG_CONTRATO_TMP_PK primary key (IDSEQCONTR); 

-- Create/Recreate indexes 
create index TBEPR_CONSIG_CONTRATO_TMP_IDX1 
    on CECRED.TBEPR_CONSIG_CONTRATO_TMP (CDCOOPER,NRDCONTA,NRCTREMP,DTMOVIMENTO );
    
-- Create sequence 
create sequence SEQTBEPR_CONSIG_CONTRATO_TMP
minvalue 1
maxvalue 999999999999999
start with 1
increment by 1
nocache
order;

-- Create Trigger
CREATE OR REPLACE TRIGGER TRGTBEPR_CONSIG_CONTRATO_TMP
BEFORE INSERT ON TBEPR_CONSIG_CONTRATO_TMP

FOR EACH ROW

BEGIN
  
  IF :NEW.IDSEQCONTR IS NULL THEN
    :NEW.IDSEQCONTR := SEQTBEPR_CONSIG_CONTRATO_TMP.NEXTVAL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO GERACAO SEQUENCE IDSEQCONTR - TABELA TBEPR_CONSIG_CONTRATO_TMP!');
END;  
  
  
 
    

