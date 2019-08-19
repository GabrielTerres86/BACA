-- Add/modify columns 
alter table CECRED.TBCTD_TRANS_PEND add flgativo number(01) default 1;
-- Add comments to the columns 
comment on column CECRED.TBCTD_TRANS_PEND.flgativo
  is 'Indica se a pendencia está ativa (1=Ativo, 0=Inativo)';
