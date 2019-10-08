-- Create/Recreate primary, unique and foreign key constraints 
alter table CECRED.TBCONV_HISTORICO_TARIFA
  drop constraint PK_TBCONV_HISTORICO_TARIFA cascade;
alter table CECRED.TBCONV_HISTORICO_TARIFA
  add constraint PK_TBCONV_HISTORICO_TARIFA primary key (CDCOOPER, CDHISTOR, DSORIGEM, DTVIGENC);
