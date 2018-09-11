-- Add/modify columns 
alter table CECRED.TBCC_PREJUIZO_DETALHE add dsjustificativa VARCHAR2(250) default ' ' not null;
-- Add comments to the columns 
comment on column CECRED.TBCC_PREJUIZO_DETALHE.dsjustificativa
  is 'Justificativa do estorno';