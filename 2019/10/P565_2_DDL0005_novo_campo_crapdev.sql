-- Add/modify columns 
alter table CECRED.CRAPDEV add cddevolu number(2) default 0;
-- Add comments to the columns 
comment on column CECRED.CRAPDEV.cddevolu
  is 'Tipo de devolucao (1-Bancoob, 2-Conta Base, 3-Conta Integracao, 5-Devolucao diurna, 6-Fraude.';
  
