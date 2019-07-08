-- Add/modify columns 
alter table CECRED.TBEPR_CONSIGNADO_PAGAMENTO add inconciliado number(1);
-- Add comments to the columns 
comment on column CECRED.TBEPR_CONSIGNADO_PAGAMENTO.inconciliado is 'Indicador se o movimento esta conciliado (0 - Não conciliado, 1 - Conciliado)';