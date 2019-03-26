-- Add/modify columns 
alter table CECRED.CRAWEPR add inaverba number(1);
-- Add comments to the columns 
comment on column CECRED.CRAWEPR.inaverba is 'Indicador de averbação  (0-Nao, 1-Sim)';