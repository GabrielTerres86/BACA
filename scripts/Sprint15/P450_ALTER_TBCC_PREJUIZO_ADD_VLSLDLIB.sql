-- Add/modify columns 
alter table CECRED.TBCC_PREJUIZO add vlsldlib number(25,2) default 0 not null;
-- Add comments to the columns 
comment on column CECRED.TBCC_PREJUIZO.vlsldlib
  is 'Saldo disponivel para operacoes (saque, pagamento, ...) na conta corrente';