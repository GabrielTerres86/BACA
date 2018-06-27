-- Add/modify columns 
alter table CECRED.CRAPSLD add vlblqprj number(25,2) default 0 not null;
-- Add comments to the columns 
comment on column CECRED.CRAPSLD.vlblqprj
  is 'Valor do saldo da conta transitória (créditos bloqueados por prejuízo em conta)';

-- Add/modify columns 
alter table CECRED.CRAPSDA add vlblqprj number(25,2) default 0 not null;
-- Add comments to the columns 
comment on column CECRED.CRAPSDA.vlblqprj
  is 'Valor do saldo da conta transitória (créditos bloqueados por prejuízo em conta)';