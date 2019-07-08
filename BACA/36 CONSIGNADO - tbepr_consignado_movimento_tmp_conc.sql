-- Add/modify columns 
alter table CECRED.TBEPR_CONSIG_MOVIMENTO_TMP add inconciliado number(1);
-- Add comments to the columns 
comment on column CECRED.TBEPR_CONSIG_MOVIMENTO_TMP.inconciliado  is 'Indicador de movimento conciliado (0 - Não conciliado, 1 - Conciliado)';
