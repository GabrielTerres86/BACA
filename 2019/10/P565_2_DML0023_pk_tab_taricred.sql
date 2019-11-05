-- Add/modify columns 
alter table CECRED.TBCONV_HISTORICO_TARIFA_CRED add cdempres number(10) default " " not null;
-- Add comments to the columns 
comment on column CECRED.TBCONV_HISTORICO_TARIFA_CRED.cdempres
  is 'Contem o codigo da empresa no SICREDI.';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CECRED.TBCONV_HISTORICO_TARIFA_CRED
  drop constraint PK_TBCONV_HIST_TARIFA_CRED cascade;
alter table CECRED.TBCONV_HISTORICO_TARIFA_CRED
  add constraint PK_TBCONV_HIST_TARIFA_CRED primary key (CDCOOPER, DTVIGENCIA, CDEMPRES, TPMEIARR);
