-- Add/modify columns 
alter table CECRED.TBEPR_CONSIGNADO_PAGAMENTO add dtmvtolt date;
-- Add comments to the columns 
comment on column CECRED.TBEPR_CONSIGNADO_PAGAMENTO.dtmvtolt is 'Data do movimento atual';