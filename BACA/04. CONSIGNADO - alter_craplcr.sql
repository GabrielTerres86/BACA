-- Add/modify columns 
alter table CECRED.CRAPLCR add tpmodcon number(1);
-- Add comments to the columns 
comment on column CECRED.CRAPLCR.tpmodcon
  is 'Tipo da modalidade do consignado';
