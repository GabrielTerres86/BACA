-- Script de cria��o da tabela de vig�ncias de tarifas conv�nio Sicredi
-- Create table
create table CECRED.tbconv_historico_tarifa
(
  cdhistor  NUMBER(5)    default 0,
  dsorigem  VARCHAR2(13) default ' ',
  vltarifa  NUMBER(25,2) default 0,
  cdcooper  NUMBER(10)   default 0,
  dtvigenc  DATE         default sysdate
)

-- Add comments to the table 
comment on table CECRED.tbconv_historico_tarifa
  is 'Vig�ncia das tarifas dos historicos(por canal)';
-- Add comments to the columns 
comment on column CECRED.tbconv_historico_tarifa.cdhistor
  is 'Codigo do historico da tarifa especial.';
comment on column CECRED.tbconv_historico_tarifa.dsorigem
  is 'Sistema no qual foi originada a operacao.';
comment on column CECRED.tbconv_historico_tarifa.vltarifa
  is 'Tarifa do historico.';
comment on column CECRED.tbconv_historico_tarifa.cdcooper
  is 'Codigo que identifica a Cooperativa.';
comment on column CECRED.tbconv_historico_tarifa.dtvigenc
  is 'Data de vig�ncia do valor da tarifa de acordo com a importa��o do arquivo.';  

-- Create/Recreate primary, unique and foreign key constraints 
alter table CECRED.tbconv_historico_tarifa
  add constraint pk_tbconv_historico_tarifa primary key (cdcooper,cdhistor,dsorigem);
