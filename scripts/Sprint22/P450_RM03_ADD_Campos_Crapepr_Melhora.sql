-- Add/modify columns 
alter table CECRED.CRAPEPR add VLSALDO_REFINANCIADO NUMBER(25,2);

-- Add comments to the columns 
comment on column CECRED.CRAPEPR.VLSALDO_REFINANCIADO
  is 'Valor do Saldo que foi Refinanciado';
