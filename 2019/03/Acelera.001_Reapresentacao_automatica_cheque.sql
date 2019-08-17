-- Add/modify columns 
alter table CECRED.TBCHQ_PARAM_CONTA add flgreapre_autom NUMBER(1) default 0 not null;
-- Add comments to the columns 
comment on column CECRED.TBCHQ_PARAM_CONTA.flgreapre_autom
  is 'Efetuar reapresentação automática de cheques (0 - Não / 1 - Sim)';
