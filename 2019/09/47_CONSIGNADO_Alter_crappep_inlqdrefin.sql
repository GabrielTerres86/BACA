-- Add/modify columns 
alter table CECRED.CRAPPEP add inlqdrefin number(1) default 0;
-- Add comments to the columns 
comment on column CECRED.CRAPPEP.inlqdrefin is 'Indica se a liquidação foi pelo refinanciamento (0 - Não, 1 - Sim)';