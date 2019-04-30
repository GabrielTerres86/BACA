-- Create table
create table TBEPR_CONSIGNADO_DEB_CONVENIAD
( IDEPR_CONSIGNADO_DEB_CONVENIAD NUMBER NOT NULL,
  CDCOOPER     NUMBER(10)   NOT NULL,
  CDEMPRES     NUMBER(10)   NOT NULL,
  IDPAGTO      NUMBER       NOT NULL,
  VRDEBITO     NUMBER(25,2) NOT NULL, 
  INSTATUS     NUMBER(5),    
  CDOPERAD     VARCHAR2(10) NOT NULL,
  DTINCREG     DATE         DEFAULT SYSDATE NOT NULL,           
  DTUPDREG     DATE);

-- Add comments to the table 
comment on table TBEPR_CONSIGNADO_DEB_CONVENIAD is 'Tabela que armazena as informações do consignado enviados pela FIS Brasil para débito da conveniada.';
-- Add comments to the columns 
comment on column TBEPR_CONSIGNADO_DEB_CONVENIAD.IDEPR_CONSIGNADO_DEB_CONVENIAD  is 'Número sequencial da tabela';
comment on column TBEPR_CONSIGNADO_DEB_CONVENIAD.CDCOOPER is 'Codigo da Cooperativa';
comment on column TBEPR_CONSIGNADO_DEB_CONVENIAD.CDEMPRES is 'Codigo da empresa';
comment on column TBEPR_CONSIGNADO_DEB_CONVENIAD.IDPAGTO  is 'Identificador de pagamento da FIS';
comment on column TBEPR_CONSIGNADO_DEB_CONVENIAD.VRDEBITO is 'Valor do débito da conveniada';
comment on column TBEPR_CONSIGNADO_DEB_CONVENIAD.INSTATUS is 'Indicador de processamento';
comment on column TBEPR_CONSIGNADO_DEB_CONVENIAD.CDOPERAD is 'Codigo do Operador';
comment on column TBEPR_CONSIGNADO_DEB_CONVENIAD.DTINCREG is 'Data de inclusão do registro';
comment on column TBEPR_CONSIGNADO_DEB_CONVENIAD.DTUPDREG is 'Data de alteração do registro';

-- Create/Recreate primary, unique and foreign key constraints 
alter table TBEPR_CONSIGNADO_DEB_CONVENIAD
  add constraint TBEPR_CONSIGNADO_DEB_CONVENIAD_PK primary key (IDEPR_CONSIGNADO_DEB_CONVENIAD);
 
