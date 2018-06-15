-- Add/modify columns 
alter table CECRED.CRAPHIS add intrasnf_cred_prejuizo number(1) default 1 not null;
-- Add comments to the columns 
comment on column CECRED.CRAPHIS.intrasnf_cred_prejuizo
  is 'Indica se o historico de credito deve ser transferido para a conta transitoria caso a conta esteja em prejuizo (0 - Nao, 1 - Sim)';
comment on column CECRED.CRAPHIS.inestoura_conta
  is 'Contem o identificador para indicar se o historico deve ser debitado caso a conta esteja com atraso (ADP) de 60 dias ou mais. (0-Não e 1-Sim)';