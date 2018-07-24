-- Add/modify columns 
alter table CECRED.TBCC_PREJUIZO_LANCAMENTO add recid_craplcm number default 0 not null;
-- Add comments to the columns 
comment on column CECRED.TBCC_PREJUIZO_LANCAMENTO.recid_craplcm
  is 'PROGRESS_RECID do registro da CRAPLCM vinculado ao credito na Conta Transitoria';