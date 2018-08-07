-- Add/modify columns 
alter table CECRED.TBCC_PREJUIZO_LANCAMENTO add vlsldlib number(25,2) default 0 not null;
-- Add comments to the columns 
comment on column CECRED.TBCC_PREJUIZO_LANCAMENTO.vlsldlib
  is 'Saldo liberado para operações na Conta Corrente';