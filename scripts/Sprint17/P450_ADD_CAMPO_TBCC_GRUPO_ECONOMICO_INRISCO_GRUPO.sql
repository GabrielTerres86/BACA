-- Add/modify columns 
alter table CECRED.TBCC_GRUPO_ECONOMICO add inrisco_grupo number(5) default 2 not null;
-- Add comments to the columns 
comment on column CECRED.TBCC_GRUPO_ECONOMICO.inrisco_grupo
  is 'Risco do Grupo Economico (2-9)';
