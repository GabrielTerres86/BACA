-- Add/modify columns 
alter table CECRED.TBEPR_CONSIGNADO_PAGAMENTO add cdagenci number(5);
alter table CECRED.TBEPR_CONSIGNADO_PAGAMENTO add cdbccxlt number(5);
alter table CECRED.TBEPR_CONSIGNADO_PAGAMENTO add cdoperad varchar2(10);
-- Add comments to the columns 
comment on column CECRED.TBEPR_CONSIGNADO_PAGAMENTO.cdagenci
  is 'Codigo da Agencia';
comment on column CECRED.TBEPR_CONSIGNADO_PAGAMENTO.cdbccxlt
  is 'Codigo da Caixa';
comment on column CECRED.TBEPR_CONSIGNADO_PAGAMENTO.cdoperad
  is 'Codigo Operador';