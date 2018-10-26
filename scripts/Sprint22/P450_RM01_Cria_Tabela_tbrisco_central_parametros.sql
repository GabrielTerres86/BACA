create table CECRED.TBRISCO_CENTRAL_PARAMETROS
(
  cdcooper                     NUMBER(5)              not null,
  perc_liquid_sem_garantia     NUMBER(3,2) DEFAULT 30 not null,
  perc_cobert_aplic_bloqueada  NUMBER(3,2) DEFAULT 70 not null,
  inrisco_melhora_minimo       NUMBER(5)   DEFAULT 2  NOT NULL,
  dthr_alteracao               DATE                   not null,
  cdoperador_alteracao         VARCHAR2(10)           not null
)

-- Add comments to the table
comment on table CECRED.TBRISCO_CENTRAL_PARAMETROS
  is 'Parametros para Central de Risco';
-- Add comments to the columns
comment on column CECRED.TBRISCO_CENTRAL_PARAMETROS.cdcooper
  is 'Codigo que identifica a cooperativa';
comment on column CECRED.TBRISCO_CENTRAL_PARAMETROS.perc_liquid_sem_garantia
  is 'Percentual de Liquidacao para Melhora risco SEM garantia';
comment on column CECRED.TBRISCO_CENTRAL_PARAMETROS.perc_cobert_aplic_bloqueada
  is 'Percentual de Cobertura Aplicacoes Bloqueadas';
comment on column CECRED.TBRISCO_CENTRAL_PARAMETROS.inrisco_melhora_minimo
  is 'Menor Risco Possivel para Risco Melhora';
comment on column CECRED.TBRISCO_CENTRAL_PARAMETROS.dthr_alteracao
  is 'Data e Hora de Alteracao dos Parametros';
comment on column CECRED.TBRISCO_CENTRAL_PARAMETROS.cdoperador_alteracao
  is 'Operador que Efetuou Alteracao dos Parametros';

alter table CECRED.TBRISCO_CENTRAL_PARAMETROS
  add constraint TBRISCO_CENTRAL_PARAMETROS_PK primary key (CDCOOPER);
