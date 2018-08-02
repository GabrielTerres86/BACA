-- Add/modify columns 
alter table CECRED.TBCC_PREJUIZO_DETALHE add idprejuizo number(10) default 0 not null;
-- Add comments to the columns 
comment on column CECRED.TBCC_PREJUIZO_DETALHE.idprejuizo
  is 'Id do lançamento na TBCC_PREJUIZO';