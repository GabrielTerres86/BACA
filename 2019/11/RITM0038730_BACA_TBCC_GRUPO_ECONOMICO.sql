-- Add/modify columns 
alter table CECRED.TBCC_GRUPO_ECONOMICO add flgcumulatividade number(1) default 0 not null;
-- Add comments to the columns 
comment on column CECRED.TBCC_GRUPO_ECONOMICO.flgcumulatividade
  is 'Considera todas as contas do grupo no calculo de cumulatividade das aplicacoes (0 - nao / 1 - sim)'; 