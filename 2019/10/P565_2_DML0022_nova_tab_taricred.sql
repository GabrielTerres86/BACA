-- Create table
create table CECRED.tbconv_historico_tarifa_cred
(
  cdcooper      number(10) not null,
  dtvigencia    date not null,
  tpmeiarr      varchar2(1) not null,
  vltarifa      number(25,2) not null,
  dtatualizacao date default sysdate not null
)
;
-- Add comments to the table 
comment on table CECRED.tbconv_historico_tarifa_cred
  is 'Armazena tarifas pagas pelos convenios (credito).';
-- Add comments to the columns 
comment on column CECRED.tbconv_historico_tarifa_cred.cdcooper
  is 'Codigo que identifica a Cooperativa.';
comment on column CECRED.tbconv_historico_tarifa_cred.dtvigencia
  is 'Data de vigencia da tarifa.';
comment on column CECRED.tbconv_historico_tarifa_cred.tpmeiarr
  is 'A-TAA, B-correspondente bancario, C-caixa, D-internet banking, E-debito automatico, F-arq cnab.';
comment on column CECRED.tbconv_historico_tarifa_cred.vltarifa
  is 'Valor da tarifa.';
comment on column CECRED.tbconv_historico_tarifa_cred.dtatualizacao
  is 'Data de atualizacao da tarifa.';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CECRED.tbconv_historico_tarifa_cred
  add constraint pk_tbconv_hist_tarifa_cred primary key (CDCOOPER, DTVIGENCIA, TPMEIARR);
