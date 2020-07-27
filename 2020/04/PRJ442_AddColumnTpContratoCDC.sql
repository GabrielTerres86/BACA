-- Add/modify columns 
alter table CECRED.TBEPR_CDC_EMPRESTIMO add cdtpctremp number(10);
-- Add comments to the columns 
comment on column CECRED.TBEPR_CDC_EMPRESTIMO.cdtpctremp
  is 'Codigo tipo de contrato tbgen_dominio_campo nmdominio = TPCONTRATOCDC';
