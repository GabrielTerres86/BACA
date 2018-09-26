-- Add/modify columns 
alter table CECRED.TBRECUP_ACORDO_CONTRATO add vliofdev number(25,2) default 0;
alter table CECRED.TBRECUP_ACORDO_CONTRATO add vliofpag number(25,2) default 0;
-- Add comments to the columns 
comment on column CECRED.TBRECUP_ACORDO_CONTRATO.vliofdev
  is 'Valor IOF devedor da operação';
comment on column CECRED.TBRECUP_ACORDO_CONTRATO.vliofpag
  is 'Valor IOF pago em acordo da operação';
-- Add/modify columns 
alter table CECRED.TBRECUP_ACORDO_CONTRATO add vlbasiof number(25,2) default 0;
-- Add comments to the columns 
comment on column CECRED.TBRECUP_ACORDO_CONTRATO.vlbasiof
  is 'Valor Base IOF Devedor';