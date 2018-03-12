-- Criação da tabela
create table CECRED.TBRISCO_CENTRAL_OCR
(cdcooper         NUMBER(10) NOT NULL
,nrcpfcgc         NUMBER(25) NOT NULL
,nrdconta         NUMBER(10) NOT NULL
,nrctremp         NUMBER(10)
,cdmodali         NUMBER(5)
,nrdgrupo         NUMBER(11)
,dtrefere         DATE       NOT NULL
,dtdrisco         DATE
,inrisco_inclusao NUMBER(5)
,inrisco_rating   NUMBER(5)
,inrisco_atraso   NUMBER(5)
,inrisco_agravado NUMBER(5)
,inrisco_melhora  NUMBER(5)
,inrisco_operacao NUMBER(5)
,inrisco_cpf      NUMBER(5)
,inrisco_grupo    NUMBER(5)
,inrisco_final    NUMBER(5))
/
-- Comentário na tabela
comment on table CECRED.TBRISCO_CENTRAL_OCR is 'Central de Risco consolidado(Dados Brutos)'
/
-- Comentários nas colunas da tabela
comment on column CECRED.TBRISCO_CENTRAL_OCR.cdcooper is 'Codigo que identifica a cooperativa'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.nrcpfcgc is 'Numero do CPF/CNPJ'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.nrdconta is 'Numero da conta'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.nrctremp is 'Numero do contrato'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.cdmodali is 'Codigo da modalidade para identificar o tipo de contrato'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.nrdgrupo is 'Numero/Codigo do Grupo Economico'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.dtrefere is 'Data de referencia'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.dtdrisco is 'Data do risco'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.inrisco_inclusao is 'Nivel de risco da Inclusao'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.inrisco_rating is 'Nivel de risco do Rating'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.inrisco_atraso is 'Nivel de risco do Atraso'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.inrisco_agravado is 'Nivel de risco Agravado'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.inrisco_melhora is 'Nivel de risco da Melhora'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.inrisco_operacao is 'Nivel de risco da Operacao'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.inrisco_cpf is 'Nivel de risco do CPF'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.inrisco_grupo is 'Nivel de risco do Grupo Economico'
/
comment on column CECRED.TBRISCO_CENTRAL_OCR.inrisco_final is 'Nivel de risco Final'
/
alter table CECRED.TBRISCO_CENTRAL_OCR
  add constraint TBRISCO_CENTRAL_OCR_PK primary key (DTREFERE, CDCOOPER, NRDCONTA, NRCTREMP, CDMODALI)
/