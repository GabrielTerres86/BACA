-- Create table
CREATE TABLE TBEPR_CONSIG_PARCELAS_TMP
(IDSEQPARC                  NUMBER(15)   NOT NULL,
 CDCOOPER                   NUMBER(12)   NOT NULL,    
 NRDCONTA                   NUMBER(12)   NOT NULL,    
 NRCTREMP                   NUMBER(12)   NOT NULL, 
 NRPARCELA                  NUMBER(4)    NOT NULL,     
 DTMOVIMENTO                DATE         NOT NULL, 
 DTGRAVACAO                 DATE         DEFAULT SYSDATE,  
 VLSALDOPARC                NUMBER(15,2),  
 VLMORAATRASO               NUMBER(15,2),  
 VLMULTAATRASO              NUMBER(15,2),  
 VLIOFATRASO                NUMBER(15,2),  
 VLDESCANTEC                NUMBER(15,2),  
 DTPAGTOPARC                DATE, 
 INPARCELALIQ               VARCHAR2(1),
 INSTATUSPROCES             VARCHAR2(1),
 DSERROPROCES               VARCHAR2(500)  
);

-- Add comments to the table 
comment on table TBEPR_CONSIG_PARCELAS_TMP is 'Tabela que armazena as informacoes das parcelas do contrato consignado enviados pela FIS Brasil';

-- Add comments to the columns 
comment on column TBEPR_CONSIG_PARCELAS_TMP.IDSEQPARC           is 'Sequencial da tabela.';
comment on column TBEPR_CONSIG_PARCELAS_TMP.CDCOOPER            is 'Codigo que identifica a cooperativa';  
comment on column TBEPR_CONSIG_PARCELAS_TMP.NRDCONTA            is 'Numero da conta';         
comment on column TBEPR_CONSIG_PARCELAS_TMP.NRCTREMP            is 'Numero do contrato'; 
comment on column TBEPR_CONSIG_PARCELAS_TMP.NRPARCELA           is 'Numero da Parcela'; 
comment on column TBEPR_CONSIG_PARCELAS_TMP.DTMOVIMENTO         is 'Data  que sera foi usada para efetuar a selecao das informacoes e gravacao, data informada no inicio do processamento';  
comment on column TBEPR_CONSIG_PARCELAS_TMP.DTGRAVACAO          is 'Data em que o registro foi gravado na tabela';           
comment on column TBEPR_CONSIG_PARCELAS_TMP.VLSALDOPARC         is 'Saldo da Parcela que falta ser cobrada';     
comment on column TBEPR_CONSIG_PARCELAS_TMP.VLMORAATRASO        is 'Valor da Mora';   
comment on column TBEPR_CONSIG_PARCELAS_TMP.VLMULTAATRASO       is 'valor da Multa';  
comment on column TBEPR_CONSIG_PARCELAS_TMP.VLIOFATRASO         is 'Valor de IOF por Atraso';    
comment on column TBEPR_CONSIG_PARCELAS_TMP.VLDESCANTEC         is 'Valor dos Descontos Antecipados';
comment on column TBEPR_CONSIG_PARCELAS_TMP.DTPAGTOPARC         is 'Data do Pagamento da Parcela';    
comment on column TBEPR_CONSIG_PARCELAS_TMP.INPARCELALIQ        is 'Indicador se o emprestimo foi liquidado(0 – Em aberto, 1 – Liquidado)';
comment on column TBEPR_CONSIG_PARCELAS_TMP.INSTATUSPROCES      is 'Indicador do status do processamento(1 - Pendente/2 - Processado/3 - Erro)';
comment on column TBEPR_CONSIG_PARCELAS_TMP.DSERROPROCES        is 'Descrição do erro de processamento';

-- Create/Recreate primary, unique and foreign key constraints 
alter table TBEPR_CONSIG_PARCELAS_TMP
  add constraint TBEPR_CONSIG_PARCELAS_TMP_PK primary key (IDSEQPARC);

-- Create/Recreate indexes 
create index TBEPR_CONSIG_PARCELAS_TMP_IDX1 
    on TBEPR_CONSIG_PARCELAS_TMP (CDCOOPER,NRDCONTA,NRCTREMP,NRPARCELA,DTMOVIMENTO );

-- Create sequence 
create sequence SEQTBEPR_CONSIG_PARCELAS_TMP
minvalue 1
maxvalue 999999999999999
start with 1
increment by 1
nocache
order;

-- Create Trigger
CREATE OR REPLACE TRIGGER TRGTBEPR_CONSIG_PARCELAS_TMP
BEFORE INSERT ON TBEPR_CONSIG_PARCELAS_TMP

FOR EACH ROW

BEGIN
  
  IF :NEW.IDSEQPARC IS NULL THEN
    :NEW.IDSEQPARC := SEQTBEPR_CONSIG_PARCELAS_TMP.NEXTVAL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100,'ERRO GERACAO SEQUENCE IDSEQPARC - TABELA TBEPR_CONSIG_PARCELAS_TMP!');
END;      
  
