-- Add/modify columns 
alter table CRAPEMP add nrdddemp number(2);
-- Add comments to the columns 
comment on column CRAPEMP.nrdddemp  is 'Número do DDD do telefone da empresa';
