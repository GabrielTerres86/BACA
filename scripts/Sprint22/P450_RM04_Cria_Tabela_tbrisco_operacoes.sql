create table CECRED.TBRISCO_OPERACOES
(
  cdcooper            NUMBER(5)  not null,
  nrdconta            NUMBER(10) not null,
  nrctremp            NUMBER(10) not null,
  tpctrato            NUMBER(2)  not null,

  inrisco_inclusao    NUMBER(5),
  inrisco_calculado   NUMBER(5),

  inrisco_melhora     NUMBER(5),
  dtrisco_melhora     date,
  cdcritica_melhora   number

);

comment on table CECRED.TBRISCO_OPERACOES
  is 'Centralizadora de Riscos da Operacao';
comment on column CECRED.TBRISCO_OPERACOES.cdcooper
  is 'Codigo que identifica a cooperativa';
comment on column CECRED.TBRISCO_OPERACOES.nrdconta
  is 'Numero da Conta DV';
comment on column CECRED.TBRISCO_OPERACOES.nrctremp
  is 'Numero do Emprestimo';
comment on column CECRED.TBRISCO_OPERACOES.tpctrato
  is 'Identificador do Tipo de Contrato (tbgen_dominio_campo)';
  

comment on column CECRED.TBRISCO_CENTRAL_OCR.inrisco_calculado
  is 'Nivel de Risco Calculado da Operacao';
comment on column CECRED.TBRISCO_CENTRAL_OCR.inrisco_inclusao
  is 'Nivel de Risco da Inclusao (Original)';


comment on column CECRED.CRAPEPR.INRISCO_MELHORA
  is 'Nivel do Risco Melhora';
comment on column CECRED.CRAPEPR.DTRISCO_MELHORA
  is 'Data do Último Cálculo do Risco Melhora';
comment on column CECRED.CRAPEPR.CDCRITICA_MELHORA
  is 'Codigo da Critica para nao calculo do Risco Melhora';


alter table CECRED.TBRISCO_OPERACOES
  add constraint TBRISCO_OPERACOES_PK primary key (CDCOOPER,NRDCONTA,NRCTREMP,TPCTRATO);

  