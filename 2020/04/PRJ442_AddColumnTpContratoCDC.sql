-- Add/modify columns 
alter table CECRED.TBEPR_CDC_EMPRESTIMO add cdtpctremp number(10);
-- Add comments to the columns 
comment on column CECRED.TBEPR_CDC_EMPRESTIMO.cdtpctremp
  is 'Codigo tipo de contrato tbgen_dominio_campo nmdominio = TPCONTRATOCDC
  (21.Contrato Digital Diversos
   22.Contrato Digital Ve�culos Novos
   23.Contrato Digital Ve�culos Usados
   11.Contrato F�sico Diversos
   12.Contrato F�sico Ve�culos Novos
   13.Contrato F�sico Ve�culos Usados)';
