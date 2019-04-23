-- Create table
create table TBEPR_CONSIGNADO
( CDCOOPER   NUMBER(5)  DEFAULT 0 NOT NULL,
  NRDCONTA   NUMBER(10) DEFAULT 0 NOT NULL,
  NRCTREMP   NUMBER(10) DEFAULT 0 NOT NULL,
  VLJURA60   NUMBER(25,2)
);

-- Add comments to the table 
comment on table TBEPR_CONSIGNADO is 'Tabela que armazena as informações do empréstimo consignado enviados pela FIS Brasil';
-- Add comments to the columns 
comment on column TBEPR_CONSIGNADO.CDCOOPER is 'Codigo da Cooperativa';
comment on column TBEPR_CONSIGNADO.NRDCONTA is 'Numero da Conta Corrente do Cooperado';
comment on column TBEPR_CONSIGNADO.NRCTREMP is 'Numero do contrato de emprestimo';
comment on column TBEPR_CONSIGNADO.VLJURA60 is 'Valor do juros em Atraso a mais de 60 dias';

-- Create/Recreate primary, unique and foreign key constraints 
alter table TBEPR_CONSIGNADO
  add constraint TBEPR_CONSIGNADO_PK primary key (CDCOOPER,NRDCONTA,NRCTREMP);
 
