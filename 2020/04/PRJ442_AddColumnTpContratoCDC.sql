-- Add/modify columns 
alter table CECRED.TBEPR_CDC_EMPRESTIMO add cdtpctremp number(10);
-- Add comments to the columns 
comment on column CECRED.TBEPR_CDC_EMPRESTIMO.cdtpctremp
  is 'Codigo tipo de contrato tbgen_dominio_campo nmdominio = TPCONTRATOCDC
  (21.Contrato Digital Diversos
   22.Contrato Digital Veículos Novos
   23.Contrato Digital Veículos Usados
   11.Contrato Físico Diversos
   12.Contrato Físico Veículos Novos
   13.Contrato Físico Veículos Usados)';
